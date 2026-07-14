import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../controller/driver_dashboard_controller.dart';

class DriverBottomNav extends GetView<DriverDashboardController> {
  const DriverBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final selectedIndex = controller.tabIndex.value;

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              height: 76,
              decoration: BoxDecoration(
                color: isDark 
                    ? AppColors.slate900.withValues(alpha: 0.85) 
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isDark 
                      ? Colors.white.withValues(alpha: 0.1) 
                      : Colors.black.withValues(alpha: 0.05),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _DriverNavItem(
                    icon: FontAwesomeIcons.mapLocationDot,
                    label: 'Carte',
                    isSelected: selectedIndex == 0,
                    onTap: () => controller.changeTabIndex(0),
                  ),
                  _DriverNavItem(
                    icon: FontAwesomeIcons.chartSimple,
                    label: 'Gains',
                    isSelected: selectedIndex == 1,
                    onTap: () => controller.changeTabIndex(1),
                  ),
                  _DriverNavItem(
                    icon: FontAwesomeIcons.wallet,
                    label: 'Wallet',
                    isSelected: selectedIndex == 2,
                    onTap: () => controller.changeTabIndex(2),
                  ),
                  _DriverNavItem(
                    icon: FontAwesomeIcons.userGear,
                    label: 'Profil',
                    isSelected: selectedIndex == 3,
                    onTap: () => controller.changeTabIndex(3),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _DriverNavItem extends StatelessWidget {
  const _DriverNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.accent(context);
    final inactiveColor = AppColors.textSub(context).withValues(alpha: 0.5);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          highlightColor: activeColor.withValues(alpha: 0.05),
          splashColor: activeColor.withValues(alpha: 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: FaIcon(
                  icon,
                  size: 19,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
              AnimatedOpacity(
                opacity: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: activeColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
