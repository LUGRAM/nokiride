import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/services/theme_service.dart';
import '../../../app/theme/app_colors.dart';
import '../controller/profile_controller.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final primary = isDark ? AppColors.primaryBlue : AppColors.primaryGreen;
    final subC = isDark ? AppColors.textDarkSub : AppColors.textLightSub;

    return Container(
      color: bg,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
          child: Column(
            children: [
              // ── Profile header card ───────────────────────
              _ProfileHeaderCard(isDark: isDark, primary: primary, controller: controller),
              const SizedBox(height: 14),

              // ── Stats strip ───────────────────────────────
              _StatsStrip(isDark: isDark, primary: primary, controller: controller),
              const SizedBox(height: 20),

              // ── Préférences ───────────────────────────────
              _SectionLabel(label: "Préférences", isDark: isDark),
              const SizedBox(height: 10),
              _SettingsCard(isDark: isDark, children: [
                _SettingsTile(
                  icon: Icons.dark_mode_rounded,
                  label: "Thème sombre",
                  isDark: isDark,
                  trailing: Obx(() => Switch(
                    value: ThemeService.to.isDark,
                    onChanged: (_) => controller.toggleTheme(),
                    activeThumbColor: primary,
                  )),
                ),
                _Divider(isDark: isDark),
                _SettingsTile(
                  icon: Icons.language_rounded,
                  label: "Langue",
                  isDark: isDark,
                  trailing: Obx(() => GestureDetector(
                    onTap: controller.toggleLocale,
                    child: _LangBadge(
                        isFrench: controller.isFrench, primary: primary),
                  )),
                ),
              ]),

              const SizedBox(height: 12),

              // ── Compte ────────────────────────────────────
              _SectionLabel(label: "Compte", isDark: isDark),
              const SizedBox(height: 10),
              _SettingsCard(isDark: isDark, children: [
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  label: "Notifications",
                  isDark: isDark, onTap: () {},
                ),
                _Divider(isDark: isDark),
                _SettingsTile(
                  icon: Icons.shield_outlined,
                  label: "Confidentialité",
                  isDark: isDark, onTap: () {},
                ),
                _Divider(isDark: isDark),
                _SettingsTile(
                  icon: Icons.help_outline_rounded,
                  label: "Aide & Support",
                  isDark: isDark, onTap: () {},
                ),
                _Divider(isDark: isDark),
                _SettingsTile(
                  icon: Icons.star_outline_rounded,
                  label: "Évaluer l'application",
                  isDark: isDark, onTap: () {},
                ),
              ]),

              const SizedBox(height: 20),

              // ── Déconnexion ───────────────────────────────
              GestureDetector(
                onTap: controller.logout,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.error.withValues(alpha: .25)),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                    const SizedBox(width: 10),
                    const Text("Se déconnecter",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.error)),
                  ]),
                ),
              ),

              const SizedBox(height: 20),

              // ── Version ───────────────────────────────────
              Text("NokiRide v1.0.0",
                  style: TextStyle(fontSize: 12, color: subC)),
              const SizedBox(height: 4),
              Text("Made with ♥ in Libreville",
                  style: TextStyle(fontSize: 11, color: subC.withValues(alpha: .6))),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Carte header profil ─────────────────────────────────────────
class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard(
      {required this.isDark, required this.primary, required this.controller});
  final bool isDark;
  final Color primary;
  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC = isDark ? AppColors.textDarkSub : AppColors.textLightSub;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: border),
      ),
      child: Column(children: [
        // Gradient banner
        Container(
          height: 80,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            gradient: isDark
                ? const LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Color(0xFF0E2E8A), Color(0xFF07101E)],
                  )
                : const LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Color(0xFF00C44F), Color(0xFF009B3E)],
                  ),
          ),
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.edit_outlined, color: Colors.white.withValues(alpha: .9), size: 13),
                    const SizedBox(width: 5),
                    Text("Modifier",
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: .9),
                            fontSize: 12, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ),
          ),
        ),

        // Avatar + infos
        Transform.translate(
          offset: const Offset(0, -38),
          child: Column(children: [
            Container(
              width: 76, height: 76,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: .12),
                shape: BoxShape.circle,
                border: Border.all(color: cardBg, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: .20),
                    blurRadius: 16, offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(Icons.person_rounded, color: primary, size: 36),
            ),
            const SizedBox(height: 10),
            Obx(() => Text(controller.userName.value,
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: titleC))),
            const SizedBox(height: 4),
            Obx(() => Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.phone_outlined, color: subC, size: 13),
              const SizedBox(width: 4),
              Text(controller.userPhone.value,
                  style: TextStyle(fontSize: 13, color: subC)),
            ])),
            const SizedBox(height: 16),
          ]),
        ),
      ]),
    );
  }
}

// ── Bande de stats ──────────────────────────────────────────────
class _StatsStrip extends StatelessWidget {
  const _StatsStrip(
      {required this.isDark, required this.primary, required this.controller});
  final bool isDark;
  final Color primary;
  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC = isDark ? AppColors.textDarkSub : AppColors.textLightSub;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: cardBg, borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
      ),
      child: Row(children: [
        _StatItem(
          value: "${controller.totalTrips}",
          label: "Courses",
          titleC: titleC, subC: subC, primary: primary,
        ),
        _StatDivider(isDark: isDark),
        _StatItem(
          value: controller.totalSpent,
          label: "Dépenses",
          titleC: titleC, subC: subC, primary: primary,
        ),
        _StatDivider(isDark: isDark),
        _StatItem(
          value: controller.memberSince,
          label: "Membre depuis",
          titleC: titleC, subC: subC, primary: primary,
        ),
      ]),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem(
      {required this.value, required this.label,
       required this.titleC, required this.subC, required this.primary});
  final String value, label;
  final Color titleC, subC, primary;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Text(value,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: titleC)),
        const SizedBox(height: 3),
        Text(label,
            style: TextStyle(fontSize: 11, color: subC, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center),
      ]),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1, height: 36,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
    );
  }
}

// ── Label de section ────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.isDark});
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final subC = isDark ? AppColors.textDarkSub : AppColors.textLightSub;
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(label.toUpperCase(),
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: subC, letterSpacing: .8)),
    );
  }
}

// ── Card paramètres ─────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.isDark, required this.children});
  final bool isDark;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      decoration: BoxDecoration(
        color: cardBg, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(children: children),
    );
  }
}

// ── Tile paramètre ──────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon, required this.label, required this.isDark,
    this.trailing, this.onTap,
  });
  final IconData icon;
  final String label;
  final bool isDark;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final iconC = isDark ? AppColors.textDarkSub : AppColors.textLightSub;
    final iconBg = iconC.withValues(alpha: .10);

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconC, size: 19),
      ),
      title: Text(label,
          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: textC)),
      trailing: trailing ??
          (onTap != null
              ? Icon(Icons.chevron_right_rounded,
                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted)
              : null),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      minLeadingWidth: 36,
    );
  }
}

// ── Badge langue ────────────────────────────────────────────────
class _LangBadge extends StatelessWidget {
  const _LangBadge({required this.isFrench, required this.primary});
  final bool isFrench;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primary.withValues(alpha: .25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(isFrench ? "🇫🇷" : "🇬🇧", style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 5),
        Text(isFrench ? "FR" : "EN",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: primary)),
      ]),
    );
  }
}

// ── Divider ─────────────────────────────────────────────────────
class _Divider extends StatelessWidget {
  const _Divider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Divider(
        height: 1,
        color: isDark ? AppColors.borderDark : AppColors.borderLight,
        indent: 66);
  }
}
