import '../../../core/network/services/otp_api_service.dart';

class OtpRepository {
  OtpRepository(this._service);
  final OtpApiService _service;

  Future<Map<String, dynamic>> send(String phone, String purpose) =>
      _service.send(phone, purpose);

  Future<Map<String, dynamic>> resend(String phone, String purpose) =>
      _service.resend(phone, purpose);

  Future<Map<String, dynamic>> verify(
    String phone,
    String purpose,
    String code,
  ) =>
      _service.verify(phone, purpose, code);
}
