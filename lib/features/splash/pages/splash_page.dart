import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/services/auth_api_service.dart';
import '../../../core/storage/app_storage.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  bool _isRouting = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 3), _redirect);
  }

  Future<void> _redirect() async {
    if (_isRouting || !mounted) return;
    _isRouting = true;
    final box = GetStorage();
    final token = await AppStorage.token;
    final hasSeenOnboarding = box.read('hasSeenOnboarding') ?? false;

    if (token != null && token.toString().trim().isNotEmpty) {
      try {
        final data = await AuthApiService().me();
        await AppStorage.saveUser(
          Map<String, dynamic>.from(data['user'] as Map),
        );
        Get.offAllNamed(Routes.home);
      } on ApiException {
        await AppStorage.clearAuth();
        Get.offAllNamed(Routes.login);
      }
    } else if (hasSeenOnboarding) {
      Get.offAllNamed(Routes.login);
    } else {
      Get.offAllNamed(Routes.onboarding);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AppColors.bgDark,
              AppColors.accentDark,
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fade,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 32),

                // ── Nom de la Marque ──
                Text(
                  'NokiRide',
                  style: GoogleFonts.inter(
                    color: const Color(0xffFFFDEE),
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 10),
                // ── Slogan ──
                Text(
                  'Mobilité urbaine simplifiée',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
