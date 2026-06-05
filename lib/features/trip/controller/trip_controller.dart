import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../model/place_model.dart';
import '../model/trip_model.dart';

// ─── Tarification locale ──────────────────────────────────────
const double _tarifBase     = 500;   // F CFA fixe au départ
const double _tarifParKm    = 250;   // F CFA / km
const double _vitesseKmH    = 25;    // vitesse moyenne coursier
const int    _tarifMinimum  = 800;   // prix plancher

enum TripStep { destination, selecting, matching, tracking }

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

  // ─── Flux UX ────────────────────────────────────────────────
  final Rx<TripStep> currentStep = TripStep.destination.obs;
  final RxString selectedServiceId = 'eco'.obs; // eco, premium, delivery

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

  @override
  void onInit() {
    super.onInit();
    // Par défaut, on met la position actuelle à Akanda pour le mock
    pickup.value = _lieuxLibreville[0]; 
  }

  // ─────────────────────────────────────────────────────────────
  // Navigation Flux
  // ─────────────────────────────────────────────────────────────
  void nextStep() {
    HapticFeedback.mediumImpact();
    if (currentStep.value == TripStep.destination) {
      if (canEstimate) {
        _calculatePrice();
        currentStep.value = TripStep.selecting;
      } else {
        Get.snackbar("Oups", "Veuillez sélectionner une destination");
      }
    } else if (currentStep.value == TripStep.selecting) {
      currentStep.value = TripStep.matching;
      confirmTrip();
    }
  }

  void prevStep() {
    if (currentStep.value == TripStep.selecting) currentStep.value = TripStep.destination;
    else if (currentStep.value == TripStep.matching) currentStep.value = TripStep.selecting;
    else Get.back();
  }

  void selectService(String id) {
    HapticFeedback.lightImpact();
    selectedServiceId.value = id;
    _calculatePrice();
  }

  void _calculatePrice() {
    if (!canEstimate) return;
    final dist = pickup.value!.distanceTo(dropoff.value!);
    double multiplier = selectedServiceId.value == 'premium' ? 1.5 : 1.0;
    
    final prix = max(
      _tarifMinimum,
      ((_tarifBase + dist * _tarifParKm) * multiplier).round(),
    );
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
  }

  // ─────────────────────────────────────────────────────────────
  // Recherche de lieu (mock)
  // ─────────────────────────────────────────────────────────────
  void searchPlace(String query) {
    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }
    isSearching.value = true;
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

  void clearPickup()  => pickup.value  = null;
  void clearDropoff() => dropoff.value = null;

  void estimateTrip() => nextStep();

  // ─────────────────────────────────────────────────────────────
  // Confirmation → recherche coursier
  // ─────────────────────────────────────────────────────────────
  void confirmTrip() {
    if (currentTrip.value == null) return;
    status.value = TripStatus.searching;
    final delay = 4 + Random().nextInt(4);
    _searchTimer = Timer(Duration(seconds: delay), _assignDriver);
  }

  void _assignDriver() {
    status.value = TripStatus.assigned;
    currentStep.value = TripStep.tracking;
  }

  void completeTrip() {
    status.value = TripStatus.completed;
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
    pickup.value = _lieuxLibreville[0];
    dropoff.value = null;
    currentTrip.value = null;
    status.value = TripStatus.idle;
  }

  String _generateId() =>
      DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase();

  @override
  void onClose() {
    _searchTimer?.cancel();
    super.onClose();
  }
}
