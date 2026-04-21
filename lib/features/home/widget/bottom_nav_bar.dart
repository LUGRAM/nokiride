import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../controller/home_controller.dart';

class NokiBottomNavBar extends StatelessWidget {
  const NokiBottomNavBar({super.key});

  static const _items = [
    _NavItemData(icon: Icons.home_filled,            label: 'Accueil'),
    _NavItemData(icon: Icons.local_shipping_outlined, label: 'Livraisons'),
    _NavItemData(icon: Icons.compare_arrows_rounded,  label: 'Courses'),
    _NavItemData(icon: Icons.person_rounded,          label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final isDark     = Theme.of(context).brightness == Brightness.dark;

    // Couleurs dépendant du thème — passées au painter
    final navBg     = isDark ? const Color(0xFF0D1D2E) : AppColors.bgLightSurface;
    final navBorder = isDark
        ? Colors.white.withOpacity(0.04)
        : AppColors.borderLight;

    return Obx(() {
      final selectedIndex = controller.tabIndex.value;

      return Material(
        color: Colors.transparent,
        child: Container(
          height: 82,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color:      Colors.black.withOpacity(isDark ? 0.28 : 0.10),
                blurRadius: 24,
                offset:     const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: CustomPaint(
              painter: _NavBarPainter(
                bgColor:     navBg,
                borderColor: navBorder,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: List.generate(_items.length, (i) {
                    return Expanded(
                      child: _BottomNavItem(
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
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────
// Item
// ─────────────────────────────────────────────────────────────
class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
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
    // Dark : fond bleu marine / texte bleu clair
    // Light : fond vert pâle / texte vert foncé
    final activeBg   = isDark
        ? const Color(0xFF1A3A5C)
        : AppColors.primaryGreenFill;
    final activeColor = isDark
        ? AppColors.primaryBlueLight
        : AppColors.primaryGreenDark;
    final inactiveColor = isDark
        ? Colors.white.withOpacity(0.45)
        : AppColors.textLightMuted;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap:    onTap,
      child: AnimatedContainer(
        duration:  const Duration(milliseconds: 220),
        curve:     Curves.easeOut,
        margin:    const EdgeInsets.symmetric(horizontal: 4),
        padding:   const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color:        isSelected ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size:  22,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize:   11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color:      isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Painter — reçoit les couleurs, ne hardcode rien
// ─────────────────────────────────────────────────────────────
class _NavBarPainter extends CustomPainter {
  const _NavBarPainter({
    required this.bgColor,
    required this.borderColor,
  });

  final Color bgColor;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(30),
    );

    // Ombre portée
    canvas.drawShadow(
      Path()..addRRect(rrect),
      Colors.black.withOpacity(0.22),
      14,
      false,
    );

    // Fond
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = bgColor
        ..style = PaintingStyle.fill,
    );

    // Bordure subtile
    canvas.drawRRect(
      rrect,
      Paint()
        ..color       = borderColor
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_NavBarPainter old) =>
      old.bgColor != bgColor || old.borderColor != borderColor;
}

// ─────────────────────────────────────────────────────────────
// Data
// ─────────────────────────────────────────────────────────────
class _NavItemData {
  final IconData icon;
  final String   label;
  const _NavItemData({required this.icon, required this.label});
}