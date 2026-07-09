import '../api_client.dart';

class PaymentApiService {
  PaymentApiService({ApiClient? client})
      : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<Map<String, dynamic>> initiate({
    required int amountFcfa,
    required String purpose,
    String method = 'noki_pay',
  }) async =>
      Map<String, dynamic>.from(
        (await _client.post('/payments/initiate', data: {
          'amount_fcfa': amountFcfa,
          'purpose': purpose,
          'method': method,
        }))['data'] as Map,
      );

  Future<Map<String, dynamic>> show(int paymentId) async =>
      Map<String, dynamic>.from(
        (await _client.get('/payments/$paymentId'))['data'] as Map,
      );

  Future<Map<String, dynamic>> confirm(int paymentId) async =>
      Map<String, dynamic>.from(
        (await _client.post('/payments/$paymentId/confirm'))['data'] as Map,
      );
}
