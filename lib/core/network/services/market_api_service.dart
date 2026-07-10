import '../api_client.dart';

class MarketApiService {
  MarketApiService({ApiClient? client})
      : _client = client ?? ApiClient.instance;
  final ApiClient _client;

  Future<List<dynamic>> merchants() async =>
      (await _client.get('/market/merchants'))['data'] as List<dynamic>;

  Future<List<dynamic>> products(String merchantId) async =>
      (await _client.get('/market/merchants/$merchantId/products'))['data']
          as List<dynamic>;

  Future<Map<String, dynamic>> createOrder({
    required int merchantId,
    required String deliveryAddress,
    required List<Map<String, dynamic>> items,
    String paymentMethod = 'noki_pay',
  }) async {
    final response = await _client.post('/market/orders', data: {
      'merchant_id': merchantId,
      'delivery_address': deliveryAddress,
      'items': items,
      'payment_method': paymentMethod,
    });
    final data = Map<String, dynamic>.from(response['data'] as Map);
    final payment = response['payment'];
    data['payment_reference'] = response['payment_reference'];
    if (payment is Map) {
      data['payment_reference'] ??= payment['reference'];
      data['payment_status'] = payment['status'];
      data['payment'] = Map<String, dynamic>.from(payment);
    }
    return data;
  }
}
