import 'package:flutter/material.dart';

/// Paramètres globaux de l'application
class AppConfig {
  AppConfig._();

  static const String appName    = 'NokiRide';
  static const String appVersion = '1.0.0';

  /// Thème actif au démarrage.
  /// Changer en [ThemeMode.light] pour le Light-Green.
  static const ThemeMode defaultThemeMode = ThemeMode.dark;
}
