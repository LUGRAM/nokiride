import 'package:flutter_test/flutter_test.dart';
import 'package:nokiride/core/utils/polyline_decoder.dart';

void main() {
  test('decode la polyline Google de référence', () {
    final points = PolylineDecoder.decodePolyline(
      '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
    );

    expect(points, hasLength(3));
    expect(points[0].latitude, closeTo(38.5, 0.00001));
    expect(points[0].longitude, closeTo(-120.2, 0.00001));
    expect(points[2].latitude, closeTo(43.252, 0.00001));
    expect(points[2].longitude, closeTo(-126.453, 0.00001));
  });

  test('rejette une polyline tronquée', () {
    expect(
      () => PolylineDecoder.decodePolyline('_p~iF'),
      throwsFormatException,
    );
  });

  test('retourne une liste vide pour une polyline vide', () {
    expect(PolylineDecoder.decodePolyline(''), isEmpty);
  });

  test('rejette les caractères hors de l’alphabet Google', () {
    expect(
      () => PolylineDecoder.decodePolyline('!!'),
      throwsFormatException,
    );
  });
}
