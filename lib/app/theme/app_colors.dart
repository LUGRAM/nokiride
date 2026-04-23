import 'package:flutter/material.dart';

/// Palette NokiRide — double thème Blue-Dark / Light-Green
/// Aucune couleur legacy. Chaque token a un rôle sémantique précis.
class AppColors {

  AppColors._();

  // ════════════════════════════════════════════════
  // BLUE-DARK THEME
  // ════════════════════════════════════════════════

  /// Fond de page principal
  static const Color bgDark         = Color(0xFF07101E);

  /// Surfaces (cards, inputs)
  static const Color bgDarkSurface  = Color(0xFF0D1826);

  /// Cards élevées / sections
  static const Color bgDarkElevated = Color(0xFF152336);

  /// Bottom nav background
  static const Color bgDarkNav      = Color(0xFF0D1D2E);

  // ─── Accent Blue-Dark ────────────────────────
  /// CTA principal (boutons, actions primaires)
  static const Color primaryBlue      = Color(0xFF1B7BFF);

  /// Textes et icônes actifs sur fond dark
  static const Color primaryBlueLight = Color(0xFF56AEFF);

  /// Halo / fill derrière icône bleue
  static const Color primaryBlueFill  = Color(0x261B7BFF); // 15%

  // ─── Accent Green (dark) ─────────────────────
  /// Succès, validation, driver online
  static const Color accentGreenDark  = Color(0xFF00C44F);

  /// Fill vert sur fond dark
  static const Color accentGreenFill  = Color(0x1F00C44F); // 12%

  // ─── Textes Dark ─────────────────────────────
  static const Color textDarkPrimary  = Color(0xFFFFFFFF);
  static const Color textDarkSub      = Color(0x8FFFFFFF); // 56%
  static const Color textDarkMuted    = Color(0x59FFFFFF); // 35%

  // ─── Borders Dark ────────────────────────────
  static const Color borderDark       = Color(0xFF1A3349);
  static const Color borderDarkSubtle = Color(0xFF0F2030); // très subtil

  // ════════════════════════════════════════════════
  // LIGHT-GREEN THEME
  // ════════════════════════════════════════════════

  /// Fond de page
  static const Color bgLight          = Color(0xFFF0F3F6);

  /// Surfaces / cards
  static const Color bgLightSurface   = Color(0xFFFFFFFF);

  /// Input background
  static const Color bgLightInput     = Color(0xFFEEF2F7);

  // ─── Accent Green-Light ──────────────────────
  /// CTA principal light theme
  static const Color primaryGreen     = Color(0xFF00C44F);

  /// Textes / icônes actifs light
  static const Color primaryGreenDark = Color(0xFF009B3E);

  /// Fill vert light
  static const Color primaryGreenFill = Color(0x2600C44F); // 15%

  // ─── Accent Blue (light) ─────────────────────
  /// Actions secondaires, info
  static const Color accentBlueLight  = Color(0xFF1B7BFF);

  /// Fill bleu light
  static const Color accentBlueFill   = Color(0x1F1B7BFF); // 12%

  // ─── Textes Light ────────────────────────────
  static const Color textLightPrimary = Color(0xFF0D1826);
  static const Color textLightSub     = Color(0xFF6B7A8D);
  static const Color textLightMuted   = Color(0xFF9AA3AF);

  // ─── Borders Light ───────────────────────────
  static const Color borderLight      = Color(0xFFE0E6EE);
  static const Color borderLightStrong= Color(0xFFCDD5DF);

  // ════════════════════════════════════════════════
  // SÉMANTIQUE — partagé entre les deux thèmes
  // ════════════════════════════════════════════════

  static const Color success        = Color(0xFF00C44F);
  static const Color successFill    = Color(0x1F00C44F);

  static const Color warning        = Color(0xFFFF9500);
  static const Color warningFill    = Color(0x1FFF9500);

  static const Color error          = Color(0xFFFF3B30);
  static const Color errorFill      = Color(0x1FFF3B30);

  static const Color info           = Color(0xFF1B7BFF);
  static const Color infoFill       = Color(0x1F1B7BFF);

  // ─── Services (couleurs identitaires) ────────
  static const Color serviceMoto    = Color(0xFF1B7BFF); // bleu
  static const Color serviceEnvoi   = Color(0xFF00C44F); // vert
  static const Color serviceMarket  = Color(0xFFFF9500); // orange
  static const Color servicePlan    = Color(0xFFA855F7); // violet

  // ════════════════════════════════════════════════
  // ALIAS DE COMPATIBILITÉ — anciens tokens
  // À supprimer progressivement au fil des refontes
  // ════════════════════════════════════════════════

  /// @deprecated → AppColors.primaryBlue
  static const Color primary          = primaryBlue;

  /// @deprecated → AppColors.primaryBlueLight
  static const Color primaryLight     = primaryBlueLight;

  /// @deprecated → AppColors.bgDark
  static const Color backgroundDark   = bgDark;

  /// @deprecated → AppColors.bgDarkSurface
  static const Color backgroundSecondary = bgDarkSurface;

  /// @deprecated → AppColors.bgDarkElevated
  static const Color surface          = bgDarkElevated;

  /// @deprecated → AppColors.textDarkPrimary
  static const Color textPrimary      = textDarkPrimary;

  /// @deprecated → AppColors.textDarkSub
  static const Color textSecondary    = textDarkSub;

  /// @deprecated → AppColors.textDarkMuted
  static const Color textMuted        = textDarkMuted;

  /// @deprecated → AppColors.borderDark
  static const Color border           = borderDark;

  /// @deprecated → AppColors.accentGreenDark
  static const Color successGreen     = accentGreenDark;
}
