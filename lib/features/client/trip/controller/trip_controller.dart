import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/location/driver_tracking_service.dart';
import '../../../../core/location/location_service.dart';
import '../../../../core/location/place_provider.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/services/trip_api_service.dart';
import '../model/place_model.dart';
import '../model/trip_model.dart';

// ─── Tarification locale ──────────────────────────────────────
const double _tarifBase = 500; // F CFA fixe au départ
const double _tarifParKm = 250; // F CFA / km
const double _vitesseKmH = 25; // vitesse moyenne coursier
const int _tarifMinimum = 800; // prix plancher

enum TripStep { destination, selecting, matching, tracking }

class TripController extends GetxController {
  TripController(this._tripService, this._placeProvider);

  final TripApiService _tripService;
  final PlaceProvider _placeProvider;

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

  // ─── Recherche de lieu ──────────────────────────────────────
  final RxList<PlaceModel> searchResults = <PlaceModel>[].obs;
  final RxBool isSearching = false.obs;
  final Rx<RxStatus> placeSearchStatus = RxStatus.empty().obs;

  // ─── Timer de simulation ────────────────────────────────────
  Timer? _searchTimer;
  StreamSubscription<PlaceModel>? _driverTrackingSub;
  Worker? _userLocationWorker;

  // ─── Getters ────────────────────────────────────────────────
  bool get canEstimate => pickup.value != null && dropoff.value != null;

  @override
  void onInit() {
    super.onInit();
    _setCurrentPickup();
    userLocation.bindStream(LocationService.placeStream());
    _userLocationWorker = ever<PlaceModel?>(userLocation, (place) {
      if (place == null) return;
      if (pickup.value == null || pickup.value?.name == 'Position actuelle') {
        pickup.value = place;
      }
    });
  }

  Future<void> _setCurrentPickup() async {
    final position = await LocationService.currentPosition();
    if (position == null) return;
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
    final delay = 4 + Random().nextInt(4);
    _searchTimer = Timer(Duration(seconds: delay), _assignDriver);
  }

  Future<void> _assignDriver() async {
    status.value = TripStatus.assigned;
    currentTrip.value =
        currentTrip.value?.copyWith(status: TripStatus.assigned);
    await _syncTripStatus('assigned');
    currentStep.value = TripStep.tracking;
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
    _searchTimer?.cancel();
    _reset();
    Get.offAllNamed(Routes.home);
  }

  void _reset() {
    currentStep.value = TripStep.destination;
    pickup.value = userLocation.value;
    dropoff.value = null;
    driverLocation.value = null;
    currentTrip.value = null;
    status.value = TripStatus.idle;
    _driverTrackingSub?.cancel();
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

  Future<void> _syncTripStatus(String apiStatus) async {
    final id = int.tryParse(currentTrip.value?.id ?? '');
    if (id == null) return;
    try {
      await _tripService.updateStatus(id, apiStatus);
    } on ApiException catch (error) {
      Get.snackbar('Synchronisation impossible', error.message,
          snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      // La simulation locale continue même si le backend est indisponible.
    }
  }

  void _startDriverTracking() {
    final trip = currentTrip.value;
    if (trip == null) return;
    _driverTrackingSub?.cancel();
    _driverTrackingSub = DriverTrackingService.simulateRoute(
      pickup: trip.pickup,
      dropoff: trip.dropoff,
      label: 'Chauffeur',
    ).listen((position) {
      driverLocation.value = position;
    });
  }

  @override
  void onClose() {
    _searchTimer?.cancel();
    _driverTrackingSub?.cancel();
    _userLocationWorker?.dispose();
    super.onClose();
  }
}
