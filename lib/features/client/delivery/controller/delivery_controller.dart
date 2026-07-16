import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/location/delivery_tracking_service.dart';
import '../../../../core/location/location_service.dart';
import '../../../../core/location/place_provider.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/services/delivery_api_service.dart';
import '../../../../core/navigation/google_routes_service.dart';
import '../../../../core/navigation/route_geometry.dart';
import '../../../../core/storage/app_storage.dart';
import '../../trip/model/place_model.dart';
import '../model/delivery_model.dart';

// ─── Tarification livraison ───────────────────────────────────
const double _base = 600;
const double _parKm = 200;
const double _vitesse = 22.0;
const int _minimum = 1000;

class DeliveryController extends GetxController {
  DeliveryController(
    this._deliveryService,
    this._placeProvider, {
    GoogleRoutesService? routesService,
  }) : _routesService = routesService ?? const GoogleRoutesService();

  final DeliveryApiService _deliveryService;
  final PlaceProvider _placeProvider;
  final GoogleRoutesService _routesService;
  final DeliveryTrackingService _trackingService = DeliveryTrackingService();

  // ─── État ────────────────────────────────────────────────────
  final Rx<DeliveryModel?> currentDelivery = Rx<DeliveryModel?>(null);
  final Rx<DeliveryStatus> status = DeliveryStatus.idle.obs;
  final RxBool isConfirming = false.obs;
  final RxString lastPaymentReference = ''.obs;
  final RxString lastPaymentStatus = ''.obs;
  final RxString selectedPaymentMethod = 'noki_pay'.obs;

  // ─── Champs de saisie ────────────────────────────────────────
  final Rx<PlaceModel?> pickup = Rx<PlaceModel?>(null);
  final Rx<PlaceModel?> dropoff = Rx<PlaceModel?>(null);
  final Rx<PlaceModel?> userLocation = Rx<PlaceModel?>(null);
  final Rx<PlaceModel?> courierLocation = Rx<PlaceModel?>(null);
  final RxList<LatLng> routePoints = <LatLng>[].obs;
  final RxInt dynamicEtaSeconds = 0.obs;
  final Rx<ParcelSize> parcelSize = ParcelSize.medium.obs;
  final RxString recipientName = ''.obs;
  final RxString recipientPhone = ''.obs;
  final RxString parcelNote = ''.obs;

  // ─── Recherche de lieu ───────────────────────────────────────
  final RxList<PlaceModel> searchResults = <PlaceModel>[].obs;
  final RxBool isSearching = false.obs;
  final Rx<RxStatus> placeSearchStatus = RxStatus.empty().obs;

  StreamSubscription<DeliveryTrackingUpdate>? _courierTrackingSub;
  Worker? _userLocationWorker;
  Timer? _etaTimer;
  DateTime? _lastRerouteAt;
  bool _routeRefreshInFlight = false;
  String _remoteDeliveryStatus = 'searching';

  @override
  void onInit() {
    super.onInit();
    _restoreActiveDelivery();
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
    if (currentDelivery.value != null) return;
    final position = await LocationService.currentPosition();
    if (position == null || currentDelivery.value != null) return;
    pickup.value = PlaceModel(
      name: 'Position actuelle',
      address: 'Votre position GPS',
      lat: position.latitude,
      lng: position.longitude,
    );
  }

  // ─── Validation ──────────────────────────────────────────────
  bool get canEstimate =>
      pickup.value != null &&
      dropoff.value != null &&
      recipientName.value.trim().isNotEmpty &&
      _normalizeGabonPhone(recipientPhone.value) != null;

  // ─────────────────────────────────────────────────────────────
  // Recherche lieu (mock)
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

  void selectPickup(PlaceModel p) {
    pickup.value = p;
    clearSearch();
  }

  void selectDropoff(PlaceModel p) {
    dropoff.value = p;
    clearSearch();
  }

  void clearPickup() => pickup.value = null;
  void clearDropoff() => dropoff.value = null;

  void setParcelSize(ParcelSize s) => parcelSize.value = s;

  // ─────────────────────────────────────────────────────────────
  // Estimation
  // ─────────────────────────────────────────────────────────────
  Future<void> estimateDelivery() async {
    if (!canEstimate) return;

    final dist = pickup.value!.distanceTo(dropoff.value!);
    try {
      final data = await _deliveryService.estimate(dist, parcelSize.value.name);
      _applyEstimate(dist, data);
      Get.toNamed(Routes.deliveryEstimate);
      return;
    } catch (_) {
      // Le calcul local sert uniquement de secours hors ligne.
    }

    final prix = max(
      _minimum,
      (_base + dist * _parKm + parcelSize.value.surcharge).round(),
    );
    final prixArrondi = ((prix / 50).round() * 50);
    final duree = max(8, (dist / _vitesse * 60).round());

    _applyEstimate(dist, {
      'distance_km': dist,
      'price_fcfa': prixArrondi,
      'estimated_minutes': duree,
    });

    Get.toNamed(Routes.deliveryEstimate);
  }

  // ─────────────────────────────────────────────────────────────
  // Confirmation
  // ─────────────────────────────────────────────────────────────
  Future<void> confirmDelivery() async {
    if (currentDelivery.value == null) return;
    isConfirming.value = true;
    final created = await _createDeliveryOnBackend();
    isConfirming.value = false;
    if (!created) return;

    await _showMockPaymentSuccess();
    currentDelivery.value =
        currentDelivery.value!.copyWith(status: DeliveryStatus.searching);
    status.value = DeliveryStatus.searching;
    Get.toNamed(Routes.deliverySearching);
    _startCourierTracking();
  }

  Future<void> _assignCourier() async {
    if (currentDelivery.value == null) return;
    currentDelivery.value =
        currentDelivery.value!.copyWith(status: DeliveryStatus.assigned);
    status.value = DeliveryStatus.assigned;
    _remoteDeliveryStatus = 'assigned';
    await _persistActiveDelivery();
    _startCourierTracking();
    Get.offNamed(Routes.deliveryTracking);
  }

  Future<void> completeDelivery() async {
    currentDelivery.value =
        currentDelivery.value?.copyWith(status: DeliveryStatus.delivered);
    status.value = DeliveryStatus.delivered;
    await _syncDeliveryStatus('delivered');
    _reset();
    Get.offAllNamed(Routes.home);
  }

  void cancelDelivery() {
    currentDelivery.value =
        currentDelivery.value?.copyWith(status: DeliveryStatus.cancelled);
    _reset();
    Get.offAllNamed(Routes.home);
  }

  void _reset() {
    Future.delayed(const Duration(seconds: 1), () {
      pickup.value = null;
      dropoff.value = null;
      courierLocation.value = null;
      recipientName.value = '';
      recipientPhone.value = '';
      parcelNote.value = '';
      parcelSize.value = ParcelSize.medium;
      currentDelivery.value = null;
      status.value = DeliveryStatus.idle;
      _courierTrackingSub?.cancel();
      _etaTimer?.cancel();
      routePoints.clear();
      unawaited(AppStorage.clearActiveDelivery());
    });
  }

  String _generateId() =>
      DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase();

  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  void _applyEstimate(double distanceKm, Map<String, dynamic> data) {
    final current = currentDelivery.value;
    currentDelivery.value = DeliveryModel(
      id: current?.id ?? _generateId(),
      pickup: pickup.value!,
      dropoff: dropoff.value!,
      recipient: RecipientModel(
        name: recipientName.value.trim(),
        phone: recipientPhone.value.trim(),
      ),
      parcelSize: parcelSize.value,
      parcelNote:
          parcelNote.value.trim().isEmpty ? null : parcelNote.value.trim(),
      distanceKm:
          double.tryParse('${data['distance_km'] ?? distanceKm}') ?? distanceKm,
      priceFCFA: int.tryParse('${data['price_fcfa'] ?? 0}') ?? 0,
      estimatedMinutes: int.tryParse('${data['estimated_minutes'] ?? 0}') ?? 0,
      status: current?.status ?? DeliveryStatus.estimating,
    );
  }

  Future<bool> _createDeliveryOnBackend() async {
    final delivery = currentDelivery.value;
    if (delivery == null) return false;

    try {
      final data = await _deliveryService.create({
        'pickup_address': delivery.pickup.address,
        'dropoff_address': delivery.dropoff.address,
        'pickup_latitude': delivery.pickup.lat,
        'pickup_longitude': delivery.pickup.lng,
        'dropoff_latitude': delivery.dropoff.lat,
        'dropoff_longitude': delivery.dropoff.lng,
        'recipient_name': delivery.recipient.name,
        'recipient_phone': _normalizeGabonPhone(delivery.recipient.phone),
        'parcel_size': delivery.parcelSize.name,
        'parcel_note': delivery.parcelNote,
        'distance_km': delivery.distanceKm,
        'payment_method': selectedPaymentMethod.value,
      });
      lastPaymentReference.value = '${data['payment_reference'] ?? ''}';
      lastPaymentStatus.value = '${data['payment_status'] ?? ''}';
      if (lastPaymentStatus.value != 'paid') {
        Get.snackbar('Paiement en attente',
            'Le paiement doit être validé avant de rechercher un coursier.',
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }
      currentDelivery.value = delivery.copyWith(
        id: '${data['id'] ?? delivery.id}',
        status: DeliveryStatus.searching,
      );
      _remoteDeliveryStatus = '${data['status'] ?? 'searching'}';
      await _persistActiveDelivery();
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

  String? _normalizeGabonPhone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (RegExp(r'^241\d{8}$').hasMatch(digits)) return '+$digits';
    if (RegExp(r'^0\d{8}$').hasMatch(digits)) {
      return '+241${digits.substring(1)}';
    }
    if (RegExp(r'^\d{8}$').hasMatch(digits)) return '+241$digits';
    return null;
  }

  Future<void> _showMockPaymentSuccess() async {
    Get.dialog(
      AlertDialog(
        title: const Text('Paiement validé'),
        content: Text(
          lastPaymentReference.value.isEmpty
              ? 'Paiement mock confirmé.'
              : 'Paiement mock confirmé.\nRéférence ${lastPaymentReference.value}',
        ),
      ),
      barrierDismissible: false,
    );
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (Get.isDialogOpen == true) Get.back();
  }

  Future<void> _syncDeliveryStatus(String apiStatus) async {
    final id = int.tryParse(currentDelivery.value?.id ?? '');
    if (id == null) return;
    try {
      await _deliveryService.updateStatus(id, apiStatus);
      _remoteDeliveryStatus = apiStatus;
      await _persistActiveDelivery();
    } on ApiException catch (error) {
      Get.snackbar('Synchronisation impossible', error.message,
          snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      // La simulation locale continue même si le backend est indisponible.
    }
  }

  void _startCourierTracking() {
    final delivery = currentDelivery.value;
    if (delivery == null) return;
    _courierTrackingSub?.cancel();
    _courierTrackingSub = _trackingService.updates.listen((update) {
      final isFirstPosition = courierLocation.value == null;
      courierLocation.value = update.position;
      _remoteDeliveryStatus = update.deliveryStatus;
      if (status.value == DeliveryStatus.searching) {
        unawaited(_assignCourier());
      }
      if (isFirstPosition) unawaited(_refreshDynamicEta());
      _maybeRecalculateForDeviation(update.position);
      unawaited(_persistActiveDelivery());
    });
    _trackingService.subscribe(delivery.id).catchError((Object error) {
      Get.snackbar(
        'Suivi indisponible',
        'Vérifiez votre connexion puis rouvrez le suivi de la livraison.',
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
    _courierTrackingSub?.cancel();
    _etaTimer?.cancel();
    _trackingService.dispose();
    _userLocationWorker?.dispose();
    super.onClose();
  }

  Future<void> _loadRoute() async {
    final delivery = currentDelivery.value;
    if (delivery == null) return;
    try {
      final route = await _routesService.route(
        origin: LatLng(delivery.pickup.lat, delivery.pickup.lng),
        destination: LatLng(delivery.dropoff.lat, delivery.dropoff.lng),
      );
      routePoints.assignAll(route.points);
      dynamicEtaSeconds.value = route.durationSeconds;
      currentDelivery.value = delivery.copyWith(
        estimatedMinutes: max(1, (route.durationSeconds / 60).ceil()),
      );
      await _persistActiveDelivery();
    } catch (_) {
      routePoints.clear();
    }
  }

  Future<void> _refreshDynamicEta({bool redrawRoute = false}) async {
    final courier = courierLocation.value;
    final delivery = currentDelivery.value;
    if (courier == null || delivery == null || _routeRefreshInFlight) return;
    _routeRefreshInFlight = true;
    try {
      final target = _remoteDeliveryStatus == 'in_progress'
          ? delivery.dropoff
          : delivery.pickup;
      final route = await _routesService.route(
        origin: LatLng(courier.lat, courier.lng),
        destination: LatLng(target.lat, target.lng),
      );
      dynamicEtaSeconds.value = route.durationSeconds;
      currentDelivery.value = delivery.copyWith(
        estimatedMinutes: max(1, (route.durationSeconds / 60).ceil()),
      );
      if (redrawRoute) routePoints.assignAll(route.points);
      await _persistActiveDelivery();
    } catch (_) {
      // Conserver la dernière ETA connue pendant la coupure.
    } finally {
      _routeRefreshInFlight = false;
    }
  }

  void _maybeRecalculateForDeviation(PlaceModel courier) {
    if (_remoteDeliveryStatus != 'in_progress' || routePoints.length < 2) {
      return;
    }
    final last = _lastRerouteAt;
    if (last != null &&
        DateTime.now().difference(last) < const Duration(minutes: 1)) {
      return;
    }
    final deviation = RouteGeometry.distanceToRouteMeters(
      LatLng(courier.lat, courier.lng),
      routePoints,
    );
    if (deviation <= 100) return;
    _lastRerouteAt = DateTime.now();
    unawaited(_refreshDynamicEta(redrawRoute: true));
  }

  void _restoreActiveDelivery() {
    final stored = AppStorage.activeDelivery;
    final pickupData = stored?['pickup'];
    final dropoffData = stored?['dropoff'];
    if (stored == null || pickupData is! Map || dropoffData is! Map) return;
    final restoredPickup =
        PlaceModel.fromJson(Map<String, dynamic>.from(pickupData));
    final restoredDropoff =
        PlaceModel.fromJson(Map<String, dynamic>.from(dropoffData));
    pickup.value = restoredPickup;
    dropoff.value = restoredDropoff;
    final restoredStatus = _deliveryStatusFromApi('${stored['status']}');
    currentDelivery.value = DeliveryModel(
      id: '${stored['id']}',
      pickup: restoredPickup,
      dropoff: restoredDropoff,
      recipient: RecipientModel(
        name: '${stored['recipient_name'] ?? ''}',
        phone: '${stored['recipient_phone'] ?? ''}',
      ),
      parcelSize: ParcelSize.values.firstWhere(
        (value) => value.name == stored['parcel_size'],
        orElse: () => ParcelSize.medium,
      ),
      parcelNote: stored['parcel_note']?.toString(),
      distanceKm: double.tryParse('${stored['distance_km']}') ?? 0,
      priceFCFA: int.tryParse('${stored['price_fcfa']}') ?? 0,
      estimatedMinutes: int.tryParse('${stored['estimated_minutes']}') ?? 0,
      status: restoredStatus,
    );
    status.value = restoredStatus;
    _remoteDeliveryStatus = '${stored['status'] ?? 'searching'}';
    final savedRoute = stored['last_polyline'];
    if (savedRoute is List) {
      routePoints.assignAll(savedRoute.whereType<Map>().map((point) => LatLng(
            double.parse('${point['latitude']}'),
            double.parse('${point['longitude']}'),
          )));
    }
    _startCourierTracking();
    if (routePoints.isEmpty) unawaited(_loadRoute());
  }

  DeliveryStatus _deliveryStatusFromApi(String value) => switch (value) {
        'searching' => DeliveryStatus.searching,
        'assigned' => DeliveryStatus.assigned,
        'in_progress' => DeliveryStatus.inProgress,
        'delivered' => DeliveryStatus.delivered,
        'cancelled' => DeliveryStatus.cancelled,
        _ => DeliveryStatus.searching,
      };

  Future<void> _persistActiveDelivery() async {
    final delivery = currentDelivery.value;
    if (delivery == null) return;
    await AppStorage.saveActiveDelivery({
      'id': delivery.id,
      'status': _remoteDeliveryStatus,
      'pickup': delivery.pickup.toJson(),
      'dropoff': delivery.dropoff.toJson(),
      'recipient_name': delivery.recipient.name,
      'recipient_phone': delivery.recipient.phone,
      'parcel_size': delivery.parcelSize.name,
      'parcel_note': delivery.parcelNote,
      'distance_km': delivery.distanceKm,
      'price_fcfa': delivery.priceFCFA,
      'estimated_minutes': delivery.estimatedMinutes,
      'last_polyline': routePoints
          .map((point) => {
                'latitude': point.latitude,
                'longitude': point.longitude,
              })
          .toList(growable: false),
    });
  }
}
