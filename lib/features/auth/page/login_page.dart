import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_colors.dart';
import '../controller/auth_controller.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final primary = AppColors.emeraldPrimary;
    final accent = isDark ? AppColors.neonYellow : AppColors.emeraldPrimary;
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC = isDark ? AppColors.textDarkSub : AppColors.textLightSub;
    final cardBg = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final inputBg = isDark ? AppColors.bgDarkElevated : AppColors.bgLightInput;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),

              // Icône de Marque Premium
              Center(
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.emeraldPrimary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.emeraldPrimary.withOpacity(0.25),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.motorcycle,
                      color: AppColors.emeraldPrimary,
                      size: 34,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              Text(
                "Bienvenue sur NokiRide",
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: titleC,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Entrez votre numéro pour continuer",
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: subC,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.1,
                ),
              ),
              const SizedBox(height: 40),

              // Carte Formulaire
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: border, width: 1.5),
                  boxShadow: isDark ? [] : [
                    BoxShadow(
                      color: AppColors.darkGreenBase.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Numéro de téléphone",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: subC,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Indicatif Pays
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: inputBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: border.withOpacity(0.3), width: 1),
                          ),
                          child: Text(
                            "+241",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: titleC,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Champ de Saisie
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: inputBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: border.withOpacity(0.3), width: 1),
                            ),
                            child: TextField(
                              onChanged: controller.setPhone,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(9),
                              ],
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: titleC,
                                fontWeight: FontWeight.w700,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "077 000 000",
                                hintStyle: GoogleFonts.inter(
                                  color: subC.withOpacity(0.35),
                                  fontWeight: FontWeight.w500,
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Bouton Principal CTA
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
                        onPressed: controller.isLoading.value ? null : controller.sendOtp,
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
                          "Continuer",
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
              const SizedBox(height: 40),

              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "En continuant, vous acceptez nos Conditions d'utilisation",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: subC.withOpacity(0.6),
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
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