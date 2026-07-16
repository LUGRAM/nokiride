import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteGeometry {
  const RouteGeometry._();

  static double distanceToRouteMeters(LatLng point, List<LatLng> route) {
    if (route.isEmpty) return double.infinity;
    if (route.length == 1) {
      return _distanceToSegmentMeters(point, route.first, route.first);
    }

    var minimum = double.infinity;
    for (var index = 0; index < route.length - 1; index++) {
      minimum = math.min(
        minimum,
        _distanceToSegmentMeters(point, route[index], route[index + 1]),
      );
    }
    return minimum;
  }

  static double _distanceToSegmentMeters(
    LatLng point,
    LatLng start,
    LatLng end,
  ) {
    const earthRadius = 6371000.0;
    final referenceLatitude = point.latitude * math.pi / 180;
    double x(LatLng value) =>
        value.longitude *
        math.pi /
        180 *
        math.cos(referenceLatitude) *
        earthRadius;
    double y(LatLng value) => value.latitude * math.pi / 180 * earthRadius;
    final px = x(point);
    final py = y(point);
    final ax = x(start);
    final ay = y(start);
    final bx = x(end);
    final by = y(end);
    final dx = bx - ax;
    final dy = by - ay;
    if (dx == 0 && dy == 0) {
      return math.sqrt(math.pow(px - ax, 2) + math.pow(py - ay, 2));
    }
    final projection = ((px - ax) * dx + (py - ay) * dy) / (dx * dx + dy * dy);
    final t = projection.clamp(0.0, 1.0);
    return math.sqrt(
      math.pow(px - (ax + t * dx), 2) + math.pow(py - (ay + t * dy), 2),
    );
  }
}
