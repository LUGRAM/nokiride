import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/app_button.dart';
import '../../../app/widgets/gradient_background.dart';
import '../controller/otp_controller.dart';

class OtpPage extends GetView<OtpController> {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final accentColor = AppColors.accent(context);
    final titleC = AppColors.textPrimary(context);
    final subC = AppColors.textSub(context);
    final inputBg = AppColors.surface(context);
    final border = AppColors.divider(context);

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

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: titleC),
            onPressed: () => Get.back(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              height: size.height -
                  MediaQuery.of(context).padding.top -
                  kToolbarHeight -
                  20,
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.08,
                vertical: size.height * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accent(context).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.mark_email_read_rounded,
                      color: AppColors.accent(context),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "otp_title".tr,
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: titleC,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Text(
                        "${'code_sent_to'.tr} ${controller.phone}",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: subC,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      )),

                  const SizedBox(height: 16),

                  const Spacer(),

                  // Saisie du Code PIN (Pinput)
                  Center(
                    child: Obx(() => Pinput(
                          length: controller.otpLength.value,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: defaultPinTheme.copyWith(
                            decoration: defaultPinTheme.decoration!.copyWith(
                              border: Border.all(color: accentColor, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: 0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                          onCompleted: (v) {
                            controller.setCode(v);
                            controller.verify();
                          },
                        )),
                  ),

                  const Spacer(),

                  // Bouton de Vérification
                  Obx(() => AppButton(
                        label: controller.isLoading.value
                            ? "verifying".tr
                            : "verify_btn".tr,
                        loading: controller.isLoading.value,
                        onTap: controller.verify,
                      )),

                  const SizedBox(height: 24),

                  // Renvoyer le Code
                  Center(
                    child: TextButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () => controller.send(resend: true),
                      child: Text(
                        "resend_code".tr,
                        style: GoogleFonts.inter(
                          color: accentColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
