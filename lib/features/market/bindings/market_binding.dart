import 'package:get/get.dart';
import '../controller/market_controller.dart';
class MarketBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<MarketController>(() => MarketController());
}
