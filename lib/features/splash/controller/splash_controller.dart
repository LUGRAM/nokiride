import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/routes/app_routes.dart';

class SplashController extends GetxController {
  final _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    // Vérification de sécurité : est-ce que les routes sont bien initialisées ?
    bool isLoggedIn = _storage.read('isLoggedIn') ?? false;

    // Utilise une logique simple pour éviter le crash
    if (isLoggedIn) {
      Get.offAllNamed(Routes.home);
    } else {
      // Vérifie bien que Routes.login est défini dans AppPages
      Get.offAllNamed(Routes.login);
    }
    print("Navigation vers : ${isLoggedIn ? Routes.home : Routes.login}");
  }}