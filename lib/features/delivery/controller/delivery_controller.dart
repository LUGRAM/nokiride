import 'dart:async';
import 'dart:math';

import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/services/delivery_api_service.dart';
import '../../trip/model/place_model.dart';
import '../model/delivery_model.dart';

// ─── Tarification livraison ───────────────────────────────────
const double _base = 600;
const double _parKm = 200;
const double _vitesse = 22.0;
const int _minimum = 1000;

// ─── Lieux Libreville (partagé avec trip) ────────────────────
const _lieux = [
  PlaceModel(
      name: 'Akanda',
      address: 'Quartier Akanda, Libreville',
      lat: 0.4477,
      lng: 9.4321),
  PlaceModel(
      name: 'Charbonnages',
      address: 'Quartier Charbonnages, Libreville',
      lat: 0.3875,
      lng: 9.4523),
  PlaceModel(
      name: 'Batterie IV',
      address: 'Batterie IV, Libreville',
      lat: 0.3812,
      lng: 9.4502),
  PlaceModel(
      name: 'Nzeng-Ayong',
      address: 'Nzeng-Ayong, Libreville',
      lat: 0.3761,
      lng: 9.4689),
  PlaceModel(
      name: 'Glass',
      address: 'Quartier Glass, Libreville',
      lat: 0.3906,
      lng: 9.4441),
  PlaceModel(
      name: 'Louis',
      address: 'Quartier Louis, Libreville',
      lat: 0.3847,
      lng: 9.4378),
  PlaceModel(
      name: 'Nombakélé',
      address: 'Nombakélé, Libreville',
      lat: 0.4021,
      lng: 9.4612),
  PlaceModel(
      name: 'Owendo', address: 'Owendo, Libreville', lat: 0.3021, lng: 9.5012),
  PlaceModel(name: 'PK5', address: 'PK5, Libreville', lat: 0.3712, lng: 9.4598),
  PlaceModel(
      name: 'Angondjé',
      address: 'Angondjé, Libreville',
      lat: 0.4201,
      lng: 9.4512),
  PlaceModel(
      name: 'Centre-Ville',
      address: 'Centre-Ville, Libreville',
      lat: 0.3934,
      lng: 9.4567),
  PlaceModel(
      name: 'Marché Mont-Bouët',
      address: 'Marché Mont-Bouët, Libreville',
      lat: 0.3945,
      lng: 9.4534),
  PlaceModel(
      name: 'Hôpital Mère-Enfant',
      address: 'CHU Mère-Enfant, Libreville',
      lat: 0.4013,
      lng: 9.4478),
];

class DeliveryController extends GetxController {
  DeliveryController(this._deliveryService);

  final DeliveryApiService _deliveryService;

  // ─── État ────────────────────────────────────────────────────
  final Rx<DeliveryModel?> currentDelivery = Rx<DeliveryModel?>(null);
  final Rx<DeliveryStatus> status = DeliveryStatus.idle.obs;
  final RxBool isConfirming = false.obs;
  final RxString lastPaymentReference = ''.obs;

  // ─── Champs de saisie ────────────────────────────────────────
  final Rx<PlaceModel?> pickup = Rx<PlaceModel?>(null);
  final Rx<PlaceModel?> dropoff = Rx<PlaceModel?>(null);
  final Rx<ParcelSize> parcelSize = ParcelSize.medium.obs;
  final RxString recipientName = ''.obs;
  final RxString recipientPhone = ''.obs;
  final RxString parcelNote = ''.obs;

  // ─── Recherche de lieu ───────────────────────────────────────
  final RxList<PlaceModel> searchResults = <PlaceModel>[].obs;
  final RxBool isSearching = false.obs;

  Timer? _searchTimer;

  // ─── Validation ──────────────────────────────────────────────
  bool get canEstimate =>
      pickup.value != null &&
      dropoff.value != null &&
      recipientName.value.trim().isNotEmpty &&
      recipientPhone.value.trim().length >= 8;

  // ─────────────────────────────────────────────────────────────
  // Recherche lieu (mock)
  // ─────────────────────────────────────────────────────────────
  Future<void> searchPlace(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }
    isSearching.value = true;
    try {
      final data = await _deliveryService.searchPlaces(query.trim());
      searchResults.value = data
          .map((item) =>
              PlaceModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
      isSearching.value = false;
    } catch (_) {
      _searchPlaceLocally(query);
    }
  }

  void _searchPlaceLocally(String query) {
    Future.delayed(const Duration(milliseconds: 300), () {
      final q = query.toLowerCase();
      searchResults.value = _lieux
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.address.toLowerCase().contains(q))
          .toList();
      isSearching.value = false;
    });
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
  void estimateDelivery() {
    if (!canEstimate) return;

    final dist = pickup.value!.distanceTo(dropoff.value!);
    final prix = max(
      _minimum,
      (_base + dist * _parKm + parcelSize.value.surcharge).round(),
    );
    final prixArrondi = ((prix / 50).round() * 50);
    final duree = max(8, (dist / _vitesse * 60).round());

    currentDelivery.value = DeliveryModel(
      id: _generateId(),
      pickup: pickup.value!,
      dropoff: dropoff.value!,
      recipient: RecipientModel(
        name: recipientName.value.trim(),
        phone: recipientPhone.value.trim(),
      ),
      parcelSize: parcelSize.value,
      parcelNote:
          parcelNote.value.trim().isEmpty ? null : parcelNote.value.trim(),
      distanceKm: dist,
      priceFCFA: prixArrondi,
      estimatedMinutes: duree,
    );
    _syncEstimateWithBackend(dist);

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

    currentDelivery.value =
        currentDelivery.value!.copyWith(status: DeliveryStatus.searching);
    status.value = DeliveryStatus.searching;
    Get.toNamed(Routes.deliverySearching);

    final delay = 4 + Random().nextInt(4);
    _searchTimer = Timer(Duration(seconds: delay), _assignCourier);
  }

  void _assignCourier() {
    if (currentDelivery.value == null) return;
    currentDelivery.value =
        currentDelivery.value!.copyWith(status: DeliveryStatus.assigned);
    status.value = DeliveryStatus.assigned;
    Get.offNamed(Routes.deliveryTracking);
  }

  void completeDelivery() {
    currentDelivery.value =
        currentDelivery.value?.copyWith(status: DeliveryStatus.delivered);
    status.value = DeliveryStatus.delivered;
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
      recipientName.value = '';
      recipientPhone.value = '';
      parcelNote.value = '';
      parcelSize.value = ParcelSize.medium;
      currentDelivery.value = null;
      status.value = DeliveryStatus.idle;
    });
  }

  String _generateId() =>
      DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase();

  Future<void> _syncEstimateWithBackend(double distanceKm) async {
    try {
      final data =
          await _deliveryService.estimate(distanceKm, parcelSize.value.name);
      if (currentDelivery.value == null) return;
      final current = currentDelivery.value!;
      currentDelivery.value = DeliveryModel(
        id: current.id,
        pickup: current.pickup,
        dropoff: current.dropoff,
        recipient: current.recipient,
        parcelSize: current.parcelSize,
        parcelNote: current.parcelNote,
        distanceKm:
            double.tryParse('${data['distance_km'] ?? current.distanceKm}') ??
                current.distanceKm,
        priceFCFA: int.tryParse('${data['price_fcfa'] ?? current.priceFCFA}') ??
            current.priceFCFA,
        estimatedMinutes: int.tryParse(
                '${data['estimated_minutes'] ?? current.estimatedMinutes}') ??
            current.estimatedMinutes,
        status: current.status,
      );
    } catch (_) {
      // L'estimation locale reste affichée si le backend est indisponible.
    }
  }

  Future<bool> _createDeliveryOnBackend() async {
    final delivery = currentDelivery.value;
    if (delivery == null) return false;

    try {
      final data = await _deliveryService.create({
        'pickup_address': delivery.pickup.address,
        'dropoff_address': delivery.dropoff.address,
        'recipient_name': delivery.recipient.name,
        'recipient_phone': delivery.recipient.phone,
        'parcel_size': delivery.parcelSize.name,
        'parcel_note': delivery.parcelNote,
        'distance_km': delivery.distanceKm,
        'payment_method': 'noki_pay',
      });
      lastPaymentReference.value = '${data['payment_reference'] ?? ''}';
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

  @override
  void onClose() {
    _searchTimer?.cancel();
    super.onClose();
  }
}
