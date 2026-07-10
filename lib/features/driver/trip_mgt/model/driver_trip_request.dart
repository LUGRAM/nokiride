import '../../../client/trip/model/place_model.dart';

enum DriverTripStage {
  idle,
  requestReceived,
  goingToPickup,
  arrivedAtPickup,
  inProgress,
  completed,
}

class DriverTripRequest {
  const DriverTripRequest({
    required this.id,
    required this.passengerName,
    required this.pickup,
    required this.dropoff,
    required this.distanceKm,
    required this.priceFCFA,
  });

  final String id;
  final String passengerName;
  final PlaceModel pickup;
  final PlaceModel dropoff;
  final double distanceKm;
  final int priceFCFA;

  String get formattedPrice {
    final value = priceFCFA.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]} ',
        );
    return '$value FCFA';
  }

  String get formattedDistance =>
      '${distanceKm.toStringAsFixed(1).replaceAll('.', ',')} km';
}
