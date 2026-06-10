import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../model/onboarding_model.dart';

class OnboardingController extends GetxController {
  final RxInt currentPage = 0.obs;

  final List<OnboardingSlide> slides = [
    OnboardingSlide(
      title: 'Noki noki !',
      description: 'Commandez une moto-taxi en quelques secondes avec une simplicité déconcertante.',
      iconBuilder: (context) => _TelegramStyleIcon(isDark: Theme.of(context).brightness == Brightness.dark),
    ),
    OnboardingSlide(
      title: 'Suivi en temps réel',
      description: 'Suivez votre coursier en direct sur la carte et restez informé à chaque étape.',
      iconBuilder: (context) => _WhatsAppStyleIcon(isDark: Theme.of(context).brightness == Brightness.dark),
    ),
    OnboardingSlide(
      title: 'Sécurité & Livraison',
      description: 'Bouton SOS, code de sécurité unique et livraison express pour votre tranquillité.',
      iconBuilder: (context) => _ShieldStyleIcon(isDark: Theme.of(context).brightness == Brightness.dark),
    ),
  ];

  bool get isLastPage => currentPage.value == slides.length - 1;

  void onPageChanged(int i) => currentPage.value = i;

  void nextPage() {
    if (isLastPage) {
      _finish();
    }
    // La navigation entre les pages est gérée directement par le PageController dans la vue
  }

  void skip() => _finish();

  void goToLogin() {
    GetStorage().write('hasSeenOnboarding', true);
    Get.offAllNamed(Routes.login);
  }

  void _finish() {
    GetStorage().write('hasSeenOnboarding', true);
    Get.offAllNamed(Routes.register);
  }
}

// ─────────────────────────────────────────────────────────────
// EXEMPLES D'ICÔNES STYLE PREMIUM (Telegram/WhatsApp/Shield)
// ─────────────────────────────────────────────────────────────

class _TelegramStyleIcon extends StatelessWidget {
  final bool isDark;
  const _TelegramStyleIcon({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? AppColors.emeraldPrimary : const Color(0xFF33A9D2),
            isDark ? const Color(0xFF076653) : const Color(0xFF2886A7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.emeraldPrimary : const Color(0xFF33A9D2)).withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.send_rounded,
          color: Colors.white,
          size: 70,
        ),
      ),
    );
  }
}

class _WhatsAppStyleIcon extends StatelessWidget {
  final bool isDark;
  const _WhatsAppStyleIcon({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B4D43) : const Color(0xFF25D366),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF1B4D43) : const Color(0xFF25D366)).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_rounded,
            color: Colors.white,
            size: 80,
          ),
          Positioned(
            top: 45,
            child: Icon(
              Icons.location_on_rounded,
              color: isDark ? AppColors.neonYellow : Colors.white.withOpacity(0.9),
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShieldStyleIcon extends StatelessWidget {
  final bool isDark;
  const _ShieldStyleIcon({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? AppColors.bgDarkElevated : Colors.white,
        border: Border.all(
          color: isDark ? AppColors.neonYellow.withOpacity(0.5) : AppColors.emeraldPrimary.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.verified_user_rounded,
          color: isDark ? AppColors.neonYellow : AppColors.emeraldPrimary,
          size: 80,
        ),
      ),
    );
  }
}
