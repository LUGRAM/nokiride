import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/app_button.dart';
import '../../../app/widgets/app_text_field.dart';
import '../../../app/widgets/gradient_background.dart';
import '../../../app/widgets/quick_help_menu.dart';
import '../controller/auth_controller.dart';
import '../widget/gabon_phone_field.dart';

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
      Get.offAllNamed(_controller.routeForUser(null));
    } else {
      Get.snackbar(
        "login_failed".tr,
        _controller.lastError.value.isNotEmpty
            ? _controller.lastError.value
            : "login_error".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width < 600 ? 24 : 32,
                    vertical: 20,
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
                        _AuthHeader(
                          icon: Icons.directions_bike_rounded,
                          title: 'welcome_title'.tr,
                          subtitle: 'login_subtitle'.tr,
                        ),
                        const SizedBox(height: 40),
                        GabonPhoneField(
                          onChanged: (phone) => _phoneCtrl.text = phone,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          hint: 'password_hint'.tr,
                          icon: Icons.lock_outline_rounded,
                          obscure: true,
                          controller: _passwordCtrl,
                          hintStyle: hintStyle,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'password_hint'.tr
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Get.toNamed(Routes.forgotPassword),
                            child: Text(
                              'forgot_password'.tr,
                              style: GoogleFonts.inter(
                                color: AppColors.accent(context),
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Obx(
                          () => AppButton(
                            label: _controller.isLoading.value
                                ? 'logging_in'.tr
                                : 'login_btn'.tr,
                            loading: _controller.isLoading.value,
                            onTap: _submit,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _AuthFooter(
                          prompt: 'no_account'.tr,
                          action: 'register_btn'.tr,
                          onTap: () => Get.offAllNamed(Routes.register),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accent(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.accent(context), size: 28),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppColors.textSub(context),
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthFooter extends StatelessWidget {
  const _AuthFooter({
    required this.prompt,
    required this.action,
    required this.onTap,
  });

  final String prompt;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: prompt,
        style: GoogleFonts.inter(
          color: AppColors.textSub(context),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        children: [
          TextSpan(
            text: action,
            style: GoogleFonts.inter(
              color: AppColors.accent(context),
              fontWeight: FontWeight.w800,
            ),
            recognizer: TapGestureRecognizer()..onTap = onTap,
          ),
        ],
      ),
    );
  }
}
