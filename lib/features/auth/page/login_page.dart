import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../controller/auth_controller.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final primary = isDark ? AppColors.primaryBlue : AppColors.primaryGreen;
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC = isDark ? AppColors.textDarkSub : AppColors.textLightSub;
    final cardBg = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final inputBg = isDark ? AppColors.bgDarkElevated : AppColors.bgLightInput;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: primary.withOpacity(.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: primary.withOpacity(.25)),
                ),
                child: Icon(Icons.sports_motorsports_rounded, color: primary, size: 30),
              ),
              const SizedBox(height: 24),
              Text("Bienvenue sur NokiRide", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: titleC, letterSpacing: -.4)),
              const SizedBox(height: 8),
              Text("Entrez votre numéro de téléphone", style: TextStyle(fontSize: 15, color: subC)),
              const SizedBox(height: 36),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(22), border: Border.all(color: border)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Numéro de téléphone", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: subC)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(color: inputBg, borderRadius: BorderRadius.circular(12)),
                          child: Text("+241", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: titleC)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(color: inputBg, borderRadius: BorderRadius.circular(12)),
                            child: TextField(
                              onChanged: controller.setPhone,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)],
                              style: TextStyle(fontSize: 15, color: titleC, fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                border: InputBorder.none, hintText: "077 000 000",
                                hintStyle: TextStyle(color: subC, fontWeight: FontWeight.w400),
                                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Obx(() => SizedBox(
                      width: double.infinity, height: 52,
                      child: FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                        onPressed: controller.isLoading.value ? null : controller.sendOtp,
                        child: controller.isLoading.value
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text("Continuer", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text("En continuant, vous acceptez nos Conditions d'utilisation",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: subC, height: 1.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
