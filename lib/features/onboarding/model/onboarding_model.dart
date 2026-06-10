import 'package:flutter/material.dart';

class OnboardingSlide {
  final String title;
  final String description;
  final Widget Function(BuildContext context)? iconBuilder;

  const OnboardingSlide({
    required this.title,
    required this.description,
    this.iconBuilder,
  });
}
