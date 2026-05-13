import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../controller/home_controller.dart';

class NokiBottomNavBar extends StatelessWidget {
  const NokiBottomNavBar({super.key});

  static const _items = [
    _NavItemData(icon: Icons.home_filled,                    label: 'Accueil'),
    _NavItemData(icon: Icons.receipt_long_rounded,           label: 'Historique'),
    _NavItemData(icon: Icons.account_balance_wallet_rounded, label: 'Wallet'),
    _NavItemData(icon: Icons.person_rounded,                 label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final isDark     = Theme.of(context).brightness == Brightness.dark;

    // Couleurs Telegram-style
    final navBg     = isDark
        ? const Color(0xFF0D1D2E).withOpacity(.92)
        : Colors.white.withOpacity(.88);
    final navBorder = isDark
        ? Colors.white.withOpacity(.06)
        : Colors.black.withOpacity(.08);

    return Obx(() {
      final selectedIndex = controller.tabIndex.value;

      return ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          // ── Flou Telegram derrière la navbar ──────────────
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: 64,                          // ← plus compact que 82
            decoration: BoxDecoration(
              color:        navBg,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: navBorder, width: 1),
              boxShadow: [
                BoxShadow(
                  color:      Colors.black.withOpacity(isDark ? .30 : .10),
                  blurRadius: 20,
                  offset:     const Offset(0, 8),
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
    final activeColor   = isDark ? AppColors.primaryBlueLight : AppColors.primaryGreenDark;
    final inactiveColor = isDark
        ? Colors.white.withOpacity(.45)
        : Colors.black.withOpacity(.40);

    // Ripple color = couleur active translucide
    final rippleColor = activeColor.withOpacity(.12);

    return Material(
      color:        Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap:        onTap,
        borderRadius: BorderRadius.circular(18),
        // ── Ripple Telegram ────────────────────────────────
        splashColor:  rippleColor,
        highlightColor: rippleColor.withOpacity(.06),
        child: AnimatedContainer(
          duration:  const Duration(milliseconds: 200),
          curve:     Curves.easeOut,
          padding:   const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize:      MainAxisSize.min,
            children: [
              // Icône avec indicateur point Telegram
              Stack(
                alignment: Alignment.topRight,
                children: [
                  AnimatedScale(
                    scale:    isSelected ? 1.10 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve:    Curves.easeOut,
                    child: Icon(
                      icon,
                      size:  22,
                      color: isSelected ? activeColor : inactiveColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize:   10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color:      isSelected ? activeColor : inactiveColor,
                  letterSpacing: isSelected ? -.2 : 0,
                ),
                child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
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