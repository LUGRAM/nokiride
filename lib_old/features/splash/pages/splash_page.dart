import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _isRouting = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted || _isRouting) return;

    await _handleLocationPermission();

    if (!mounted || _isRouting) return;

    _redirectAfterBoot();
  }

  Future<void> _handleLocationPermission() async {
    try {
      final bool serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      // Si le GPS/service de localisation est coupé,
      // on ne bloque pas l'utilisateur.
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission =
      await Geolocator.checkPermission();

      // Première demande classique
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        return;
      }

      // Refus définitif : on continue sans bloquer.
      if (permission == LocationPermission.deniedForever) {
        return;
      }

      // whileInUse / always => OK
      return;
    } catch (e) {
      debugPrint('Erreur localisation splash: $e');
      return;
    }
  }

  void _redirectAfterBoot() {
    if (_isRouting || !mounted) return;
    _isRouting = true;

    final box = GetStorage();
    final token = box.read('auth_token') ?? box.read('token');

    final bool isAuthenticated =
        token != null && token.toString().trim().isNotEmpty;

    if (isAuthenticated) {
      Get.offAllNamed(Routes.home);
    } else {
      Get.offAllNamed(Routes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF0B1220),
              Color(0xFF111827),
            ],
            stops: [0.0, 0.90],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/animations/halo_soft.json',
                  width: 200,
                  height: 200,
                  repeat: true,
                ),
                const SizedBox(height: 28),
                Text(
                  'NokiRide',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mobilité urbaine simplifiée',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary.withValues(alpha: 0.82),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
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