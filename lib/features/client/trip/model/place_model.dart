import 'dart:math' as math;

/// Représente un lieu (départ ou arrivée)
class PlaceModel {
  final String name; // Nom court    ex: "Akanda"
  final String address; // Adresse complète
  final double lat;
  final double lng;

  const PlaceModel({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'];
    final location = geometry is Map ? geometry['location'] : json['location'];
    final locationMap =
        location is Map ? Map<String, dynamic>.from(location) : null;

    return PlaceModel(
      name:
          '${json['name'] ?? json['structured_formatting']?['main_text'] ?? ''}',
      address:
          '${json['address'] ?? json['formatted_address'] ?? json['description'] ?? json['vicinity'] ?? ''}',
      lat: _doubleValue(
        json['latitude'] ??
            json['lat'] ??
            locationMap?['lat'] ??
            locationMap?['latitude'],
      ),
      lng: _doubleValue(
        json['longitude'] ??
            json['lng'] ??
            locationMap?['lng'] ??
            locationMap?['longitude'],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'latitude': lat,
        'longitude': lng,
      };

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

  static double _doubleValue(dynamic value) => double.tryParse('$value') ?? 0;

  @override
  String toString() => '$name ($address)';
}
