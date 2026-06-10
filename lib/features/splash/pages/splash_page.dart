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
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
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
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark, // Assure un fallback de couleur uni
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AppColors.bgDarkElevated,
              AppColors.emeraldPrimary
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fade,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Conteneur d'animation Premium ──
                /*Container(
                  width: 96, height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.bgDarkSurface.withOpacity(0.4),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.borderDark.withOpacity(0.6),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkGreenBase.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Lottie.asset(
                      'assets/animations/halo_soft.json',
                      width: 200,
                      height: 200,
                      repeat: true,
                    ),
                  ),
                ),*/
                const SizedBox(height: 32),

                // ── Nom de la Marque ──
                Text(
                  'NokiRide',
                  style: GoogleFonts.inter(
                    color: Color(0xffFFFDEE),
                    //color: AppColors.textDarkPrimary, // OffWhite (#FFFDEE)
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                    textBaseline: TextBaseline.alphabetic,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                // ── Slogan ──
                Text(
                  'Mobilité urbaine simplifiée',
                  style: GoogleFonts.inter(
                    color: AppColors.textDarkPrimary, // Vert adouci à 70%
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}