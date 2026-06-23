import 'package:flutter/material.dart';

/// Palette NokiRide — Charte CEMAC Dynamique (Production)
class AppColors {
  AppColors._();

  // ════════════════════════════════════════════════
  // DARK THEME (Telegram Redesign Inspired)
  // ════════════════════════════════════════════════
  static const Color bgDark          = Color(0xFF0B141A); // Fond profond
  static const Color bgDarkSurface   = Color(0xFF182229); // Blocs / Cartes
  static const Color borderDark      = Color(0xFF222C32); // Séparateurs
  static const Color accentDark      = Color(0xFF00A884); // Vert Mint Éclatant
  
  static const Color textDarkPrimary = Color(0xFFFFFFFF); // Titres
  static const Color textDarkSub     = Color(0xFF8696A0); // Gris bleuté
  static const Color textDarkMuted   = Color(0x668696A0);

  // ════════════════════════════════════════════════
  // LIGHT THEME (CEMAC Clean Edition)
  // ════════════════════════════════════════════════
  static const Color bgLight          = Color(0xFFF5F7F5); // Blanc cassé teinté
  static const Color bgLightSurface   = Color(0xFFFFFFFF); // Blanc pur
  static const Color borderLight      = Color(0xFFE0E0E0); // Séparateurs fins
  static const Color accentLight      = Color(0xFF1E3A2F); // Vert sombre identitaire

  static const Color textLightPrimary = Color(0xFF1E3A2F); // Anthracite sombre
  static const Color textLightSub     = Color(0xFF545454); // Noir atténué
  static const Color textLightMuted   = Color(0xFF9AA3AF);

  // ════════════════════════════════════════════════
  // SÉMANTIQUE & SERVICES
  // ════════════════════════════════════════════════
  static const Color success        = Color(0xFF00A884);
  static const Color warning        = Color(0xFFF2994A);
  static const Color error          = Color(0xFFEF5350);

  static const Color serviceMoto    = Color(0xFF00A884);
  static const Color serviceEnvoi   = Color(0xFF2D9CDB);
  static const Color serviceMarket  = Color(0xFFF2C94C);
  static const Color servicePlan    = Color(0xFF9B51E0);

  // Nouvelles couleurs ajoutées pour corriger les erreurs de compilation
  static const Color emeraldPrimary   = Color(0xFF00A884);
  static const Color bgLightInput     = Color(0xFFF0F2F5);
  static const Color primaryBlue      = Color(0xFF2D9CDB);
  static const Color primaryGreen     = Color(0xFF00A884);
  static const Color bgDarkElevated   = Color(0xFF1F2C34);
  static const Color infoFill         = Color(0xFF1F2C34); 
  static const Color accentBlueFill   = Color(0xFFE3F2FD); 
  static const Color primaryBlueLight = Color(0xFF2D9CDB);
  static const Color accentBlueLight  = Color(0xFF1976D2);
  static const Color neonYellow       = Color(0xFFF2C94C);
  static const Color darkGreenBase    = Color(0xFF1E3A2F);
  static const Color darkGreenSurface = Color(0xFF1E3A2F);

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
