import 'place_model.dart';

enum TripStatus {
  idle,        // Pas de course active
  estimating,  // Calcul du prix en cours
  searching,   // Recherche coursier
  assigned,    // Coursier trouvé
  inProgress,  // Course en cours
  completed,   // Terminée
  cancelled,   // Annulée
}

class TripModel {
  final String     id;
  final PlaceModel pickup;
  final PlaceModel dropoff;
  final double     distanceKm;
  final int        priceFCFA;
  final int        estimatedMinutes;
  final TripStatus status;

  const TripModel({
    required this.id,
    required this.pickup,
    required this.dropoff,
    required this.distanceKm,
    required this.priceFCFA,
    required this.estimatedMinutes,
    this.status = TripStatus.idle,
  });

  TripModel copyWith({TripStatus? status}) => TripModel(
        id:               id,
        pickup:           pickup,
        dropoff:          dropoff,
        distanceKm:       distanceKm,
        priceFCFA:        priceFCFA,
        estimatedMinutes: estimatedMinutes,
        status:           status ?? this.status,
      );

  /// "2 500 F CFA"
  String get formattedPrice {
    final s = priceFCFA.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    );
    return '$s F CFA';
  }

  /// "4,2 km"
  String get formattedDistance =>
      '${distanceKm.toStringAsFixed(1).replaceAll('.', ',')} km';

  /// "~18 min"
  String get formattedDuration => '~$estimatedMinutes min';
}
