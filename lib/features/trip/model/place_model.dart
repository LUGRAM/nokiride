import 'dart:math' as math;

/// Représente un lieu (départ ou arrivée)
class PlaceModel {
  final String name;     // Nom court    ex: "Akanda"
  final String address;  // Adresse complète
  final double lat;
  final double lng;

  const PlaceModel({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
  });

  /// Distance haversine en km entre ce lieu et un autre
  double distanceTo(PlaceModel other) {
    const r = 6371.0;
    final dLat = _rad(other.lat - lat);
    final dLng = _rad(other.lng - lng);
    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(_rad(lat)) *
            math.cos(_rad(other.lat)) *
            math.pow(math.sin(dLng / 2), 2);
    return r * 2 * math.asin(math.sqrt(a));
  }

  static double _rad(double deg) => deg * math.pi / 180;

  @override
  String toString() => '$name ($address)';
}
