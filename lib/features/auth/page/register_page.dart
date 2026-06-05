import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_colors.dart';
import '../controller/auth_controller.dart';

class RegisterPage extends GetView<AuthController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final primary = AppColors.emeraldPrimary;
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC = isDark ? AppColors.textDarkSub : AppColors.textLightSub;
    final inputBg = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),

              Text(
                "Créer mon profil",
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: titleC,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Comment devons-nous vous appeler ?",
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: subC,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),

              // Champ de saisie Nom/Prénom
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: border, width: 1.5),
                  boxShadow: isDark ? [] : [
                    BoxShadow(
                      color: AppColors.darkGreenBase.withOpacity(0.02),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.solidUser,
                      color: AppColors.emeraldPrimary,
                      size: 16,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextField(
                        onChanged: controller.setName,
                        autofocus: true,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: titleC,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Votre prénom et nom",
                          hintStyle: GoogleFonts.inter(
                            color: subC.withOpacity(0.35),
                            fontWeight: FontWeight.w500,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Bouton Finalisation d'inscription
              Obx(() => SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                    overlayColor: isDark ? AppColors.neonYellow.withOpacity(0.2) : null,
                  ),
                  onPressed: controller.isLoading.value ? null : controller.register,
                  child: controller.isLoading.value
                      ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: isDark ? AppColors.bgDark : Colors.white,
                    ),
                  )
                      : Text(
                    "Commencer",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textDarkPrimary : Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}