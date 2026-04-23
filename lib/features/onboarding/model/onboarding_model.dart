import 'package:flutter/material.dart';
class OnboardingModel {
  final String title, description, emoji, lottiePath;
  final Color bgColor;
  const OnboardingModel({required this.title, required this.description,
    required this.emoji, required this.lottiePath, required this.bgColor});
}
