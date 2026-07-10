import '../../features/client/trip/model/place_model.dart';

class DriverTrackingService {
  DriverTrackingService._();

  static Stream<PlaceModel> simulateRoute({
    required PlaceModel pickup,
    required PlaceModel dropoff,
    String label = 'Coursier',
    Duration interval = const Duration(seconds: 1),
    int steps = 36,
  }) async* {
    for (var step = 0; step <= steps; step++) {
      final t = step / steps;
      yield PlaceModel(
        name: label,
        address: 'Position en temps réel',
        lat: pickup.lat + ((dropoff.lat - pickup.lat) * t),
        lng: pickup.lng + ((dropoff.lng - pickup.lng) * t),
      );
      await Future<void>.delayed(interval);
    }
  }
}
