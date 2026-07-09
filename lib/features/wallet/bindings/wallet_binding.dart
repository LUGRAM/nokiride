import 'package:get/get.dart';
import '../../../core/network/services/wallet_api_service.dart';
import '../controller/wallet_controller.dart';

class WalletBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalletApiService>(() => WalletApiService(), fenix: true);
    Get.lazyPut<WalletController>(() => WalletController(Get.find()));
  }
}
