import 'package:get/get.dart';
import '../../../core/network/services/auth_api_service.dart';
import '../controller/history_controller.dart';

class HistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthApiService>(() => AuthApiService());
    Get.lazyPut<HistoryController>(() => HistoryController(Get.find()));
  }
}
