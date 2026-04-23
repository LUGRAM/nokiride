import 'package:flutter/material.dart';

abstract class AppConfig {

  AppConfig._();

  static const String appName    = 'NokiRide';
  static const String appVersion = '1.0.0';

  /// Thème actif au démarrage.
  /// Changer en [ThemeMode.light] pour le Light-Green.
  static const ThemeMode defaultThemeMode = ThemeMode.dark;

  // ── Environnement ─────────────────────────
  static const bool isDev = true;
  static const String _prod = 'https://la1gabonaise.com/api';
  static const String _dev = 'http://localhost:8000/api';

  // Android emulator → http://10.0.2.2:8000/api
  // Device physique  → http://<IP_locale>:8000/api
  static String get baseUrl => isDev ? _dev : _prod;

  // ── Timeouts ──────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ── Storage keys ──────────────────────────
  static const String kToken = 'access_token';
  static const String kRefreshToken = 'refresh_token';
  static const String kUser = 'user_data';
  static const String kOnboarding = 'onboarding_done';
  static const String kActiveProfile = 'active_profile';

  // ── App ───────────────────────────────────
  //static const String appName = 'NokiRide';
  //static const String appVersion = '1.0.0';
  static const String supportMail = 'support@nokiride.com';
}