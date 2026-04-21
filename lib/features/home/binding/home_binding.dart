import 'package:get/get.dart';

import '../controller/home_controller.dart';

/// Bindings injectés au démarrage de l'app (avant le premier écran).
class HomeBinding extends Bindings {
  @override
  void dependencies() {

    Get.lazyPut<HomeController>(
          () => HomeController(),
      fenix: true,
    );
    // Services globaux permanents
    // Get.put<NetworkManager>(NetworkManager(), permanent: true);
    // AppStorage déjà initialisé dans main.dart via await
  }
}