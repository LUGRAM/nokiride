import 'package:google_maps_flutter/google_maps_flutter.dart';

class PolylineDecoder {
  const PolylineDecoder._();

  static List<LatLng> decodePolyline(String encoded) {
    if (encoded.isEmpty) return const <LatLng>[];

    final points = <LatLng>[];
    var index = 0;
    var latitude = 0;
    var longitude = 0;

    while (index < encoded.length) {
      final latitudeChunk = _decodeChunk(encoded, index);
      index = latitudeChunk.nextIndex;
      latitude += latitudeChunk.delta;

      if (index >= encoded.length) {
        throw const FormatException('Polyline tronquée après la latitude.');
      }

      final longitudeChunk = _decodeChunk(encoded, index);
      index = longitudeChunk.nextIndex;
      longitude += longitudeChunk.delta;
      points.add(LatLng(latitude / 1e5, longitude / 1e5));
    }

    return points;
  }

  static ({int delta, int nextIndex}) _decodeChunk(
    String encoded,
    int startIndex,
  ) {
    var index = startIndex;
    var shift = 0;
    var result = 0;
    int byte;

    do {
      if (index >= encoded.length || shift > 30) {
        throw const FormatException('Polyline Google invalide.');
      }
      byte = encoded.codeUnitAt(index++) - 63;
      if (byte < 0 || byte > 63) {
        throw const FormatException('Polyline Google invalide.');
      }
      result |= (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20);

    final delta = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
    return (delta: delta, nextIndex: index);
  }
}
