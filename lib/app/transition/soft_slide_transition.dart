import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SoftSlideTransition extends CustomTransition {
  @override
  Widget buildTransition(
      BuildContext context,
      Curve? curve,
      Alignment? alignment,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    // Glissement très léger de droite vers gauche
    final slide = Tween<Offset>(
      begin: const Offset(0.04, 0), // 🔹 très subtil
      end: Offset.zero,
    ).animate(curved);

    // Opacité quasi constante (effet "soft")
    final fade = Tween<double>(
      begin: 0.97,
      end: 1.0,
    ).animate(curved);

    return SlideTransition(
      position: slide,
      child: FadeTransition(
        opacity: fade,
        child: child,
      ),
    );
  }
}
