import 'package:get/get.dart';
import '../../../core/network/services/market_api_service.dart';
import '../controller/market_controller.dart';

class MarketBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MarketApiService>(() => MarketApiService(), fenix: true);
    Get.lazyPut<MarketController>(() => MarketController(Get.find()));
  }
}
