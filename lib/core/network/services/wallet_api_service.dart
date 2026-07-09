import '../api_client.dart';

class WalletApiService {
  WalletApiService({ApiClient? client})
      : _client = client ?? ApiClient.instance;
  final ApiClient _client;

  Future<Map<String, dynamic>> show() => _client.get('/wallet');

  Future<Map<String, dynamic>> requestRecharge(int amount, String method) =>
      _client.post('/wallet/recharge', data: {
        'amount_fcfa': amount,
        'method': method,
      });
}
