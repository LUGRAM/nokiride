import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../app/routes/app_routes.dart';
import '../model/onboarding_model.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  final List<OnboardingModel> slides = [
    OnboardingModel(
      title: "Noki noki !",
      description: "Commandez une moto-taxi en quelques secondes et déplacez-vous rapidement en ville.",
      lottiePath: "assets/animations/ride_fast.json",
      emoji: "🏍️",
      bgColor: const Color(0xFF00D27F),
    ),
    OnboardingModel(
      title: "Suivi en temps réel",
      description: "Suivez votre chauffeur en direct sur la carte et sachez exactement quand il arrive.",
      lottiePath: "assets/animations/tracking.json",
      emoji: "📍",
      bgColor: const Color(0xFF00B0FF),
    ),
    OnboardingModel(
      title: "Sécurité & Livraison",
      description: "Bouton SOS, code de sécurité et livraison de colis express en toute confiance.",
      lottiePath: "assets/animations/safety_delivery.json",
      emoji: "🔒",
      bgColor: const Color(0xFFFFA500),
    ),
  ];

  bool get isLastPage => currentPage.value == slides.length - 1;

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < slides.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void skip() {
    _finishOnboarding();
  }

  /// Nouvelle méthode ajoutée pour le bouton "J'ai déjà un compte"
  void goToLogin() {
    final storage = GetStorage();
    storage.write('hasSeenOnboarding', true);
    Get.offAllNamed(Routes.login);
  }

  void _finishOnboarding() {
    final storage = GetStorage();
    storage.write('hasSeenOnboarding', true);

    // Pour le MVP : on va directement à l'accueil
    // Tu pourras changer en Routes.login plus tard si tu veux forcer la connexion
    Get.offAllNamed(Routes.home);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}