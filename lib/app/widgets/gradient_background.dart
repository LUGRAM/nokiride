import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final topColor    = isDark ? AppColors.bgDark         : AppColors.bgLight;
    final bottomColor = isDark ? AppColors.bgDarkElevated : AppColors.bgLightSurface;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [topColor, bottomColor],
          begin:  Alignment.topCenter,
          end:    Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}
