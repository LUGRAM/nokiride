import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../features/client/trip/model/place_model.dart';

class LocationService {
  LocationService._();

  /// Récupère la position actuelle avec gestion d'erreurs et fallback.
  static Future<Position?> currentPosition() async {
    try {
      // 1. Vérifier si le service est activé
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return null;
      }

      // 2. Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied.');
        return null;
      }

      // 3. Tenter de récupérer la dernière position connue (plus rapide)
      final lastKnown = await Geolocator.getLastKnownPosition();

      // 4. Récupérer la position précise
      // On utilise un timeout pour éviter d'attendre indéfiniment
      try {
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );
      } catch (e) {
        debugPrint('Error getting current position: $e');
        return lastKnown; // Fallback sur la dernière position connue en cas d'erreur
      }
    } catch (e) {
      debugPrint('Exception in LocationService: $e');
      return null;
    }
  }

  /// Stream pour suivre la position en temps réel (ex: pour le trajet)
  static Stream<Position> get positionStream {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update tous les 10 mètres
    );
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  static Stream<PlaceModel> placeStream({
    String name = 'Position actuelle',
    String address = 'Votre position GPS',
  }) async* {
    final current = await currentPosition();
    if (current == null) return;
    yield PlaceModel(
      name: name,
      address: address,
      lat: current.latitude,
      lng: current.longitude,
    );

    await for (final position in positionStream.handleError((_) {})) {
      yield PlaceModel(
        name: name,
        address: address,
        lat: position.latitude,
        lng: position.longitude,
      );
    }
  }

  /// Ouvre les paramètres de l'application (utile si permission deniedForever)
  static Future<bool> openSettings() async {
    return await Geolocator.openAppSettings();
  }
}
