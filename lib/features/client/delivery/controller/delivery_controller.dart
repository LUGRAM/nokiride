import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/location/driver_tracking_service.dart';
import '../../../../core/location/location_service.dart';
import '../../../../core/location/place_provider.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/services/delivery_api_service.dart';
import '../../trip/model/place_model.dart';
import '../model/delivery_model.dart';

// ─── Tarification livraison ───────────────────────────────────
const double _base = 600;
const double _parKm = 200;
const double _vitesse = 22.0;
const int _minimum = 1000;

class DeliveryController extends GetxController {
  DeliveryController(this._deliveryService, this._placeProvider);

  final DeliveryApiService _deliveryService;
  final PlaceProvider _placeProvider;

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
  final Rx<ParcelSize> parcelSize = ParcelSize.medium.obs;
  final RxString recipientName = ''.obs;
  final RxString recipientPhone = ''.obs;
  final RxString parcelNote = ''.obs;

  // ─── Recherche de lieu ───────────────────────────────────────
  final RxList<PlaceModel> searchResults = <PlaceModel>[].obs;
  final RxBool isSearching = false.obs;
  final Rx<RxStatus> placeSearchStatus = RxStatus.empty().obs;

  Timer? _searchTimer;
  StreamSubscription<PlaceModel>? _courierTrackingSub;
  Worker? _userLocationWorker;

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

    final delay = 4 + Random().nextInt(4);
    _searchTimer = Timer(Duration(seconds: delay), _assignCourier);
  }

  Future<void> _assignCourier() async {
    if (currentDelivery.value == null) return;
    currentDelivery.value =
        currentDelivery.value!.copyWith(status: DeliveryStatus.assigned);
    status.value = DeliveryStatus.assigned;
    await _syncDeliveryStatus('assigned');
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
    _searchTimer?.cancel();
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
    _courierTrackingSub = DriverTrackingService.simulateRoute(
      pickup: delivery.pickup,
      dropoff: delivery.dropoff,
      label: 'Coursier',
    ).listen((position) {
      courierLocation.value = position;
    });
  }

  @override
  void onClose() {
    _searchTimer?.cancel();
    _courierTrackingSub?.cancel();
    _userLocationWorker?.dispose();
    super.onClose();
  }
}
