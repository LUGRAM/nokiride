import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../controller/home_controller.dart';

class NokiBottomNavBar extends StatelessWidget {
  const NokiBottomNavBar({super.key});

  static final _items = [
    _NavItemData(icon: FontAwesomeIcons.house,               label: 'Accueil'),
    _NavItemData(icon: FontAwesomeIcons.clockRotateLeft,     label: 'Activités'),
    _NavItemData(icon: FontAwesomeIcons.wallet,              label: 'Wallet'),
    _NavItemData(icon: FontAwesomeIcons.bars,                label: 'Menu'),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final isDark     = Theme.of(context).brightness == Brightness.dark;

    final navBg     = isDark
        ? AppColors.bgDark.withOpacity(.95)
        : AppColors.bgLightSurface.withOpacity(.90);
    final navBorder = isDark
        ? AppColors.borderDark
        : AppColors.borderLight;

    return Obx(() {
      final selectedIndex = controller.tabIndex.value;

      return ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color:        navBg,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: navBorder, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color:      Colors.black.withOpacity(isDark ? .40 : .08),
                  blurRadius: 25,
                  offset:     const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: List.generate(_items.length, (i) {
                return Expanded(
                  child: _NavItem(
                    icon:       _items[i].icon,
                    label:      _items[i].label,
                    isSelected: i == selectedIndex,
                    isDark:     isDark,
                    onTap:      () => controller.changeTabIndex(i),
                  ),
                );
              }),
            ),
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────
// Item avec ripple + animation Telegram
// ─────────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final IconData     icon;
  final String       label;
  final bool         isSelected;
  final bool         isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor   = isDark ? AppColors.neonYellow : AppColors.success;
    final inactiveColor = isDark
        ? AppColors.textDarkMuted
        : AppColors.textLightMuted;

    final rippleColor = activeColor.withOpacity(.10);

    return Material(
      color:        Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap:        onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor:  rippleColor,
        highlightColor: rippleColor.withOpacity(.05),
        child: AnimatedContainer(
          duration:  const Duration(milliseconds: 250),
          curve:     Curves.easeOutCubic,
          padding:   const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize:      MainAxisSize.min,
            children: [
              AnimatedScale(
                scale:    isSelected ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 250),
                curve:    Curves.easeOutBack,
                child: Center(
                  child: FaIcon(
                    icon,
                    size:  20,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  fontSize:   11,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  color:      isSelected ? activeColor : inactiveColor,
                  letterSpacing: isSelected ? -0.3 : 0,
                ),
                child: Text(label, maxLines: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Barrier non-cliquable sous la navbar
// À utiliser dans home_page.dart à la place de Positioned simple
// ─────────────────────────────────────────────────────────────
class NokiNavBarBarrier extends StatelessWidget {
  const NokiNavBarBarrier({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        // Zone basse non-cliquable (absorbe les taps sous la navbar)
        Positioned(
          left: 0, right: 0, bottom: 0,
          height: 90,
          child: IgnorePointer(
            ignoring: false,
            child: Container(color: Colors.transparent),
          ),
        ),
      ],
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String   label;
  const _NavItemData({required this.icon, required this.label});
}