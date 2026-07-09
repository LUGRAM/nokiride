import 'package:get/get.dart';
import '../../../core/network/services/auth_api_service.dart';
import '../controller/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthApiService>(() => AuthApiService(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(Get.find()));
  }
}
