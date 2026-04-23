import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../controller/profile_controller.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final primary = isDark ? AppColors.primaryBlue : AppColors.primaryGreen;
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC = isDark ? AppColors.textDarkSub : AppColors.textLightSub;
    final cardBg = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      color: bg,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Avatar + nom
              Column(children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: .12), shape: BoxShape.circle,
                    border: Border.all(color: primary.withValues(alpha:
                    .30), width: 2),
                  ),
                  child: Icon(Icons.person_rounded, color: primary, size: 38),
                ),
                const SizedBox(height: 12),
                Obx(() => Text(controller.userName.value,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: titleC))),
                const SizedBox(height: 4),
                Obx(() => Text(controller.userPhone.value,
                  style: TextStyle(fontSize: 14, color: subC))),
              ]),

              const SizedBox(height: 24),

              // Paramètres
              _SettingsCard(isDark: isDark, cardBg: cardBg, border: border, children: [
                _SettingsTile(
                  icon: Icons.dark_mode_rounded, label: "Thème sombre",
                  trailing: Obx(() => Switch(
                    value: ThemeService.isDark,
                    onChanged: (_) => controller.toggleTheme(),
                    activeThumbColor: primary,
                  )),
                  isDark: isDark,
                ),
                _Divider(isDark: isDark),
                _SettingsTile(
                  icon: Icons.language_rounded, label: "Langue",
                  trailing: Obx(() => GestureDetector(
                    onTap: controller.toggleLocale,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: primary.withValues(alpha: .12), borderRadius: BorderRadius.circular(8)),
                      child: Text(controller.isFrench ? "🇫🇷 FR" : "🇬🇧 EN",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: primary)),
                    ),
                  )),
                  isDark: isDark,
                ),
              ]),

              const SizedBox(height: 12),

              _SettingsCard(isDark: isDark, cardBg: cardBg, border: border, children: [
                _SettingsTile(icon: Icons.notifications_outlined, label: "Notifications", isDark: isDark, onTap: () {}),
                _Divider(isDark: isDark),
                _SettingsTile(icon: Icons.shield_outlined, label: "Confidentialité", isDark: isDark, onTap: () {}),
                _Divider(isDark: isDark),
                _SettingsTile(icon: Icons.help_outline_rounded, label: "Aide & Support", isDark: isDark, onTap: () {}),
                _Divider(isDark: isDark),
                _SettingsTile(icon: Icons.star_outline_rounded, label: "Évaluer l'app", isDark: isDark, onTap: () {}),
              ]),

              const SizedBox(height: 12),

              _SettingsCard(isDark: isDark, cardBg: cardBg, border: border, children: [
                _SettingsTile(
                  icon: Icons.logout_rounded, label: "Se déconnecter",
                  labelColor: AppColors.error, iconColor: AppColors.error,
                  isDark: isDark, onTap: controller.logout,
                ),
              ]),

              const SizedBox(height: 24),
              Text("NokiRide v1.0.0", style: TextStyle(fontSize: 12, color: subC)),
            ],
          ),
        ),
      ),
    );
  }
}

class ThemeService {
  static ThemeService get to => ThemeService();
  static bool get isDark => Get.isDarkMode;
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.isDark, required this.cardBg, required this.border, required this.children});
  final bool isDark;
  final Color cardBg, border;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: border)),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.label, required this.isDark,
    this.trailing, this.onTap, this.labelColor, this.iconColor});
  final IconData icon;
  final String label;
  final bool isDark;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? labelColor, iconColor;

  @override
  Widget build(BuildContext context) {
    final textC = labelColor ?? (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary);
    final iconC = iconColor ?? (isDark ? AppColors.textDarkSub : AppColors.textLightSub);

    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: iconC, size: 22),
      title: Text(label, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: textC)),
      trailing: trailing ?? (onTap != null ? Icon(Icons.chevron_right_rounded, color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted) : null),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.isDark});
  final bool isDark;
  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight, indent: 54);
  }
}
