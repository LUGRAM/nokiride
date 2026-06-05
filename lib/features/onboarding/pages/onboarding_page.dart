import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/app_button.dart';
import '../controller/onboarding_controller.dart';
import '../model/onboarding_model.dart';

class OnboardingPage extends GetView<OnboardingController> {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? AppColors.bgDark : AppColors.bgLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _SkipButton(isDark: isDark, onTap: controller.skip),
            Expanded(
              child: PageView.builder(
                controller:    controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount:     controller.slides.length,
                itemBuilder:   (_, i) => _Slide(
                  slide:  controller.slides[i],
                  isDark: isDark,
                ),
              ),
            ),
            _Footer(controller: controller, isDark: isDark),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Bouton Passer (Plus discret, mieux intégré)
// ─────────────────────────────────────────────────────────────
class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.isDark, required this.onTap});

  final bool         isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isDark ? AppColors.textDarkSub : AppColors.textLightSub;

    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, right: 16),
        child: TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: color,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            splashFactory: NoSplash.splashFactory, // Évite l'effet de flash gris
          ),
          child: Text(
            'Passer',
            style: GoogleFonts.inter(
              color:      color,
              fontSize:   14,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Slide individuelle (Épurée et Premium)
// ─────────────────────────────────────────────────────────────
class _Slide extends StatelessWidget {
  const _Slide({required this.slide, required this.isDark});

  final OnboardingModel slide;
  final bool            isDark;

  @override
  Widget build(BuildContext context) {
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final descC  = isDark ? AppColors.textDarkSub     : AppColors.textLightSub;
    final cardBg = isDark ? AppColors.bgDarkSurface : Colors.white;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Cercle d'illustration Premium
          Container(
            width:  180,
            height: 180,
            decoration: BoxDecoration(
              color: isDark ? cardBg.withOpacity(0.6) : AppColors.lightAcidGreen.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(
                color: border.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: isDark ? [] : [
                BoxShadow(
                  color: AppColors.darkGreenBase.withOpacity(0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                slide.emoji,
                style: const TextStyle(fontSize: 85),
              ),
            ),
          ),

          const SizedBox(height: 48),

          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize:      26,
              fontWeight:    FontWeight.w900,
              color:         titleC,
              height:        1.25,
              letterSpacing: -0.8,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize:   15,
              color:      descC,
              height:     1.5,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Footer — dots + boutons relookés
// ─────────────────────────────────────────────────────────────
class _Footer extends StatelessWidget {
  const _Footer({required this.controller, required this.isDark});

  final OnboardingController controller;
  final bool                 isDark;

  @override
  Widget build(BuildContext context) {
    // Changement dynamique de l'accent pour les dots actifs
    final activeDotColor = isDark ? AppColors.neonYellow : AppColors.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dots Indicator
          Obx(() => _DotsRow(
            count:       controller.slides.length,
            current:     controller.currentPage.value,
            isDark:      isDark,
            activeColor: activeDotColor,
          )),

          const SizedBox(height: 36),

          // Bouton Principal (Suivant / Commencer)
          Obx(() => AppButton(
            label: controller.isLastPage
                ? 'Commencer avec NokiRide'
                : 'Suivant',
            onTap: controller.nextPage,
          )),

          // Bouton secondaire (Optionnel en dernière page)
          Obx(() => AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve:    Curves.easeInOut,
            child: controller.isLastPage
                ? Padding(
              padding: const EdgeInsets.only(top: 14),
              child: AppButton(
                label:   "J'ai déjà un compte",
                variant: AppButtonVariant.outline,
                onTap:   controller.goToLogin,
              ),
            )
                : const SizedBox.shrink(),
          )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Dots Indicator (Design Étiré / Pill-shaped modern)
// ─────────────────────────────────────────────────────────────
class _DotsRow extends StatelessWidget {
  const _DotsRow({
    required this.count,
    required this.current,
    required this.isDark,
    required this.activeColor,
  });

  final int   count;
  final int   current;
  final bool  isDark;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final inactiveC = isDark
        ? Colors.white.withOpacity(.15)
        : AppColors.textLightMuted.withOpacity(.3);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve:    Curves.easeInOut,
          margin:   const EdgeInsets.symmetric(horizontal: 4),
          height:   6,
          width:    active ? 24 : 6, // Effet pilule étirée moderne
          decoration: BoxDecoration(
            color:        active ? activeColor : inactiveC,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}