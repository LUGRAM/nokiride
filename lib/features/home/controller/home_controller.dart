import 'package:get/get.dart';

class HomeController extends GetxController {
  // Index de l'onglet actif (0: Accueil, 1: Livraisons, 2: Courses, 3: Profil)
  var tabIndex = 0.obs;

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }
}