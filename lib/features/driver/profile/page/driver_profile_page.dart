import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../app/services/theme_service.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../client/profile/controller/profile_controller.dart';

class DriverProfilePage extends GetView<ProfileController> {
  const DriverProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = ThemeService.to.isDark;

      final Color colorBg = isDark ? AppColors.slate950 : AppColors.background(context);
      final Color colorSurface = isDark ? AppColors.slate900 : AppColors.surface(context);
      final Color colorSlate = AppColors.accent(context);
      final Color colorBorder = isDark ? AppColors.slateDivider : AppColors.divider(context);
      final Color colorTextPrimary = AppColors.textPrimary(context);
      final Color colorTextSecondary = AppColors.textSub(context);
      final Color colorError = AppColors.error;

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarColor: Colors.transparent,
        ),
        child: Scaffold(
          backgroundColor: colorBg,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // 1. En-tête Profil
                  _buildHeader(colorSurface, colorBorder, colorSlate,
                      colorTextPrimary, colorTextSecondary),

                  const SizedBox(height: 24),

                  // 2. Bloc Statistiques
                  _buildStatsStrip(colorSurface, colorBorder, colorTextPrimary,
                      colorTextSecondary),

                  const SizedBox(height: 24),

                  // 3. Section 1 : DOCUMENTS DU CHAUFFEUR
                  _buildSectionTitle("DOCUMENTS DU CHAUFFEUR", colorTextSecondary),
                  _buildGroupedBlock(
                    [
                      _buildDriverDocumentTile(
                        title: "Permis de conduire",
                        status: "Validé",
                        statusColor: AppColors.success,
                        colorSlate: colorSlate,
                        colorTextPrimary: colorTextPrimary,
                        colorTextSecondary: colorTextSecondary,
                      ),
                      _buildDriverDocumentTile(
                        title: "Assurance véhicule",
                        status: "En attente",
                        statusColor: AppColors.warning,
                        colorSlate: colorSlate,
                        colorTextPrimary: colorTextPrimary,
                        colorTextSecondary: colorTextSecondary,
                      ),
                    ],
                    colorSurface: colorSurface,
                    colorBorder: colorBorder,
                  ),

                  const SizedBox(height: 20),

                  // 4. Section 2 : GESTION DU COMPTE
                  _buildSectionTitle("GESTION DU COMPTE", colorTextSecondary),
                  _buildGroupedBlock(
                    [
                      _buildTile(
                        icon: Icons.person_outline_rounded,
                        label: "Informations personnelles",
                        onTap: () => _showEditProfileSheet(context),
                        colorSlate: colorSlate,
                        colorTextPrimary: colorTextPrimary,
                        colorTextSecondary: colorTextSecondary,
                      ),
                      _buildTile(
                        icon: Icons.notifications_none_rounded,
                        label: "notifications".tr,
                        onTap: () => Get.toNamed('/notifications'),
                        colorSlate: colorSlate,
                        colorTextPrimary: colorTextPrimary,
                        colorTextSecondary: colorTextSecondary,
                      ),
                      _buildTile(
                        icon: Icons.account_balance_wallet_rounded,
                        label: "Informations bancaires / Versements",
                        onTap: () {},
                        colorSlate: colorSlate,
                        colorTextPrimary: colorTextPrimary,
                        colorTextSecondary: colorTextSecondary,
                      ),
                    ],
                    colorSurface: colorSurface,
                    colorBorder: colorBorder,
                  ),

                  const SizedBox(height: 20),

                  // 5. Section 3 : ACTIVITÉ & FIDÉLITÉ
                  _buildSectionTitle("ACTIVITÉ & FIDÉLITÉ", colorTextSecondary),
                  _buildGroupedBlock(
                    [
                      _buildTile(
                        icon: Icons.history_rounded,
                        label: "Historique des courses & Factures",
                        onTap: () {},
                        colorSlate: colorSlate,
                        colorTextPrimary: colorTextPrimary,
                        colorTextSecondary: colorTextSecondary,
                      ),
                      _buildTile(
                        icon: Icons.stars_rounded,
                        label: "Mon statut & Points privilèges",
                        onTap: () {},
                        colorSlate: colorSlate,
                        colorTextPrimary: colorTextPrimary,
                        colorTextSecondary: colorTextSecondary,
                      ),
                    ],
                    colorSurface: colorSurface,
                    colorBorder: colorBorder,
                  ),

                  const SizedBox(height: 20),

                  // 6. Section 4 : PRÉFÉRENCES
                  _buildSectionTitle("PRÉFÉRENCES", colorTextSecondary),
                  _buildGroupedBlock(
                    [
                      _buildTile(
                        icon: Icons.dark_mode_outlined,
                        label: "Thème Sombre",
                        colorSlate: colorSlate,
                        colorTextPrimary: colorTextPrimary,
                        colorTextSecondary: colorTextSecondary,
                        trailing: SizedBox(
                          height: 20,
                          child: Switch(
                            value: isDark,
                            onChanged: (_) => controller.toggleTheme(),
                            activeColor: colorSlate,
                            inactiveThumbColor:
                                isDark ? const Color(0xFF8696A0) : null,
                            inactiveTrackColor:
                                isDark ? const Color(0xFF222C32) : null,
                          ),
                        ),
                      ),
                      _buildTile(
                        icon: Icons.language_rounded,
                        label: "Langue de l'application",
                        onTap: controller.toggleLocale,
                        colorSlate: colorSlate,
                        colorTextPrimary: colorTextPrimary,
                        colorTextSecondary: colorTextSecondary,
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF222C32)
                                : colorSlate.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(4),
                            border:
                                Border.all(color: colorSlate.withOpacity(0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(controller.isFrench ? "🇫🇷" : "🇬🇧",
                                  style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text(
                                controller.isFrench ? "FR" : "EN",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : colorSlate,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      _buildTile(
                        icon: Icons.notifications_none_rounded,
                        label: "Gestion des alertes & Promos",
                        onTap: () => Get.toNamed('/notifications'),
                        colorSlate: colorSlate,
                        colorTextPrimary: colorTextPrimary,
                        colorTextSecondary: colorTextSecondary,
                      ),
                      _buildTile(
                        icon: Icons.speed_rounded,
                        label: "Mode économie de data",
                        colorSlate: colorSlate,
                        colorTextPrimary: colorTextPrimary,
                        colorTextSecondary: colorTextSecondary,
                        trailing: SizedBox(
                          height: 20,
                          child: Switch(
                            value: false,
                            onChanged: (v) {},
                            activeColor: colorSlate,
                            inactiveThumbColor:
                                isDark ? const Color(0xFF8696A0) : null,
                            inactiveTrackColor:
                                isDark ? const Color(0xFF222C32) : null,
                          ),
                        ),
                      ),
                    ],
                    colorSurface: colorSurface,
                    colorBorder: colorBorder,
                  ),

                  const SizedBox(height: 20),

                  // 7. Section 5 : SUPPORT & LÉGAL
                  _buildSectionTitle("SUPPORT & LÉGAL", colorTextSecondary),
                  _buildGroupedBlock(
                    [
                      _buildTile(
                        icon: Icons.help_outline_rounded,
                        label: "Centre d'aide & FAQ",
                        onTap: () {},
                        colorSlate: colorSlate,
                        colorTextPrimary: colorTextPrimary,
                        colorTextSecondary: colorTextSecondary,
                      ),
                      _buildTile(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: "Contacter le support",
                        onTap: () {},
                        colorSlate: colorSlate,
                        colorTextPrimary: colorTextPrimary,
                        colorTextSecondary: colorTextSecondary,
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF102A22)
                                : const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "En ligne",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color:
                                  isDark ? colorSlate : const Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      ),
                      _buildTile(
                        icon: Icons.description_outlined,
                        label: "Conditions Générales & CGU",
                        onTap: () {},
                        colorSlate: colorSlate,
                        colorTextPrimary: colorTextPrimary,
                        colorTextSecondary: colorTextSecondary,
                      ),
                      _buildTile(
                        icon: Icons.star_outline_rounded,
                        label: "Évaluer l'application",
                        onTap: () {},
                        colorSlate: colorSlate,
                        colorTextPrimary: colorTextPrimary,
                        colorTextSecondary: colorTextSecondary,
                      ),
                    ],
                    colorSurface: colorSurface,
                    colorBorder: colorBorder,
                  ),

                  const SizedBox(height: 32),

                  // 8. Déconnexion
                  TextButton.icon(
                    onPressed: controller.logout,
                    style: TextButton.styleFrom(foregroundColor: colorError),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: Text("logout".tr,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                  ),

                  const SizedBox(height: 24),
                  Text("NokiRide v1.0.0",
                      style: TextStyle(
                          fontSize: 11,
                          color: colorTextSecondary.withOpacity(0.4))),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeader(
    Color colorSurface,
    Color colorBorder,
    Color colorSlate,
    Color colorTextPrimary,
    Color colorTextSecondary,
  ) {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: colorSurface,
            shape: BoxShape.circle,
            border: Border.all(color: colorBorder, width: 2),
          ),
          child: Center(
            child:
                Icon(Icons.person_rounded, size: 48, color: colorTextSecondary),
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          final name = controller.userName.value.split('#')[0].trim();
          return Text(
            name.isEmpty ? "Utilisateur" : name,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: colorTextPrimary,
                letterSpacing: -0.5),
          );
        }),
        const SizedBox(height: 4),
        Obx(() => Text(
              controller.userPhone.value,
              style: TextStyle(
                  fontSize: 14,
                  color: colorTextSecondary,
                  fontWeight: FontWeight.w500),
            )),
      ],
    );
  }

  Widget _buildStatsStrip(
    Color colorSurface,
    Color colorBorder,
    Color colorTextPrimary,
    Color colorTextSecondary,
  ) {
    return Obx(() {
      final isLoading = controller.isLoadingStats.value;
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: colorSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorBorder),
        ),
        child: isLoading
            ? SizedBox(
                height: 42,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: colorTextPrimary,
                  ),
                ),
              )
            : Row(
                children: [
                  _buildStatItem("${controller.totalTrips}", "Courses",
                      colorTextPrimary, colorTextSecondary),
                  _buildVerticalDivider(colorBorder),
                  _buildStatItem(controller.totalEarnings, "Revenus",
                      colorTextPrimary, colorTextSecondary),
                  _buildVerticalDivider(colorBorder),
                  _buildStatItem(controller.memberSince, "Depuis",
                      colorTextPrimary, colorTextSecondary),
                ],
              ),
      );
    });
  }

  void _showEditProfileSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameController =
        TextEditingController(text: controller.userName.value);
    final phoneController =
        TextEditingController(text: controller.userPhone.value);
    final emailController =
        TextEditingController(text: controller.userEmail.value);
    final titleC = AppColors.textPrimary(context);
    final subC = AppColors.textSub(context);
    final surface = isDark ? AppColors.slate900 : AppColors.surface(context);
    final border = isDark ? AppColors.slateDivider : AppColors.divider(context);
    final accent = AppColors.accent(context);

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 14,
          bottom: MediaQuery.of(context).viewInsets.bottom + 18,
        ),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          border: Border(top: BorderSide(color: border)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Informations personnelles',
                style: TextStyle(
                  color: titleC,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Le téléphone doit rester au format +24177xxxxxx.',
                style: TextStyle(color: subC, fontSize: 12),
              ),
              const SizedBox(height: 16),
              _profileField(
                controller: nameController,
                label: 'Nom complet',
                icon: Icons.person_outline_rounded,
                titleC: titleC,
                subC: subC,
                border: border,
                accent: accent,
              ),
              const SizedBox(height: 10),
              _profileField(
                controller: phoneController,
                label: 'Téléphone',
                icon: Icons.phone_outlined,
                titleC: titleC,
                subC: subC,
                border: border,
                accent: accent,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              _profileField(
                controller: emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                titleC: titleC,
                subC: subC,
                border: border,
                accent: accent,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Obx(() => FilledButton(
                      onPressed: controller.isSavingProfile.value
                          ? null
                          : () => controller.updateProfile(
                                name: nameController.text,
                                phone: phoneController.text,
                                email: emailController.text,
                              ),
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: controller.isSavingProfile.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Enregistrer',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                    )),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: isDark ? .55 : .25),
    ).whenComplete(() {
      nameController.dispose();
      phoneController.dispose();
      emailController.dispose();
    });
  }

  Widget _profileField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color titleC,
    required Color subC,
    required Color border,
    required Color accent,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: titleC, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: subC),
        prefixIcon: Icon(icon, color: subC, size: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color colorTextPrimary,
      Color colorTextSecondary) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: colorTextPrimary)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colorTextSecondary)),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(Color colorBorder) {
    return Container(width: 1, height: 24, color: colorBorder);
  }

  Widget _buildSectionTitle(String title, Color colorTextSecondary) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: colorTextSecondary,
              letterSpacing: 1.1),
        ),
      ),
    );
  }

  Widget _buildGroupedBlock(List<Widget> tiles,
      {required Color colorSurface, required Color colorBorder}) {
    return Container(
      decoration: BoxDecoration(
        color: colorSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorBorder),
      ),
      child: Column(
        children: List.generate(tiles.length, (index) {
          return Column(
            children: [
              tiles[index],
              if (index < tiles.length - 1)
                Divider(
                    height: 0.5,
                    thickness: 0.5,
                    color: colorBorder,
                    indent: 52),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    Widget? trailing,
    required Color colorSlate,
    required Color colorTextPrimary,
    required Color colorTextSecondary,
  }) {
    return ListTile(
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: colorSlate.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 18, color: colorSlate),
      ),
      title: Text(label,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorTextPrimary)),
      trailing: trailing ??
          Icon(Icons.chevron_right_rounded,
              size: 18, color: colorTextSecondary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  Widget _buildDriverDocumentTile({
    required String title,
    required String status,
    required Color statusColor,
    required Color colorSlate,
    required Color colorTextPrimary,
    required Color colorTextSecondary,
  }) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorSlate.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.assignment_turned_in_rounded,
          size: 18,
          color: colorSlate,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colorTextPrimary,
        ),
      ),
      subtitle: Text(
        "Document chauffeur",
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: colorTextSecondary,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: statusColor,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }
}
