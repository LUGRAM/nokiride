import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/routes/app_routes.dart';
import '../model/onboarding_model.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  final slides = const [
    OnboardingModel(title: 'Noki noki !', description: 'Commandez une moto-taxi en quelques secondes.', emoji: '🏍️', lottiePath: '', bgColor: Color(0xFF1B7BFF)),
    OnboardingModel(title: 'Suivi en temps réel', description: 'Suivez votre coursier en direct sur la carte.', emoji: '📍', lottiePath: '', bgColor: Color(0xFF00C44F)),
    OnboardingModel(title: 'Sécurité & Livraison', description: 'Bouton SOS, code de sécurité, livraison express.', emoji: '🔒', lottiePath: '', bgColor: Color(0xFFFF9500)),
  ];
  bool get isLastPage => currentPage.value == slides.length - 1;
  void onPageChanged(int i) => currentPage.value = i;
  void nextPage() => isLastPage ? _finish() : pageController.nextPage(duration: const Duration(milliseconds: 450), curve: Curves.easeInOut);
  void skip() => _finish();
  void goToLogin() { GetStorage().write('hasSeenOnboarding', true); Get.offAllNamed(Routes.login); }
  void _finish() { GetStorage().write('hasSeenOnboarding', true); Get.offAllNamed(Routes.login); }
  @override
  void onClose() { pageController.dispose(); super.onClose(); }
}
