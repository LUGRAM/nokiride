import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/services/auth_api_service.dart';
import '../repository/otp_repository.dart';

enum PasswordResetStep { phone, otp, password }

class PasswordResetController extends GetxController {
  PasswordResetController(this._authService, this._otpRepository);

  final AuthApiService _authService;
  final OtpRepository _otpRepository;
  final Rx<PasswordResetStep> step = PasswordResetStep.phone.obs;
  final RxBool isLoading = false.obs;
  final RxString phone = ''.obs;
  final RxString code = ''.obs;
  String? _verificationToken;

  Future<void> requestOtp(String value) async {
    phone.value = value;
    await _run(() async {
      await _authService.forgotPassword(value);
      step.value = PasswordResetStep.otp;
    });
  }

  Future<void> verifyOtp(String value) async {
    code.value = value;
    await _run(() async {
      final response = await _otpRepository.verify(
        phone.value,
        'password_reset',
        value,
      );
      final data = Map<String, dynamic>.from(response['data'] as Map);
      _verificationToken = data['verification_token'] as String;
      step.value = PasswordResetStep.password;
    });
  }

  Future<void> resetPassword(String password) async {
    await _run(() async {
      await _authService.resetPassword(
        phone: phone.value,
        password: password,
        verificationToken: _verificationToken!,
      );
      Get.snackbar('Succès', 'Mot de passe mis à jour.');
      Get.offAllNamed(Routes.login);
    });
  }

  Future<void> _run(Future<void> Function() operation) async {
    isLoading.value = true;
    try {
      await operation();
    } on ApiException catch (error) {
      Get.snackbar('Erreur', error.message);
    } finally {
      isLoading.value = false;
    }
  }
}
