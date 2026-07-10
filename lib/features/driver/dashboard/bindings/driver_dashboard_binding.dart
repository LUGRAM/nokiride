import 'package:get/get.dart';

import '../../../../core/network/services/trip_api_service.dart';
import '../../../../core/network/services/auth_api_service.dart';
import '../../../auth/controller/auth_controller.dart';
import '../../earnings/service/driver_history_service.dart';
import '../../trip_mgt/controller/driver_trip_controller.dart';
import '../controller/driver_dashboard_controller.dart';

class DriverDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverDashboardController>(
      () => DriverDashboardController(),
      fenix: true,
    );
    Get.lazyPut<AuthApiService>(() => AuthApiService(), fenix: true);
    Get.lazyPut<AuthController>(() => AuthController(Get.find()), fenix: true);
    Get.lazyPut<TripApiService>(() => TripApiService(), fenix: true);
    Get.lazyPut<DriverHistoryService>(() => DriverHistoryService(),
        fenix: true);
    Get.lazyPut<DriverTripController>(
      () => DriverTripController(Get.find(), Get.find(), Get.find()),
      fenix: true,
    );
  }
}
