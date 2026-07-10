import '../../features/client/trip/model/place_model.dart';
import '../network/api_client.dart';

abstract class PlaceProvider {
  Future<List<PlaceModel>> search(String query);
}

class BackendPlaceProvider implements PlaceProvider {
  BackendPlaceProvider({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  @override
  Future<List<PlaceModel>> search(String query) async {
    final response =
        await _client.get('/places', queryParameters: {'q': query});
    final data = response['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((item) => PlaceModel.fromJson(Map<String, dynamic>.from(item)))
        .where((place) => place.lat != 0 || place.lng != 0)
        .toList();
  }
}

class MockPlaceProvider implements PlaceProvider {
  const MockPlaceProvider(this.places);

  final List<PlaceModel> places;

  @override
  Future<List<PlaceModel>> search(String query) async {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return const [];
    return places
        .where((place) =>
            place.name.toLowerCase().contains(q) ||
            place.address.toLowerCase().contains(q))
        .toList();
  }
}

class FallbackPlaceProvider implements PlaceProvider {
  const FallbackPlaceProvider({
    required this.primary,
    required this.fallback,
  });

  final PlaceProvider primary;
  final PlaceProvider fallback;

  @override
  Future<List<PlaceModel>> search(String query) async {
    try {
      final results = await primary.search(query);
      if (results.isNotEmpty) return results;
    } catch (_) {
      // Le fallback local garde la recherche utilisable hors ligne.
    }
    return fallback.search(query);
  }
}
