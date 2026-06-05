import 'package:flutter/material.dart';

/// Palette NokiRide — Thème Premium Organic (Vert Sombre & Jaune Acide)
class AppColors {
  AppColors._();

  // ════════════════════════════════════════════════
  // BASE COLORS (NOUVELLE PALETTE)
  // ════════════════════════════════════════════════
  
  // Verts profonds
  static const Color darkGreenBase    = Color(0xFF06231D); // Fond Dark
  static const Color darkGreenSurface = Color(0xFF0C342C); // Cartes Dark / Texte Light
  static const Color emeraldPrimary   = Color(0xFF1f9b61); // Couleur de marque  // ou 1f9b61 / 076653
  
  // Accents
  static const Color neonYellow       = Color(0xFFE3EF26); // Accent Punchy
  static const Color lightAcidGreen   = Color(0xFFD0FFE3); // Fond accent léger
  
  // Neutres
  static const Color offWhite         = Color(0xFFFFFDEE); // Fond Light / Texte sur Dark
  static const Color greyMuted        = Color(0xFF9AA3AF);

  // ════════════════════════════════════════════════
  // DARK THEME (Premium Organic)
  // ════════════════════════════════════════════════
  static const Color bgDark         = darkGreenBase;
  static const Color bgDarkSurface  = darkGreenSurface;
  static const Color bgDarkElevated = Color(0xFF124036);
  static const Color borderDark       = Color(0xFF1A453B);

  static const Color textDarkPrimary  = offWhite;
  static const Color textDarkSub      = Color(0xB3FFFDEE); // 70%
  static const Color textDarkMuted    = Color(0x66FFFDEE); // 40%

  // ════════════════════════════════════════════════
  // LIGHT THEME (Clean Organic)
  // ════════════════════════════════════════════════
  static const Color bgLight          = Color(0xFFF7F9F2); // Un peu plus frais que le pur blanc
  static const Color bgLightSurface   = offWhite;
  static const Color bgLightInput     = Color(0xFFE8ECD7);
  static const Color borderLight      = lightAcidGreen;

  static const Color textLightPrimary = darkGreenBase;
  static const Color textLightSub     = Color(0xFF4A5D59);
  static const Color textLightMuted   = Color(0xFF8B9A97);

  // ════════════════════════════════════════════════
  // SÉMANTIQUE & SERVICES
  // ════════════════════════════════════════════════
  static const Color primary        = emeraldPrimary;
  static const Color accent         = neonYellow;
  
  static const Color success        = Color(0xFF27AE60);
  static const Color warning        = Color(0xFFF2994A);
  static const Color error          = Color(0xFFEB5757);

  static const Color serviceMoto    = emeraldPrimary;
  static const Color serviceEnvoi   = Color(0xFF2D9CDB);
  static const Color serviceMarket  = Color(0xFFF2C94C);
  static const Color servicePlan    = Color(0xFF9B51E0);
  
  // ════════════════════════════════════════════════
  // ALIAS DE COMPATIBILITÉ & SÉMANTIQUE DYNAMIQUE
  // ════════════════════════════════════════════════
  static const Color infoFill       = Color(0x1A076653); // emeraldPrimary avec alpha
  static const Color successFill    = Color(0x1A27AE60);
  static const Color warningFill    = Color(0x1AF2994A);
  static const Color errorFill      = Color(0x1AEB5757);

  static const Color accentBlueLight = emeraldPrimary; 
  static const Color accentBlueFill  = infoFill;

  // Compatibilité Legacy
  static const Color primaryBlue      = emeraldPrimary;
  static const Color primaryBlueLight = Color(0xFF4DB6A3);
  static const Color primaryGreen     = emeraldPrimary;
  static const Color primaryGreenDark = Color(0xFF044D3E);
  static const Color primaryGreenFill = Color(0x1A076653);
}
