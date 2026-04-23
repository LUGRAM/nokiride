import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';

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
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 3), _redirect);
  }

  void _redirect() {
    if (_isRouting || !mounted) return;
    _isRouting = true;
    final box = GetStorage();
    final token = box.read('auth_token');
    final hasSeenOnboarding = box.read('hasSeenOnboarding') ?? false;
    if (token != null && token.toString().trim().isNotEmpty) {
      Get.offAllNamed(Routes.home);
    } else if (hasSeenOnboarding) {
      Get.offAllNamed(Routes.login);
    } else {
      Get.offAllNamed(Routes.onboarding);
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF0B1220), Color(0xFF111827)],
          ),
        ),
        child: FadeTransition(
          opacity: _fade,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88, height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryBlue.withOpacity(.30), width: 1.5),
                  ),
                  child: const Icon(Icons.sports_motorsports_rounded, color: AppColors.primaryBlue, size: 42),
                ),
                const SizedBox(height: 28),
                Text('NokiRide', style: GoogleFonts.inter(
                  color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -0.6,
                )),
                const SizedBox(height: 8),
                Text('Mobilité urbaine simplifiée', style: GoogleFonts.inter(
                  color: AppColors.textDarkSub, fontSize: 15, fontWeight: FontWeight.w500,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
