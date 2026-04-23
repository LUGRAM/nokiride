import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../../app/theme/app_colors.dart';
import '../controller/auth_controller.dart';

class OtpPage extends GetView<AuthController> {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final primary = isDark ? AppColors.primaryBlue : AppColors.primaryGreen;
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC = isDark ? AppColors.textDarkSub : AppColors.textLightSub;
    final inputBg = isDark ? AppColors.bgDarkSurface : AppColors.bgLightSurface;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    final defaultPinTheme = PinTheme(
      width: 60, height: 60,
      textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: titleC),
      decoration: BoxDecoration(color: inputBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: border, width: 1.5)),
    );

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(onTap: Get.back, child: Icon(Icons.arrow_back_rounded, color: titleC)),
              const SizedBox(height: 32),
              Text("Vérification", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: titleC, letterSpacing: -.4)),
              const SizedBox(height: 8),
              Obx(() => Text("Code envoyé au +241 ${controller.phone.value}", style: TextStyle(fontSize: 14, color: subC))),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: primary.withOpacity(.12), borderRadius: BorderRadius.circular(8)),
                child: Text("Code de test : 1234", style: TextStyle(fontSize: 12, color: primary, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 40),
              Center(
                child: Pinput(
                  length: 4,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(border: Border.all(color: primary, width: 2)),
                  ),
                  onCompleted: (v) { controller.setOtp(v); controller.verifyOtp(); },
                ),
              ),
              const SizedBox(height: 32),
              Obx(() => SizedBox(
                width: double.infinity, height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  onPressed: controller.isLoading.value ? null : controller.verifyOtp,
                  child: controller.isLoading.value
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text("Vérifier", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              )),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: controller.sendOtp,
                  child: Text("Renvoyer le code", style: TextStyle(color: primary, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
