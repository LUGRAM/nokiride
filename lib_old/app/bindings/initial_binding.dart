import 'package:get/get.dart';
import '../../core/network/network_manager.dart';
import '../../core/storage/app_storage.dart';
import '../services/theme_service.dart';

/// Bindings injectés au démarrage de l'app (avant le premier écran).
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ThemeService(), permanent: true); // déjà init, permanent
  }
}