import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/location/location_service.dart';
import '../../../../core/location/place_provider.dart';
import '../../../../core/location/trip_tracking_service.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/navigation/google_routes_service.dart';
import '../../../../core/navigation/route_geometry.dart';
import '../../../../core/network/services/trip_api_service.dart';
import '../../../../core/storage/app_storage.dart';
import '../model/place_model.dart';
import '../model/trip_model.dart';

// ─── Tarification locale ──────────────────────────────────────
const double _tarifBase = 500; // F CFA fixe au départ
const double _tarifParKm = 250; // F CFA / km
const double _vitesseKmH = 25; // vitesse moyenne coursier
const int _tarifMinimum = 800; // prix plancher

enum TripStep { destination, selecting, matching, tracking }

class TripController extends GetxController {
  TripController(
    this._tripService,
    this._placeProvider, {
    GoogleRoutesService? routesService,
  }) : _routesService = routesService ?? const GoogleRoutesService();

  final TripApiService _tripService;
  final PlaceProvider _placeProvider;
  final GoogleRoutesService _routesService;
  final TripTrackingService _trackingService = TripTrackingService();

  // ─── Flux UX ────────────────────────────────────────────────
  final Rx<TripStep> currentStep = TripStep.destination.obs;
  final RxString selectedServiceId = 'eco'.obs; // eco, premium, delivery
  final RxString selectedPaymentMethod = 'noki_pay'.obs;

  // ─── État de la course ──────────────────────────────────────
  final Rx<TripModel?> currentTrip = Rx<TripModel?>(null);
  final Rx<TripStatus> status = TripStatus.idle.obs;
  final RxBool isConfirming = false.obs;
  final RxString lastPaymentReference = ''.obs;
  final RxString lastPaymentStatus = ''.obs;

  // ─── Champs de saisie ───────────────────────────────────────
  final Rx<PlaceModel?> pickup = Rx<PlaceModel?>(null);
  final Rx<PlaceModel?> dropoff = Rx<PlaceModel?>(null);
  final Rx<PlaceModel?> userLocation = Rx<PlaceModel?>(null);
  final Rx<PlaceModel?> driverLocation = Rx<PlaceModel?>(null);
  final RxList<LatLng> routePoints = <LatLng>[].obs;
  final RxBool isRouteLoading = false.obs;
  final RxInt dynamicEtaSeconds = 0.obs;

  // ─── Recherche de lieu ──────────────────────────────────────
  final RxList<PlaceModel> searchResults = <PlaceModel>[].obs;
  final RxBool isSearching = false.obs;
  final Rx<RxStatus> placeSearchStatus = RxStatus.empty().obs;

  // ─── Timer de simulation ────────────────────────────────────
  StreamSubscription<DriverTrackingUpdate>? _driverTrackingSub;
  Worker? _userLocationWorker;
  Timer? _etaTimer;
  DateTime? _lastRerouteAt;
  bool _routeRefreshInFlight = false;
  String _remoteTripStatus = 'searching';

  // ─── Getters ────────────────────────────────────────────────
  bool get canEstimate => pickup.value != null && dropoff.value != null;

  @override
  void onInit() {
    super.onInit();
    _restoreActiveTrip();
    _setCurrentPickup();
    userLocation.bindStream(LocationService.placeStream());
    _userLocationWorker = ever<PlaceModel?>(userLocation, (place) {
      if (place == null) return;
      if (pickup.value == null || pickup.value?.name == 'Position actuelle') {
        pickup.value = place;
      }
    });
  }

  void _restoreActiveTrip() {
    final stored = AppStorage.activeTrip;
    if (stored == null) return;
    final pickupData = stored['pickup'];
    final dropoffData = stored['dropoff'];
    if (pickupData is! Map || dropoffData is! Map) return;

    final restoredStatus = _tripStatusFromApi('${stored['status'] ?? ''}');
    final restoredPickup = PlaceModel.fromJson(
      Map<String, dynamic>.from(pickupData),
    );
    final restoredDropoff = PlaceModel.fromJson(
      Map<String, dynamic>.from(dropoffData),
    );
    pickup.value = restoredPickup;
    dropoff.value = restoredDropoff;
    currentTrip.value = TripModel(
      id: '${stored['id']}',
      pickup: restoredPickup,
      dropoff: restoredDropoff,
      distanceKm: double.tryParse('${stored['distance_km']}') ?? 0,
      priceFCFA: int.tryParse('${stored['price_fcfa']}') ?? 0,
      estimatedMinutes: int.tryParse('${stored['estimated_minutes']}') ?? 0,
      status: restoredStatus,
    );
    _remoteTripStatus = '${stored['status'] ?? 'searching'}';
    final savedRoute = stored['last_polyline'];
    if (savedRoute is List) {
      routePoints.assignAll(savedRoute.whereType<Map>().map((point) => LatLng(
            double.parse('${point['latitude']}'),
            double.parse('${point['longitude']}'),
          )));
    }
    currentStep.value = restoredStatus == TripStatus.searching
        ? TripStep.matching
        : TripStep.tracking;
    _startDriverTracking();
    if (routePoints.isEmpty) unawaited(_loadRoute());
  }

  Future<void> _setCurrentPickup() async {
    if (currentTrip.value != null) return;
    final position = await LocationService.currentPosition();
    if (position == null || currentTrip.value != null) return;
    pickup.value = PlaceModel(
      name: 'Position actuelle',
      address: 'Votre position GPS',
      lat: position.latitude,
      lng: position.longitude,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Navigation Flux
  // ─────────────────────────────────────────────────────────────
  Future<void> nextStep() async {
    HapticFeedback.mediumImpact();
    if (currentStep.value == TripStep.destination) {
      if (canEstimate) {
        await _calculatePrice();
        currentStep.value = TripStep.selecting;
      } else {
        Get.snackbar("Oups", "Veuillez sélectionner une destination");
      }
    } else if (currentStep.value == TripStep.selecting) {
      await confirmTrip();
    }
  }

  void prevStep() {
    if (currentStep.value == TripStep.selecting) {
      currentStep.value = TripStep.destination;
    } else if (currentStep.value == TripStep.matching) {
      currentStep.value = TripStep.selecting;
    } else {
      Get.back();
    }
  }

  Future<void> selectService(String id) async {
    HapticFeedback.lightImpact();
    selectedServiceId.value = id;
    await _calculatePrice();
  }

  Future<void> _calculatePrice() async {
    if (!canEstimate) return;
    final dist = pickup.value!.distanceTo(dropoff.value!);
    try {
      final data = await _tripService.estimate(
        dist,
        selectedServiceId.value == 'premium' ? 'premium' : 'eco',
      );
      _applyEstimate(dist, data);
      return;
    } catch (_) {
      // Le calcul local sert uniquement de secours hors ligne.
    }

    double multiplier = selectedServiceId.value == 'premium' ? 1.5 : 1.0;

    final prix = max(
      _tarifMinimum,
      ((_tarifBase + dist * _tarifParKm) * multiplier).round(),
    );
    final prixArrondi = ((prix / 50).round() * 50);
    final duree = max(5, (dist / _vitesseKmH * 60).round());

    _applyEstimate(dist, {
      'distance_km': dist,
      'price_fcfa': prixArrondi,
      'estimated_minutes': duree,
    });
  }

  // ─────────────────────────────────────────────────────────────
  // Recherche de lieu (mock)
  // ─────────────────────────────────────────────────────────────
  Future<void> searchPlace(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      placeSearchStatus.value = RxStatus.empty();
      return;
    }
    isSearching.value = true;
    placeSearchStatus.value = RxStatus.loading();
    try {
      final data = await _placeProvider.search(query.trim());
      searchResults.value = data;
      placeSearchStatus.value =
          data.isEmpty ? RxStatus.empty() : RxStatus.success();
    } catch (_) {
      placeSearchStatus.value = RxStatus.error('Recherche indisponible.');
    } finally {
      isSearching.value = false;
    }
  }

  void clearSearch() => searchResults.clear();

  void selectPickup(PlaceModel place) {
    pickup.value = place;
    searchResults.clear();
    if (canEstimate) _calculatePrice();
  }

  void selectDropoff(PlaceModel place) {
    dropoff.value = place;
    searchResults.clear();
    if (canEstimate) {
      nextStep();
    }
  }

  void clearPickup() => pickup.value = null;
  void clearDropoff() => dropoff.value = null;

  void estimateTrip() => nextStep();

  // ─────────────────────────────────────────────────────────────
  // Confirmation → recherche coursier
  // ─────────────────────────────────────────────────────────────
  Future<void> confirmTrip() async {
    if (currentTrip.value == null) return;
    isConfirming.value = true;
    final created = await _createTripOnBackend();
    isConfirming.value = false;
    if (!created) return;

    currentStep.value = TripStep.matching;
    status.value = TripStatus.searching;
    _startDriverTracking();
  }

  Future<void> completeTrip() async {
    status.value = TripStatus.completed;
    currentTrip.value =
        currentTrip.value?.copyWith(status: TripStatus.completed);
    await _syncTripStatus('completed');
    _reset();
    Get.offAllNamed(Routes.home);
  }

  void cancelTrip() {
    _reset();
    Get.offAllNamed(Routes.home);
  }

  void _reset() {
    currentStep.value = TripStep.destination;
    pickup.value = userLocation.value;
    dropoff.value = null;
    driverLocation.value = null;
    routePoints.clear();
    currentTrip.value = null;
    status.value = TripStatus.idle;
    _driverTrackingSub?.cancel();
    _etaTimer?.cancel();
    unawaited(AppStorage.clearActiveTrip());
  }

  String _generateId() =>
      DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase();

  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  void _applyEstimate(double distanceKm, Map<String, dynamic> data) {
    final current = currentTrip.value;
    currentTrip.value = TripModel(
      id: current?.id ?? _generateId(),
      pickup: pickup.value!,
      dropoff: dropoff.value!,
      distanceKm:
          double.tryParse('${data['distance_km'] ?? distanceKm}') ?? distanceKm,
      priceFCFA: int.tryParse('${data['price_fcfa'] ?? 0}') ?? 0,
      estimatedMinutes: int.tryParse('${data['estimated_minutes'] ?? 0}') ?? 0,
      status: current?.status ?? TripStatus.estimating,
    );
  }

  Future<bool> _createTripOnBackend() async {
    final trip = currentTrip.value;
    if (trip == null) return false;

    try {
      final data = await _tripService.create({
        'pickup_address': trip.pickup.address,
        'dropoff_address': trip.dropoff.address,
        'pickup_latitude': trip.pickup.lat,
        'pickup_longitude': trip.pickup.lng,
        'dropoff_latitude': trip.dropoff.lat,
        'dropoff_longitude': trip.dropoff.lng,
        'distance_km': trip.distanceKm,
        'service_type':
            selectedServiceId.value == 'premium' ? 'premium' : 'eco',
        'payment_method': selectedPaymentMethod.value,
      });
      lastPaymentReference.value = '${data['payment_reference'] ?? ''}';
      lastPaymentStatus.value = '${data['payment_status'] ?? ''}';
      if (lastPaymentStatus.value != 'paid') {
        Get.snackbar('Paiement en attente',
            'Le paiement doit être validé avant de rechercher un chauffeur.',
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }
      currentTrip.value = TripModel(
        id: '${data['id'] ?? trip.id}',
        pickup: trip.pickup,
        dropoff: trip.dropoff,
        distanceKm: trip.distanceKm,
        priceFCFA: trip.priceFCFA,
        estimatedMinutes: trip.estimatedMinutes,
        status: TripStatus.searching,
      );
      await _persistActiveTrip();
      unawaited(_loadRoute());
      return true;
    } on ApiException catch (error) {
      Get.snackbar('Paiement impossible', error.message,
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } catch (_) {
      Get.snackbar(
          'Paiement impossible', 'Vérifiez votre connexion puis réessayez.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  Future<void> _loadRoute() async {
    final trip = currentTrip.value;
    if (trip == null) return;

    isRouteLoading.value = true;
    try {
      final route = await _routesService.route(
        origin: LatLng(trip.pickup.lat, trip.pickup.lng),
        destination: LatLng(trip.dropoff.lat, trip.dropoff.lng),
      );
      routePoints.assignAll(route.points);
      dynamicEtaSeconds.value = route.durationSeconds;
      currentTrip.value = currentTrip.value?.copyWith(
        estimatedMinutes: max(1, (route.durationSeconds / 60).ceil()),
      );
      await _persistActiveTrip();
    } catch (_) {
      routePoints.clear();
    } finally {
      isRouteLoading.value = false;
    }
  }

  Future<void> _syncTripStatus(String apiStatus) async {
    final id = int.tryParse(currentTrip.value?.id ?? '');
    if (id == null) return;
    try {
      await _tripService.updateStatus(id, apiStatus);
    } on ApiException catch (error) {
      Get.snackbar('Synchronisation impossible', error.message,
          snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      // L'état local reste visible pendant une coupure temporaire.
    }
  }

  void _startDriverTracking() {
    final trip = currentTrip.value;
    if (trip == null) return;
    _driverTrackingSub?.cancel();
    _driverTrackingSub = _trackingService.positions.listen((update) {
      final isFirstPosition = driverLocation.value == null;
      driverLocation.value = update.position;
      _remoteTripStatus = update.tripStatus;
      if (currentStep.value != TripStep.tracking) {
        status.value = TripStatus.assigned;
        currentTrip.value =
            currentTrip.value?.copyWith(status: TripStatus.assigned);
        currentStep.value = TripStep.tracking;
      }
      unawaited(_persistActiveTrip());
      if (isFirstPosition) unawaited(_refreshDynamicEta());
      _maybeRecalculateForDeviation(update.position);
    });
    _trackingService.subscribe(trip.id).catchError((Object error) {
      Get.snackbar(
        'Suivi indisponible',
        'Vérifiez votre connexion puis rouvrez le suivi de la course.',
        snackPosition: SnackPosition.BOTTOM,
      );
    });
    _etaTimer?.cancel();
    _etaTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _refreshDynamicEta(),
    );
  }

  @override
  void onClose() {
    _driverTrackingSub?.cancel();
    _etaTimer?.cancel();
    _trackingService.dispose();
    _userLocationWorker?.dispose();
    super.onClose();
  }

  Future<void> _refreshDynamicEta({bool redrawRoute = false}) async {
    final driver = driverLocation.value;
    final trip = currentTrip.value;
    if (driver == null || trip == null || _routeRefreshInFlight) return;
    _routeRefreshInFlight = true;
    try {
      final target =
          _remoteTripStatus == 'in_progress' ? trip.dropoff : trip.pickup;
      final route = await _routesService.route(
        origin: LatLng(driver.lat, driver.lng),
        destination: LatLng(target.lat, target.lng),
      );
      dynamicEtaSeconds.value = route.durationSeconds;
      currentTrip.value = trip.copyWith(
        estimatedMinutes: max(1, (route.durationSeconds / 60).ceil()),
      );
      if (redrawRoute) routePoints.assignAll(route.points);
      await _persistActiveTrip();
    } catch (_) {
      // La dernière ETA fiable reste affichée hors connexion.
    } finally {
      _routeRefreshInFlight = false;
    }
  }

  void _maybeRecalculateForDeviation(PlaceModel driver) {
    if (_remoteTripStatus != 'in_progress' || routePoints.length < 2) return;
    final last = _lastRerouteAt;
    if (last != null &&
        DateTime.now().difference(last) < const Duration(minutes: 1)) {
      return;
    }
    final distance = RouteGeometry.distanceToRouteMeters(
      LatLng(driver.lat, driver.lng),
      routePoints,
    );
    if (distance <= 100) return;
    _lastRerouteAt = DateTime.now();
    unawaited(_refreshDynamicEta(redrawRoute: true));
  }

  TripStatus _tripStatusFromApi(String value) => switch (value) {
        'searching' => TripStatus.searching,
        'accepted' || 'assigned' => TripStatus.assigned,
        'in_progress' => TripStatus.inProgress,
        'completed' => TripStatus.completed,
        'cancelled' => TripStatus.cancelled,
        _ => TripStatus.searching,
      };

  Future<void> _persistActiveTrip() async {
    final trip = currentTrip.value;
    if (trip == null) return;
    await AppStorage.saveActiveTrip({
      'id': trip.id,
      'status': _remoteTripStatus,
      'pickup': trip.pickup.toJson(),
      'dropoff': trip.dropoff.toJson(),
      'distance_km': trip.distanceKm,
      'price_fcfa': trip.priceFCFA,
      'estimated_minutes': trip.estimatedMinutes,
      'last_polyline': routePoints
          .map((point) => {
                'latitude': point.latitude,
                'longitude': point.longitude,
              })
          .toList(growable: false),
    });
  }
}
