import 'package:get/get.dart';
import '../../../core/network/services/trip_api_service.dart';
import '../controller/trip_controller.dart';

class TripBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TripApiService>(() => TripApiService(), fenix: true);
    Get.lazyPut<TripController>(() => TripController(Get.find()), fenix: true);
  }
}
