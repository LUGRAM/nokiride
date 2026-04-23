import 'package:get/get.dart';
import '../controller/delivery_controller.dart';

class DeliveryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryController>(() => DeliveryController(), fenix: true);
  }
}