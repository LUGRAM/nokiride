import '../api_client.dart';

class OtpApiService {
  OtpApiService({ApiClient? client}) : _client = client ?? ApiClient.instance;
  final ApiClient _client;

  Future<Map<String, dynamic>> send(String phone, String purpose) =>
      _client.post('/otp/send', data: {'phone': phone, 'purpose': purpose});

  Future<Map<String, dynamic>> resend(String phone, String purpose) =>
      _client.post('/otp/resend', data: {'phone': phone, 'purpose': purpose});

  Future<Map<String, dynamic>> verify(
    String phone,
    String purpose,
    String code,
  ) =>
      _client.post('/otp/verify', data: {
        'phone': phone,
        'purpose': purpose,
        'code': code,
      });
}
