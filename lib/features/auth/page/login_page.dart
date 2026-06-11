import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/app_button.dart';
import '../../../app/widgets/app_text_field.dart';
import '../../../app/widgets/gradient_background.dart';
import '../../../app/widgets/quick_help_menu.dart';
import '../controller/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final AuthController _controller = Get.find<AuthController>();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _controller.login(
      _phoneCtrl.text,
      _passwordCtrl.text,
    );

    if (success) {
      Get.offAllNamed(Routes.home);
    } else {
      Get.snackbar(
        "login_failed".tr,
        "login_error".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final titleC = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final subC = isDark ? AppColors.textDarkSub : AppColors.textLightSub;
    final hintStyle = GoogleFonts.inter(
      color: subC.withValues(alpha: 0.4),
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              height: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.08,
                vertical: size.height * 0.02,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.topRight,
                      child: QuickHelpMenu(),
                    ),
                    const Spacer(flex: 2),
                    
                    // En-tête avec Logo ou Texte
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.emeraldPrimary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.directions_bike_rounded,
                              color: AppColors.emeraldPrimary,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "welcome_title".tr,
                            style: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: titleC,
                              letterSpacing: -1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "login_subtitle".tr,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: subC,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Spacer(),

                    // Champ téléphone avec IntlPhoneField
                    IntlPhoneField(
                      initialCountryCode: 'GA',
                      invalidNumberMessage: "phone_number".tr,
                      style: GoogleFonts.inter(
                        color: titleC, 
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      dropdownTextStyle: GoogleFonts.inter(
                        color: titleC,
                        fontWeight: FontWeight.w600,
                      ),
                      cursorColor: AppColors.emeraldPrimary,
                      decoration: InputDecoration(
                        hintText: "phone_hint".tr,
                        hintStyle: hintStyle,
                        counterText: "",
                      ),
                      onChanged: (phone) => _phoneCtrl.text = phone.completeNumber,
                    ),

                    const SizedBox(height: 16),

                    // Champ Mot de passe (AppTextField)
                    AppTextField(
                      hint: 'password_hint'.tr,
                      icon: Icons.lock_outline_rounded,
                      obscure: true,
                      controller: _passwordCtrl,
                      hintStyle: hintStyle,
                      validator: (v) => (v == null || v.isEmpty) ? 'password_hint'.tr : null,
                    ),

                    const SizedBox(height: 12),
                    
                    // Mot de passe oublié ?
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {}, // TODO: Mdp oublié
                        child: Text(
                          "forgot_password".tr,
                          style: GoogleFonts.inter(
                            color: AppColors.emeraldPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Bouton Principal
                    Obx(() => AppButton(
                      label: _controller.isLoading.value ? "logging_in".tr : "login_btn".tr,
                      loading: _controller.isLoading.value,
                      onTap: _submit,
                    )),

                    const SizedBox(height: 32),

                    // Lien Inscription
                    RichText(
                      text: TextSpan(
                        text: "no_account".tr,
                        style: GoogleFonts.inter(
                          color: subC, 
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: "register_btn".tr,
                            style: GoogleFonts.inter(
                              color: isDark ? AppColors.neonYellow : AppColors.emeraldPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => Get.offAllNamed(Routes.register),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 3),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
