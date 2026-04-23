import 'dart:async';
import 'dart:math';

import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../model/place_model.dart';
import '../model/trip_model.dart';

// ─── Tarification locale ──────────────────────────────────────
const double _tarifBase     = 500;   // F CFA fixe au départ
const double _tarifParKm    = 250;   // F CFA / km
const double _vitesseKmH    = 25;    // vitesse moyenne coursier
const int    _tarifMinimum  = 800;   // prix plancher

/// Lieux prédéfinis à Libreville pour la recherche mock
const _lieuxLibreville = [
  PlaceModel(name: 'Akanda',           address: 'Quartier Akanda, Libreville',              lat: 0.4477,  lng: 9.4321),
  PlaceModel(name: 'Charbonnages',     address: 'Quartier Charbonnages, Libreville',        lat: 0.3875,  lng: 9.4523),
  PlaceModel(name: 'Batterie IV',      address: 'Batterie IV, Libreville',                  lat: 0.3812,  lng: 9.4502),
  PlaceModel(name: 'Nzeng-Ayong',      address: 'Nzeng-Ayong, Libreville',                  lat: 0.3761,  lng: 9.4689),
  PlaceModel(name: 'Glass',            address: 'Quartier Glass, Libreville',               lat: 0.3906,  lng: 9.4441),
  PlaceModel(name: 'Louis',            address: 'Quartier Louis, Libreville',               lat: 0.3847,  lng: 9.4378),
  PlaceModel(name: 'Nombakélé',        address: 'Nombakélé, Libreville',                   lat: 0.4021,  lng: 9.4612),
  PlaceModel(name: 'Owendo',           address: 'Owendo, Libreville',                       lat: 0.3021,  lng: 9.5012),
  PlaceModel(name: 'PK5',              address: 'PK5, Libreville',                          lat: 0.3712,  lng: 9.4598),
  PlaceModel(name: 'PK8',              address: 'PK8, Libreville',                          lat: 0.3523,  lng: 9.4701),
  PlaceModel(name: 'Angondjé',         address: 'Angondjé, Libreville',                     lat: 0.4201,  lng: 9.4512),
  PlaceModel(name: 'Centre-Ville',     address: 'Centre-Ville, Libreville',                 lat: 0.3934,  lng: 9.4567),
  PlaceModel(name: 'Awendjé',          address: 'Awendjé, Libreville',                      lat: 0.4102,  lng: 9.4423),
  PlaceModel(name: 'Cocotiers',        address: 'Quartier des Cocotiers, Libreville',       lat: 0.3989,  lng: 9.4489),
  PlaceModel(name: 'IAI Gabon',        address: 'Institut Africain d\'Informatique, Lb',   lat: 0.3901,  lng: 9.4612),
  PlaceModel(name: 'SETRAG',           address: 'SETRAG, Owendo',                           lat: 0.2989,  lng: 9.5112),
  PlaceModel(name: 'Marché Mont-Bouët',address: 'Marché Mont-Bouët, Libreville',            lat: 0.3945,  lng: 9.4534),
  PlaceModel(name: 'Hôpital Mère-Enfant', address: 'CHU Mère-Enfant, Libreville',          lat: 0.4013,  lng: 9.4478),
];

class TripController extends GetxController {

  // ─── État de la course ──────────────────────────────────────
  final Rx<TripModel?>    currentTrip = Rx<TripModel?>(null);
  final Rx<TripStatus>    status      = TripStatus.idle.obs;

  // ─── Champs de saisie ───────────────────────────────────────
  final Rx<PlaceModel?>   pickup      = Rx<PlaceModel?>(null);
  final Rx<PlaceModel?>   dropoff     = Rx<PlaceModel?>(null);

  // ─── Recherche de lieu ──────────────────────────────────────
  final RxList<PlaceModel> searchResults = <PlaceModel>[].obs;
  final RxBool             isSearching   = false.obs;

  // ─── Timer de simulation ────────────────────────────────────
  Timer? _searchTimer;

  // ─── Getters ────────────────────────────────────────────────
  bool get canEstimate => pickup.value != null && dropoff.value != null;

  // ─────────────────────────────────────────────────────────────
  // Recherche de lieu (mock)
  // ─────────────────────────────────────────────────────────────
  void searchPlace(String query) {
    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }
    isSearching.value = true;

    // Simule un délai réseau
    Future.delayed(const Duration(milliseconds: 300), () {
      final q = query.toLowerCase().trim();
      searchResults.value = _lieuxLibreville
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.address.toLowerCase().contains(q))
          .toList();
      isSearching.value = false;
    });
  }

  void clearSearch() => searchResults.clear();

  // ─────────────────────────────────────────────────────────────
  // Sélection d'un lieu
  // ─────────────────────────────────────────────────────────────
  void selectPickup(PlaceModel place) {
    pickup.value = place;
    searchResults.clear();
  }

  void selectDropoff(PlaceModel place) {
    dropoff.value = place;
    searchResults.clear();
  }

  void clearPickup()  => pickup.value  = null;
  void clearDropoff() => dropoff.value = null;

  // ─────────────────────────────────────────────────────────────
  // Estimation du prix
  // ─────────────────────────────────────────────────────────────
  void estimateTrip() {
    if (!canEstimate) return;

    final dist = pickup.value!.distanceTo(dropoff.value!);
    final prix = max(
      _tarifMinimum,
      (_tarifBase + dist * _tarifParKm).round(),
    );
    // Arrondi au 50 F le plus proche
    final prixArrondi = ((prix / 50).round() * 50);

    final duree = max(5, (dist / _vitesseKmH * 60).round());

    currentTrip.value = TripModel(
      id:               _generateId(),
      pickup:           pickup.value!,
      dropoff:          dropoff.value!,
      distanceKm:       dist,
      priceFCFA:        prixArrondi,
      estimatedMinutes: duree,
      status:           TripStatus.estimating,
    );

    Get.toNamed(Routes.tripEstimate);
  }

  // ─────────────────────────────────────────────────────────────
  // Confirmation → recherche coursier
  // ─────────────────────────────────────────────────────────────
  void confirmTrip() {
    if (currentTrip.value == null) return;

    currentTrip.value = currentTrip.value!.copyWith(
      status: TripStatus.searching,
    );
    status.value = TripStatus.searching;

    Get.toNamed(Routes.tripSearching);

    // Simule la trouvaille d'un coursier après 4–7s
    final delay = 4 + Random().nextInt(4);
    _searchTimer = Timer(Duration(seconds: delay), _assignDriver);
  }

  // ─────────────────────────────────────────────────────────────
  // Coursier trouvé (simulation)
  // ─────────────────────────────────────────────────────────────
  void _assignDriver() {
    if (currentTrip.value == null) return;

    currentTrip.value = currentTrip.value!.copyWith(
      status: TripStatus.assigned,
    );
    status.value = TripStatus.assigned;

    Get.offNamed(Routes.tripTracking);
  }

  // ─────────────────────────────────────────────────────────────
  // Fin de course
  // ─────────────────────────────────────────────────────────────
  void completeTrip() {
    currentTrip.value = currentTrip.value?.copyWith(
      status: TripStatus.completed,
    );
    status.value = TripStatus.completed;
    _reset();
    Get.offAllNamed(Routes.home);
  }

  void cancelTrip() {
    _searchTimer?.cancel();
    currentTrip.value = currentTrip.value?.copyWith(
      status: TripStatus.cancelled,
    );
    status.value = TripStatus.cancelled;
    _reset();
    Get.offAllNamed(Routes.home);
  }

  void _reset() {
    Future.delayed(const Duration(seconds: 1), () {
      pickup.value       = null;
      dropoff.value      = null;
      currentTrip.value  = null;
      status.value       = TripStatus.idle;
    });
  }

  String _generateId() =>
      DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase();

  @override
  void onClose() {
    _searchTimer?.cancel();
    super.onClose();
  }
}
