import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
// Bouton Passer
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
        padding: const EdgeInsets.only(top: 12, right: 20),
        child: TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: color,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: Text(
            'Passer',
            style: TextStyle(
              color:      color,
              fontSize:   15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Slide individuelle
// ─────────────────────────────────────────────────────────────
class _Slide extends StatelessWidget {
  const _Slide({required this.slide, required this.isDark});

  final OnboardingModel slide;
  final bool            isDark;

  @override
  Widget build(BuildContext context) {
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final descC  = isDark ? AppColors.textDarkSub     : AppColors.textLightSub;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Cercle emoji
          Container(
            width:  190,
            height: 190,
            decoration: BoxDecoration(
              color: slide.bgColor.withOpacity(.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: slide.bgColor.withOpacity(.18),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                slide.emoji,
                style: const TextStyle(fontSize: 100),
              ),
            ),
          ),

          const SizedBox(height: 52),

          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize:      26,
              fontWeight:    FontWeight.w800,
              color:         titleC,
              height:        1.2,
              letterSpacing: -.4,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize:   16,
              color:      descC,
              height:     1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Footer — dots + boutons
// ─────────────────────────────────────────────────────────────
class _Footer extends StatelessWidget {
  const _Footer({required this.controller, required this.isDark});

  final OnboardingController controller;
  final bool                 isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dots
          Obx(() => _DotsRow(
            count:    controller.slides.length,
            current:  controller.currentPage.value,
            isDark:   isDark,
            activeColor: isDark
                ? AppColors.primaryBlue
                : AppColors.primaryGreen,
          )),

          const SizedBox(height: 32),

          // Bouton principal
          Obx(() => AppButton(
            label: controller.isLastPage
                ? 'Commencer avec NokiRide'
                : 'Suivant',
            onTap: controller.nextPage,
          )),

          // Bouton secondaire — seulement sur la dernière slide
          Obx(() => AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve:    Curves.easeInOut,
            child: controller.isLastPage
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
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
// Dots indicator
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
        ? Colors.white.withOpacity(.18)
        : Colors.black.withOpacity(.12);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve:    Curves.easeInOut,
          margin:   const EdgeInsets.symmetric(horizontal: 5),
          height:   8,
          width:    active ? 28 : 8,
          decoration: BoxDecoration(
            color:        active ? activeColor : inactiveC,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }
}
