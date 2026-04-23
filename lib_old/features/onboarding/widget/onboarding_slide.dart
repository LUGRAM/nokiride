import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../model/onboarding_model.dart';
import '../../../app/theme/app_colors.dart';

class OnboardingSlide extends StatelessWidget {
  final OnboardingModel data;

  const OnboardingSlide({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Lottie.asset(
              data.lottiePath,
              width: 260,
              height: 260,
              fit: BoxFit.contain,
              repeat: true,
            ),
            const SizedBox(height: 50),
            Text(
              data.title,
              style: GoogleFonts.playfair(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              data.description,
              style: const TextStyle(
                fontSize: 17.5,
                height: 1.45,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 100), // Espace pour les boutons en bas
          ],
        ),
      ),
    );
  }
}