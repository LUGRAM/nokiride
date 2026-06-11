import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';

class QuickHelpMenu extends StatelessWidget {
  const QuickHelpMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopupMenuButton<int>(
      offset: const Offset(0, 50),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDark ? AppColors.bgDarkSurface : Colors.white,
      padding: EdgeInsets.zero,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark 
              ? AppColors.bgDarkSurface.withValues(alpha: 0.5) 
              : AppColors.bgLightSurface.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark 
                ? AppColors.borderDark.withValues(alpha: 0.5) 
                : AppColors.borderLight,
            width: 1.5,
          ),
        ),
        child: Icon(
          Icons.help_outline_rounded,
          color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
          size: 22,
        ),
      ),
      onSelected: (value) {
        switch (value) {
          case 1:
            // TODO: Help action
            break;
          case 2:
            _showLanguageDialog(context);
            break;
          case 3:
            Get.changeThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<int>(
          enabled: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Quick Help',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
              ),
            ),
          ),
        ),
        _buildMenuItem(
          context,
          value: 1,
          icon: Icons.chat_bubble_outline_rounded,
          text: 'help_needed'.tr,
          isDark: isDark,
        ),
        _buildMenuItem(
          context,
          value: 2,
          icon: Icons.language_rounded,
          text: 'change_language'.tr,
          isDark: isDark,
        ),
        _buildMenuItem(
          context,
          value: 3,
          icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          text: 'change_theme'.tr,
          isDark: isDark,
        ),
      ],
    );
  }

  PopupMenuItem<int> _buildMenuItem(
    BuildContext context, {
    required int value,
    required IconData icon,
    required String text,
    required bool isDark,
  }) {
    return PopupMenuItem<int>(
      value: value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark 
              ? AppColors.emeraldPrimary.withValues(alpha: 0.1) 
              : AppColors.bgLightInput.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('change_language'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Français'),
              leading: const Text('🇫🇷', style: TextStyle(fontSize: 24)),
              onTap: () {
                Get.updateLocale(const Locale('fr', 'FR'));
                Get.back();
              },
            ),
            ListTile(
              title: const Text('English'),
              leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
              onTap: () {
                Get.updateLocale(const Locale('en', 'US'));
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
