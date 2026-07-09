import 'package:get/get.dart';
import '../../../core/network/services/auth_api_service.dart';
import '../../../core/network/services/otp_api_service.dart';
import '../controller/auth_controller.dart';
import '../controller/otp_controller.dart';
import '../controller/password_reset_controller.dart';
import '../repository/otp_repository.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthApiService>(() => AuthApiService(), fenix: true);
    Get.lazyPut<AuthController>(() => AuthController(Get.find()), fenix: true);
    Get.lazyPut<OtpApiService>(() => OtpApiService(), fenix: true);
    Get.lazyPut<OtpRepository>(() => OtpRepository(Get.find()), fenix: true);
    Get.lazyPut<OtpController>(
      () => OtpController(Get.find(), Get.find()),
      fenix: true,
    );
    Get.lazyPut<PasswordResetController>(
      () => PasswordResetController(Get.find(), Get.find()),
      fenix: true,
    );
  }
}
