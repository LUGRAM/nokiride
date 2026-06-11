import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/app_button.dart';
import '../../../app/widgets/quick_help_menu.dart';
import '../controller/onboarding_controller.dart';

import '../model/onboarding_model.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final controller = Get.find<OnboardingController>();
  late PageController _pageController;
  final RxDouble _currentPageValue = 0.0.obs;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: controller.currentPage.value,
      viewportFraction: 0.88, // Meilleur effet visuel
    );
    _pageController.addListener(() {
      _currentPageValue.value = _pageController.page ?? 0.0;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundGradient = isDark
        ? const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.bgDarkSurface, AppColors.bgDark],
    )
        : const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.bgLightSurface, AppColors.bgLight],
    );

    return Scaffold(
      body: Stack(
        children: [
          // Fond dégradé
          Container(decoration: BoxDecoration(gradient: backgroundGradient)),

          // Formes lumineuses en arrière-plan
          Positioned(
            top: -60,
            left: -80,
            child: _GlassSphere(
              size: 260,
              color: isDark ? AppColors.neonYellow : AppColors.emeraldPrimary,
              opacity: isDark ? 0.22 : 0.35,
            ),
          ),
          Positioned(
            bottom: 80,
            right: -100,
            child: _GlassSphere(
              size: 340,
              color: isDark ? AppColors.emeraldPrimary : const Color(0xFF076653),
              opacity: isDark ? 0.28 : 0.18,
            ),
          ),

          // Un seul BackdropFilter global (beaucoup plus performant)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
              child: const SizedBox.shrink(),
            ),
          ),

          // Interface principale
          SafeArea(
            child: Column(
              children: [
                // Bouton Skip & Help
                Padding(
                  padding: const EdgeInsets.only(top: 12, right: 20, left: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const QuickHelpMenu(),
                      TextButton(
                        onPressed: controller.skip,
                        style: TextButton.styleFrom(
                          splashFactory: NoSplash.splashFactory,
                          foregroundColor: isDark
                              ? AppColors.textDarkSub
                              : AppColors.textLightSub,
                        ),
                        child: Text(
                          'skip'.tr,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // PageView des cartes
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: controller.onPageChanged,
                    itemCount: controller.slides.length,
                    clipBehavior: Clip.none,
                    itemBuilder: (context, index) {
                      final slide = controller.slides[index];
                      return Obx(() {
                        final position = _currentPageValue.value - index;
                        final scale = (1 - (position.abs() * 0.15)).clamp(0.85, 1.0);
                        final translate = position * 18.0;

                        return Transform(
                          transform: Matrix4.identity()
                            ..scale(scale, scale)
                            ..translate(translate, 0.0),
                          alignment: Alignment.center,
                          child: _OnboardingCard(
                            slide: slide,
                            isDark: isDark,
                            isActive: position.abs() < 0.4,
                          ),
                        );
                      });
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Dots améliorés
                Obx(() => _buildDots()),

                const SizedBox(height: 32),

                // Boutons d'action
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Obx(() => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppButton(
                        label: controller.isLastPage ? 'start'.tr : 'next'.tr,
                        onTap: () {
                          if (!controller.isLastPage && _pageController.hasClients) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 320),
                              curve: Curves.easeInOutCubic,
                            );
                          } else {
                            controller.nextPage();
                          }
                        },
                      ),
                      if (controller.isLastPage) ...[
                        const SizedBox(height: 12),
                        AppButton(
                          label: "have_account".tr,
                          variant: AppButtonVariant.outline,
                          onTap: controller.goToLogin,
                        ),
                      ],
                    ],
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDots() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        controller.slides.length,
            (i) {
          final delta = (_currentPageValue.value - i).abs();
          final factor = (1.0 - delta).clamp(0.0, 1.0);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 7,
            width: 7 + (22 * factor),
            decoration: BoxDecoration(
              color: Color.lerp(
                isDark ? Colors.white.withOpacity(0.2) : AppColors.textLightSub.withOpacity(0.3),
                isDark ? AppColors.neonYellow : AppColors.emeraldPrimary,
                factor,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Sphère lumineuse en arrière-plan
// ─────────────────────────────────────────────────────────────
class _GlassSphere extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _GlassSphere({
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(opacity),
            Colors.transparent,
          ],
          stops: const [0.3, 1.0],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Carte Onboarding (Glassmorphism amélioré)
// ─────────────────────────────────────────────────────────────
class _OnboardingCard extends StatelessWidget {
  final OnboardingSlide slide;
  final bool isDark;
  final bool isActive;

  const _OnboardingCard({
    required this.slide,
    required this.isDark,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark
        ? Colors.black.withOpacity(isActive ? 0.42 : 0.22)
        : Colors.white.withOpacity(isActive ? 0.78 : 0.55);

    final borderColor = isDark
        ? Colors.white.withOpacity(isActive ? 0.18 : 0.08)
        : Colors.white.withOpacity(isActive ? 0.65 : 0.35);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 36),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: borderColor, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isActive ? 0.18 : 0.06),
            blurRadius: isActive ? 40 : 20,
            offset: Offset(0, isActive ? 20 : 8),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(isDark ? 0.08 : 0.25),
            Colors.white.withOpacity(0.02),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              // Zone illustration
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.07)
                        : AppColors.emeraldPrimary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Center(
                    child: AnimatedScale(
                      scale: isActive ? 1.08 : 0.88,
                      duration: const Duration(milliseconds: 280),
                      child: slide.iconBuilder?.call(context) ??
                          Text(
                            "📱", // fallback
                            style: const TextStyle(fontSize: 110),
                          ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Textes
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      slide.title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? AppColors.textDarkPrimary
                            : AppColors.textLightPrimary,
                        letterSpacing: 0.9,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      slide.description,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.textDarkSub
                            : AppColors.textLightSub,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}