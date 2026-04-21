import 'package:flutter/material.dart';

class OnboardingModel {
  final String title;
  final String description;
  final String lottiePath;
  final String emoji;           // Pour fallback si Lottie pas encore prêt
  final Color bgColor;

  OnboardingModel({
    required this.title,
    required this.description,
    required this.lottiePath,
    this.emoji = "",
    required this.bgColor,
  });
}