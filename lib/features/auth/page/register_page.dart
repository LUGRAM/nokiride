import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../controller/auth_controller.dart';

class RegisterPage extends GetView<AuthController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final primary = isDark ? AppColors.primaryBlue : AppColors.primaryGreen;
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC = isDark ? AppColors.textDarkSub : AppColors.textLightSub;
    final inputBg = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text("Créer mon profil", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: titleC, letterSpacing: -.4)),
              const SizedBox(height: 8),
              Text("Comment devons-nous vous appeler ?", style: TextStyle(fontSize: 14, color: subC)),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(color: inputBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
                child: Row(
                  children: [
                    Icon(Icons.person_outline_rounded, color: subC, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        onChanged: controller.setName,
                        autofocus: true,
                        style: TextStyle(fontSize: 15, color: titleC, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          border: InputBorder.none, hintText: "Votre prénom et nom",
                          hintStyle: TextStyle(color: subC),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Obx(() => SizedBox(
                width: double.infinity, height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  onPressed: controller.isLoading.value ? null : controller.register,
                  child: controller.isLoading.value
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text("Commencer", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
