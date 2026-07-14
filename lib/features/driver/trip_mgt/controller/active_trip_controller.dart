import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/location/background_location_service.dart';
import '../../../../core/network/api_client.dart';

enum DriverTripStatus {
  accepted,      // En route vers le client
  arrived,       // Arrivé au point de départ
  pickedUp,      // Client récupéré, en route vers destination
  completed      // Course terminée
}

class ActiveTripController extends GetxController {
  final BackgroundLocationService _locationService = Get.find<BackgroundLocationService>();
  
  final Rx<DriverTripStatus> currentStatus = DriverTripStatus.accepted.obs;
  final RxMap<String, dynamic> tripData = <String, dynamic>{}.obs;
  
  GoogleMapController? mapController;
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxSet<Polyline> polylines = <Polyline>{}.obs;
  
  StreamSubscription? _locationSubscription;

  @override
  void onInit() {
    super.onInit();
    // Récupération des données passées en argument lors de la navigation
    if (Get.arguments != null) {
      tripData.value = Map<String, dynamic>.from(Get.arguments);
    }
    
    _initMarkers();
    _listenToLocation();
    _drawItinerary();
  }

  @override
  void onClose() {
    _locationSubscription?.cancel();
    super.onClose();
  }

  /// Initialise les marqueurs (Client/Destination)
  void _initMarkers() {
    markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(
          double.parse(tripData['pickup_latitude'].toString()),
          double.parse(tripData['pickup_longitude'].toString()),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Départ'),
      ),
    );
    
    markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(
          double.parse(tripData['dropoff_latitude'].toString()),
          double.parse(tripData['dropoff_longitude'].toString()),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Arrivée'),
      ),
    );
  }

  /// Écoute la position en temps réel du chauffeur
  void _listenToLocation() {
    _locationSubscription = _locationService.latitude.listen((lat) {
      final lng = _locationService.longitude.value;
      _updateDriverMarker(lat, lng);
    });
  }

  /// Met à jour la position de la voiture sur la carte
  void _updateDriverMarker(double lat, double lng) {
    const markerId = MarkerId('driver');
    
    // Animation fluide vers la nouvelle position
    markers.removeWhere((m) => m.markerId == markerId);
    markers.add(
      Marker(
        markerId: markerId,
        position: LatLng(lat, lng),
        rotation: 0, // Idéalement calculer le cap (heading)
        anchor: const Offset(0.5, 0.5),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );
    
    // Suivre la voiture avec la caméra si nécessaire
    // mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(lat, lng)));
  }

  /// Trace l'itinéraire selon le statut actuel
  Future<void> _drawItinerary() async {
    polylines.clear();
    
    LatLng start;
    LatLng end;

    if (currentStatus.value == DriverTripStatus.accepted) {
      // Du chauffeur vers le client
      start = LatLng(_locationService.latitude.value, _locationService.longitude.value);
      end = LatLng(
        double.parse(tripData['pickup_latitude'].toString()),
        double.parse(tripData['pickup_longitude'].toString()),
      );
    } else {
      // Du client vers la destination
      start = LatLng(
        double.parse(tripData['pickup_latitude'].toString()),
        double.parse(tripData['pickup_longitude'].toString()),
      );
      end = LatLng(
        double.parse(tripData['dropoff_latitude'].toString()),
        double.parse(tripData['dropoff_longitude'].toString()),
      );
    }

    // Ici on devrait normalement appeler l'API Google Directions
    // Pour cet exercice, on trace une ligne droite symbolique
    polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: [start, end],
        color: const Color(0xFF2E7D32),
        width: 5,
      ),
    );
  }

  /// Transition de statut (Action du bouton en bas)
  Future<void> nextStep() async {
    final tripId = tripData['id'];
    String endpoint = '';
    
    switch (currentStatus.value) {
      case DriverTripStatus.accepted:
        endpoint = '/trips/$tripId/arrived';
        break;
      case DriverTripStatus.arrived:
        endpoint = '/trips/$tripId/pickup';
        break;
      case DriverTripStatus.pickedUp:
        endpoint = '/trips/$tripId/complete';
        break;
      case DriverTripStatus.completed:
        return;
    }

    try {
      Get.showOverlay(
        asyncFunction: () async {
          final response = await ApiClient.instance.post(endpoint);
          if (response['status'] == 'success') {
            _advanceStatus();
          }
        },
        loadingWidget: const Center(child: CircularProgressIndicator()),
      );
    } catch (e) {
      Get.snackbar("Erreur", "Impossible de mettre à jour le statut.");
    }
  }

  void _advanceStatus() {
    if (currentStatus.value == DriverTripStatus.accepted) {
      currentStatus.value = DriverTripStatus.arrived;
    } else if (currentStatus.value == DriverTripStatus.arrived) {
      currentStatus.value = DriverTripStatus.pickedUp;
      _drawItinerary(); // On trace maintenant vers la destination
    } else if (currentStatus.value == DriverTripStatus.pickedUp) {
      currentStatus.value = DriverTripStatus.completed;
      Get.offAllNamed('/driver/dashboard'); // Fin de course
      Get.snackbar("Félicitations", "Course terminée avec succès !");
    }
  }

  String get actionButtonText {
    switch (currentStatus.value) {
      case DriverTripStatus.accepted: return "JE SUIS ARRIVÉ";
      case DriverTripStatus.arrived: return "CLIENT RÉCUPÉRÉ";
      case DriverTripStatus.pickedUp: return "TERMINER LA COURSE";
      case DriverTripStatus.completed: return "TERMINÉ";
    }
  }

  String get instructionText {
    switch (currentStatus.value) {
      case DriverTripStatus.accepted: return "Allez chercher le client";
      case DriverTripStatus.arrived: return "Le client vous attend";
      case DriverTripStatus.pickedUp: return "En route vers la destination";
      case DriverTripStatus.completed: return "Course terminée";
    }
  }
}
