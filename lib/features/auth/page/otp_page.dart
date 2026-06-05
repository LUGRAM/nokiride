import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import '../../../app/theme/app_colors.dart';
import '../controller/auth_controller.dart';

class OtpPage extends GetView<AuthController> {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;

    // Changement d'accent : Jaune Acide électrisant en Dark mode pour les composants OTP
    final accentColor = isDark ? AppColors.neonYellow : AppColors.emeraldPrimary;
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC = isDark ? AppColors.textDarkSub : AppColors.textLightSub;
    final inputBg = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    final defaultPinTheme = PinTheme(
      width: 62,
      height: 62,
      textStyle: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: titleC,
      ),
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1.5),
      ),
    );

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bouton Retour Flottant Épuré
              GestureDetector(
                onTap: Get.back,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: inputBg.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_back_rounded, color: titleC, size: 22),
                ),
              ),
              const SizedBox(height: 36),

              Text(
                "Vérification",
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: titleC,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => Text(
                "Code envoyé au +241 ${controller.phone.value}",
                style: GoogleFonts.inter(fontSize: 14, color: subC, fontWeight: FontWeight.w500),
              )),
              const SizedBox(height: 16),

              // Badge de Code de Test Organique
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: accentColor.withOpacity(0.2), width: 1),
                ),
                child: Text(
                  "Code de test : 1234",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: accentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 44),

              // Saisie du Code PIN (Pinput)
              Center(
                child: Pinput(
                  length: 4,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: Border.all(color: accentColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  onCompleted: (v) {
                    controller.setOtp(v);
                    controller.verifyOtp();
                  },
                ),
              ),
              const SizedBox(height: 40),

              // Bouton de Vérification
              Obx(() => SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.emeraldPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: controller.isLoading.value ? null : controller.verifyOtp,
                  child: controller.isLoading.value
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                      : Text(
                    "Vérifier",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textDarkPrimary : Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              )),
              const SizedBox(height: 24),

              // Renvoyer le Code
              Center(
                child: TextButton(
                  onPressed: controller.sendOtp,
                  style: TextButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                  ),
                  child: Text(
                    "Renvoyer le code",
                    style: GoogleFonts.inter(
                      color: accentColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
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