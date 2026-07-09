import 'package:get/get.dart';
import '../../../core/network/services/delivery_api_service.dart';
import '../controller/delivery_controller.dart';

class DeliveryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryApiService>(() => DeliveryApiService(), fenix: true);
    Get.lazyPut<DeliveryController>(() => DeliveryController(Get.find()),
        fenix: true);
  }
}
