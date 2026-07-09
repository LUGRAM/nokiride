import '../api_client.dart';

class AuthApiService {
  AuthApiService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<Map<String, dynamic>> login(String phone, String password) =>
      _client.post('/auth/login', data: {'phone': phone, 'password': password});

  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String password,
    required String otpVerificationToken,
  }) =>
      _client.post('/auth/register', data: {
        'name': name,
        'phone': phone,
        'password': password,
        'otp_verification_token': otpVerificationToken,
      });

  Future<Map<String, dynamic>> me() => _client.get('/auth/me');

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String phone,
    String? email,
  }) =>
      _client.patch('/auth/profile', data: {
        'name': name,
        'phone': phone,
        'email': email,
      });

  Future<Map<String, dynamic>> stats() => _client.get('/auth/stats');

  Future<void> logout() async {
    await _client.post('/auth/logout');
  }

  Future<Map<String, dynamic>> forgotPassword(String phone) =>
      _client.post('/auth/password/forgot', data: {'phone': phone});

  Future<void> resetPassword({
    required String phone,
    required String password,
    required String verificationToken,
  }) async {
    await _client.post('/auth/password/reset', data: {
      'phone': phone,
      'password': password,
      'password_confirmation': password,
      'otp_verification_token': verificationToken,
    });
  }
}
