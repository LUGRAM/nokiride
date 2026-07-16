import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nokiride/core/navigation/route_geometry.dart';

void main() {
  const route = <LatLng>[
    LatLng(0.3900, 9.4500),
    LatLng(0.3900, 9.4600),
  ];

  test('une position sur le segment a une déviation quasi nulle', () {
    final distance = RouteGeometry.distanceToRouteMeters(
      const LatLng(0.3900, 9.4550),
      route,
    );
    expect(distance, lessThan(1));
  });

  test('détecte une déviation supérieure à 100 mètres', () {
    final distance = RouteGeometry.distanceToRouteMeters(
      const LatLng(0.3920, 9.4550),
      route,
    );
    expect(distance, greaterThan(200));
  });

  test('mesure aussi la distance après la fin du segment', () {
    final distance = RouteGeometry.distanceToRouteMeters(
      const LatLng(0.3900, 9.4620),
      route,
    );
    expect(distance, greaterThan(200));
  });
}
