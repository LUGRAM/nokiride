import '../api_client.dart';

class DeliveryApiService {
  DeliveryApiService({ApiClient? client})
      : _client = client ?? ApiClient.instance;
  final ApiClient _client;

  Future<List<dynamic>> searchPlaces(String query) async =>
      (await _client.get('/places', queryParameters: {'q': query}))['data']
          as List<dynamic>;

  Future<Map<String, dynamic>> estimate(
          double distanceKm, String parcelSize) async =>
      Map<String, dynamic>.from(
          (await _client.post('/deliveries/estimate', data: {
        'distance_km': distanceKm,
        'parcel_size': parcelSize,
      }))['data'] as Map);

  Future<Map<String, dynamic>> create(Map<String, dynamic> payload) async {
    final response = await _client.post('/deliveries', data: {
      ...payload,
      'payment_method': payload['payment_method'] ?? 'noki_pay',
    });
    final data = Map<String, dynamic>.from(response['data'] as Map);
    final payment = response['payment'];
    if (payment is Map) {
      data['payment_reference'] = payment['reference'];
      data['payment_status'] = payment['status'];
    }
    return data;
  }

  Future<Map<String, dynamic>> updateStatus(int id, String status) async =>
      Map<String, dynamic>.from((await _client.patch('/deliveries/$id/status',
          data: {'status': status}))['data'] as Map);
}
