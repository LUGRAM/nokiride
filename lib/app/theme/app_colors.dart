import 'package:flutter/material.dart';

/// Palette NokiRide — Green Mobility
class AppColors {
  AppColors._();

  // ════════════════════════════════════════════════
  // BRAND SCALE
  // ════════════════════════════════════════════════
  static const Color green950 = Color(0xFF0B1220);
  static const Color green900 = Color(0xFF14532D);
  static const Color green800 = Color(0xFF15803D);
  static const Color green700 = Color(0xFF16A34A);
  static const Color green500 = Color(0xFF22C55E);
  static const Color green400 = Color(0xFF34D399);
  static const Color green300 = Color(0xFF4ADE80);
  static const Color green100 = Color(0xFFDCFCE7);

  // ════════════════════════════════════════════════
  // DARK THEME
  // ════════════════════════════════════════════════
  static const Color bgDark          = Color(0xFF0B1220);
  static const Color bgDarkSurface   = Color(0xFF111827);
  static const Color borderDark      = Color(0xFF334155);
  static const Color accentDark      = green500;
  
  static const Color textDarkPrimary = Color(0xFFE5E7EB);
  static const Color textDarkSub     = Color(0xFF9CA3AF);
  static const Color textDarkMuted   = Color(0x999CA3AF);

  // ════════════════════════════════════════════════
  // LIGHT THEME
  // ════════════════════════════════════════════════
  static const Color bgLight          = Color(0xFFF8FAF8);
  static const Color bgLightSurface   = Color(0xFFFFFFFF);
  static const Color borderLight      = Color(0xFFD1D5DB);
  static const Color accentLight      = green700;

  static const Color textLightPrimary = Color(0xFF0F172A);
  static const Color textLightSub     = Color(0xFF475569);
  static const Color textLightMuted   = Color(0xFF64748B);

  // ════════════════════════════════════════════════
  // SÉMANTIQUE & SERVICES
  // ════════════════════════════════════════════════
  static const Color success        = green500;
  static const Color warning        = Color(0xFFF59E0B);
  static const Color error          = Color(0xFFD95555);

  static const Color serviceMoto    = green700;
  static const Color serviceEnvoi   = green400;
  static const Color serviceMarket  = Color(0xFFEAB308);
  static const Color servicePlan    = Color(0xFF64748B);

  // Compatibilité avec les écrans existants.
  static const Color emeraldPrimary   = green700;
  static const Color bgLightInput     = Color(0xFFF1F5F1);
  static const Color primaryBlue      = green400;
  static const Color primaryGreen     = green700;
  static const Color bgDarkElevated   = Color(0xFF1F2937);
  static const Color infoFill         = Color(0xFF1F2937); 
  static const Color accentBlueFill   = green100; 
  static const Color primaryBlueLight = green400;
  static const Color accentBlueLight  = green700;
  static const Color neonYellow       = Color(0xFFEAB308);
  static const Color darkGreenBase    = green900;
  static const Color darkGreenSurface = green900;

  // Alias pour faciliter le switch dynamique dans le code
  static Color background(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? bgDark : bgLight;
      
  static Color surface(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? bgDarkSurface : bgLightSurface;

  static Color textPrimary(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? textDarkPrimary : textLightPrimary;

  static Color textSub(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? textDarkSub : textLightSub;

  static Color divider(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? borderDark : borderLight;

  static Color accent(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? accentDark : accentLight;
}
