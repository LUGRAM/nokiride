import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/routes/app_routes.dart';

class AuthController extends GetxController {
  final _box = GetStorage();
  final RxString phone = ''.obs;
  final RxString otp = ''.obs;
  final RxString name = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool otpSent = false.obs;
  static const String _mockOtp = '1234';

  void setPhone(String v) => phone.value = v;
  void setOtp(String v) => otp.value = v;
  void setName(String v) => name.value = v;

  Future<void> sendOtp() async {
    if (phone.value.length < 8) return;
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;
    otpSent.value = true;
    Get.toNamed(Routes.otp);
  }

  Future<void> verifyOtp() async {
    if (otp.value.length != 4) return;
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isLoading.value = false;
    if (otp.value == _mockOtp) {
      final isNew = _box.read('user_name') == null;
      if (isNew) {
        Get.toNamed(Routes.register);
      } else {
        _box.write('auth_token', 'mock_token_${phone.value}');
        Get.offAllNamed(Routes.home);
      }
    } else {
      Get.snackbar('Erreur', 'Code incorrect. Essayez 1234', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> register() async {
    if (name.value.trim().isEmpty) return;
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    _box.write('user_name', name.value.trim());
    _box.write('user_phone', phone.value);
    _box.write('auth_token', 'mock_token_${phone.value}');
    isLoading.value = false;
    Get.offAllNamed(Routes.home);
  }

  void logout() {
    _box.remove('auth_token');
    Get.offAllNamed(Routes.login);
  }
}
