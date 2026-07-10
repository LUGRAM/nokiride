import 'dart:async';

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

  Future<Map<String, dynamic>> pollUntilPaid(
    int paymentId, {
    Duration interval = const Duration(seconds: 2),
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final startedAt = DateTime.now();
    while (DateTime.now().difference(startedAt) < timeout) {
      final payment = await show(paymentId);
      if (payment['status'] == 'paid' || payment['status'] == 'failed') {
        return payment;
      }
      await Future<void>.delayed(interval);
    }
    throw TimeoutException('Paiement toujours en attente.');
  }
}
