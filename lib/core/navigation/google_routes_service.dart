import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../network/api_client.dart';
import '../utils/polyline_decoder.dart';

class NavigationRoute {
  const NavigationRoute({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  final List<LatLng> points;
  final int distanceMeters;
  final int durationSeconds;
}

class GoogleRoutesService {
  const GoogleRoutesService();

  Future<NavigationRoute> route({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final response = await ApiClient.instance.post('/navigation/route', data: {
      'origin': {
        'latitude': origin.latitude,
        'longitude': origin.longitude,
      },
      'destination': {
        'latitude': destination.latitude,
        'longitude': destination.longitude,
      },
    });

    final data = Map<String, dynamic>.from(response['data'] as Map);
    final encoded = data['encoded_polyline']?.toString() ?? '';
    final points = PolylineDecoder.decodePolyline(encoded);
    if (points.length < 2) {
      throw const FormatException('Polyline Google Routes invalide.');
    }

    return NavigationRoute(
      points: points,
      distanceMeters: int.tryParse('${data['distance_meters']}') ?? 0,
      durationSeconds: int.tryParse('${data['duration_seconds']}') ?? 0,
    );
  }
}
