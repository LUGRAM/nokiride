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

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final AuthController _controller = Get.find<AuthController>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
        Get.snackbar(
          "error".tr,
          "password_mismatch".tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }
      _controller.setName(_nameCtrl.text);
      _controller.phone.value = _phoneCtrl.text;
      _controller.sendOtp();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final titleC = AppColors.textPrimary(context);
    final subC = AppColors.textSub(context);
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
            child: Padding(
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
                    const SizedBox(height: 10),
                    
                    // En-tête
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.accent(context).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.person_add_rounded,
                              color: AppColors.accent(context),
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "register_title".tr,
                            style: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: titleC,
                              letterSpacing: -1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "register_subtitle".tr,
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
                    
                    const SizedBox(height: 40),

                    // Champ Nom complet
                    AppTextField(
                      hint: 'name_hint'.tr,
                      icon: Icons.person_outline_rounded,
                      controller: _nameCtrl,
                      hintStyle: hintStyle,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'name_hint'.tr : null,
                    ),

                    const SizedBox(height: 16),

                    // Champ téléphone
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
                      cursorColor: AppColors.accent(context),
                      decoration: InputDecoration(
                        hintText: "phone_hint".tr,
                        hintStyle: hintStyle,
                        counterText: "",
                      ),
                      onChanged: (phone) => _phoneCtrl.text = phone.completeNumber,
                    ),

                    const SizedBox(height: 16),

                    // Champ Mot de passe
                    AppTextField(
                      hint: 'password_hint'.tr,
                      icon: Icons.lock_outline_rounded,
                      obscure: true,
                      controller: _passwordCtrl,
                      hintStyle: hintStyle,
                      validator: (v) => (v == null || v.length < 6) ? 'password_too_short'.tr : null,
                    ),

                    const SizedBox(height: 16),

                    // Confirmation Mot de passe
                    AppTextField(
                      hint: 'confirm_password_hint'.tr,
                      icon: Icons.lock_reset_rounded,
                      obscure: true,
                      controller: _confirmPasswordCtrl,
                      hintStyle: hintStyle,
                      validator: (v) => (v == null || v.isEmpty) ? 'confirm_required'.tr : null,
                    ),

                    const SizedBox(height: 32),

                    // Bouton Principal
                    Obx(() => AppButton(
                      label: _controller.isLoading.value ? "sending_code".tr : "register_btn".tr,
                      loading: _controller.isLoading.value,
                      onTap: _submit,
                    )),

                    const SizedBox(height: 32),

                    // Lien Connexion
                    RichText(
                      text: TextSpan(
                        text: "already_have_account".tr,
                        style: GoogleFonts.inter(
                          color: subC, 
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: "login_btn".tr,
                            style: GoogleFonts.inter(
                              color: AppColors.accent(context),
                              fontWeight: FontWeight.w800,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => Get.offAllNamed(Routes.login),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
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
