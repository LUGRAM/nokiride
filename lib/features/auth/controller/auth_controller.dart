import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/services/auth_api_service.dart';
import '../../../core/storage/app_storage.dart';

class AuthController extends GetxController {
  AuthController(this._authService);

  final AuthApiService _authService;
  final RxString phone = ''.obs;
  final RxString name = ''.obs;
  final RxString password = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString lastError = ''.obs;
  static final RegExp _gabonPhonePattern = RegExp(r'^\+241\d{8}$');

  void setPhone(String v) => phone.value = v;
  void setName(String v) => name.value = v;
  void setPassword(String v) => password.value = v;

  Future<bool> login(String phoneVal, String password) async {
    if (!_gabonPhonePattern.hasMatch(phoneVal) || password.isEmpty) {
      return false;
    }

    isLoading.value = true;
    lastError.value = '';
    try {
      final data = await _authService.login(phoneVal, password);
      await AppStorage.saveAuth(
        token: data['token'] as String,
        user: Map<String, dynamic>.from(data['user'] as Map),
      );
      return true;
    } on ApiException catch (error) {
      lastError.value = error.message;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register({required String otpVerificationToken}) async {
    if (name.value.trim().isEmpty) return;
    isLoading.value = true;
    lastError.value = '';
    try {
      final data = await _authService.register(
        name: name.value.trim(),
        phone: phone.value.trim(),
        password: password.value,
        otpVerificationToken: otpVerificationToken,
      );
      await AppStorage.saveAuth(
        token: data['token'] as String,
        user: Map<String, dynamic>.from(data['user'] as Map),
      );
      Get.offAllNamed(Routes.home);
    } on ApiException catch (error) {
      lastError.value = error.message;
      Get.snackbar('Erreur', error.message,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } on ApiException {
      // La session locale doit être supprimée même si le serveur est indisponible.
    }
    await AppStorage.clearAuth();
    Get.offAllNamed(Routes.login);
  }
}
