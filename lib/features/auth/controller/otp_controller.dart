import 'dart:async';

import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/network/api_exception.dart';
import '../repository/otp_repository.dart';
import 'auth_controller.dart';

class OtpController extends GetxController {
  OtpController(this._repository, this._authController);

  final OtpRepository _repository;
  final AuthController _authController;
  final RxString code = ''.obs;
  final RxBool isLoading = false.obs;
  final RxInt remainingSeconds = 0.obs;
  final RxInt otpLength = 6.obs;
  Timer? _timer;

  String get phone => _authController.phone.value;

  Future<void> send({bool resend = false}) async {
    isLoading.value = true;
    try {
      final data = resend
          ? await _repository.resend(phone, 'registration')
          : await _repository.send(phone, 'registration');
      otpLength.value = int.tryParse('${data['length']}') ?? 6;
      _startCountdown(DateTime.tryParse('${data['expires_at']}'));
      if (!resend) Get.toNamed(Routes.otp);
    } on ApiException catch (error) {
      Get.snackbar('Erreur', error.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verify() async {
    if (code.value.isEmpty) return;
    isLoading.value = true;
    try {
      final response = await _repository.verify(
        phone,
        'registration',
        code.value,
      );
      final data = Map<String, dynamic>.from(response['data'] as Map);
      await _authController.register(
        otpVerificationToken: data['verification_token'] as String,
      );
    } on ApiException catch (error) {
      Get.snackbar('Erreur', error.message);
    } finally {
      isLoading.value = false;
    }
  }

  void setCode(String value) => code.value = value;

  void _startCountdown(DateTime? expiresAt) {
    _timer?.cancel();
    remainingSeconds.value =
        expiresAt?.difference(DateTime.now()).inSeconds.clamp(0, 3600) ?? 300;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value <= 0) {
        timer.cancel();
      } else {
        remainingSeconds.value--;
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
