import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/app_button.dart';
import '../../../app/widgets/app_text_field.dart';
import '../../../app/widgets/gradient_background.dart';
import '../controller/password_reset_controller.dart';
import '../widget/gabon_phone_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final controller = Get.find<PasswordResetController>();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Mot de passe oublié',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 32),
                        if (controller.step.value == PasswordResetStep.phone)
                          GabonPhoneField(
                            onChanged: (value) => phoneController.text = value,
                          ),
                        if (controller.step.value == PasswordResetStep.otp)
                          Pinput(
                            length: 6,
                            onChanged: (value) => controller.code.value = value,
                          ),
                        if (controller.step.value == PasswordResetStep.password)
                          AppTextField(
                            hint: 'Nouveau mot de passe',
                            icon: Icons.lock_reset,
                            obscure: true,
                            controller: passwordController,
                            hintStyle: TextStyle(
                              color: AppColors.textSub(context),
                            ),
                          ),
                        const SizedBox(height: 24),
                        AppButton(
                          label: controller.isLoading.value
                              ? 'Chargement...'
                              : 'Continuer',
                          loading: controller.isLoading.value,
                          onTap: () {
                            switch (controller.step.value) {
                              case PasswordResetStep.phone:
                                controller.requestOtp(phoneController.text);
                              case PasswordResetStep.otp:
                                controller.verifyOtp(controller.code.value);
                              case PasswordResetStep.password:
                                controller
                                    .resetPassword(passwordController.text);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        Text(
                          controller.phone.value,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSub(context)),
                        ),
                      ],
                    )),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
