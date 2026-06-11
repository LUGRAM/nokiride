import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // ─────────────────────────────────────────────
  // DARK — Premium Organic (Dark Green)
  // ─────────────────────────────────────────────
  static ThemeData get dark {
    final base = ThemeData.dark();

    return base.copyWith(
      brightness: Brightness.dark,

      scaffoldBackgroundColor: AppColors.bgDark,

      colorScheme: const ColorScheme.dark(
        primary:       AppColors.emeraldPrimary,
        onPrimary:     Colors.white,
        secondary:     AppColors.neonYellow,
        onSecondary:   AppColors.darkGreenBase,
        surface:       AppColors.bgDarkSurface,
        onSurface:     AppColors.textDarkPrimary,
        error:         AppColors.error,
        onError:       Colors.white,
      ),

      textTheme: _buildTextTheme(AppColors.textDarkPrimary, AppColors.textDarkSub),

      appBarTheme: const AppBarTheme(
        backgroundColor:    AppColors.bgDark,
        elevation:          0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness:          Brightness.dark,
          statusBarIconBrightness:      Brightness.light,
          systemNavigationBarColor:     AppColors.bgDark,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          color:      AppColors.textDarkPrimary,
          fontSize:   18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: AppColors.textDarkPrimary),
      ),

      cardTheme: CardThemeData(
        color:        AppColors.bgDarkSurface,
        elevation:    0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled:              true,
        fillColor:           AppColors.bgDarkSurface,
        border:              _inputBorder(AppColors.borderDark),
        enabledBorder:       _inputBorder(AppColors.borderDark),
        focusedBorder:       _inputBorder(AppColors.emeraldPrimary),
        hintStyle:           const TextStyle(color: AppColors.textDarkMuted, fontSize: 14),
        contentPadding:      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:  AppColors.emeraldPrimary,
          foregroundColor:  Colors.white,
          elevation:        0,
          shadowColor:      Colors.transparent,
          minimumSize:      const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor:     AppColors.bgDark,
        selectedItemColor:   AppColors.neonYellow,
        unselectedItemColor: AppColors.textDarkMuted,
        elevation:           0,
      ),

      dividerColor: AppColors.borderDark,
      dividerTheme: const DividerThemeData(color: AppColors.borderDark, thickness: 1),
    );
  }

  // ─────────────────────────────────────────────
  // LIGHT — Clean Slate (Slate & Off White)
  // ─────────────────────────────────────────────
  static ThemeData get light {
    final base = ThemeData.light();

    return base.copyWith(
      brightness: Brightness.light,

      scaffoldBackgroundColor: AppColors.bgLight,

      colorScheme: const ColorScheme.light(
        primary:       AppColors.emeraldPrimary,
        onPrimary:     Colors.white,
        secondary:     AppColors.emeraldPrimary,
        onSecondary:   Colors.white,
        surface:       AppColors.bgLightSurface,
        onSurface:     AppColors.textLightPrimary,
        error:         AppColors.error,
        onError:       Colors.white,
      ),

      textTheme: _buildTextTheme(AppColors.textLightPrimary, AppColors.textLightSub),

      appBarTheme: const AppBarTheme(
        backgroundColor:    AppColors.bgLight,
        elevation:          0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness:          Brightness.light,
          statusBarIconBrightness:      Brightness.dark,
          systemNavigationBarColor:     AppColors.bgLight,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          color:      AppColors.textLightPrimary,
          fontSize:   18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: AppColors.textLightPrimary),
      ),

      cardTheme: CardThemeData(
        color:        AppColors.bgLightSurface,
        elevation:    2,
        shadowColor:  Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled:              true,
        fillColor:           AppColors.bgLightSurface,
        border:              _inputBorder(AppColors.borderLight),
        enabledBorder:       _inputBorder(AppColors.borderLight),
        focusedBorder:       _inputBorder(AppColors.emeraldPrimary),
        hintStyle:           const TextStyle(color: AppColors.textLightMuted, fontSize: 14),
        contentPadding:      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:  AppColors.emeraldPrimary,
          foregroundColor:  Colors.white,
          elevation:        0,
          shadowColor:      Colors.transparent,
          minimumSize:      const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor:     AppColors.bgLightSurface,
        selectedItemColor:   AppColors.emeraldPrimary,
        unselectedItemColor: AppColors.textLightMuted,
        elevation:           0,
      ),

      dividerColor: AppColors.borderLight,
      dividerTheme: const DividerThemeData(color: AppColors.borderLight, thickness: 1),
    );
  }

  // ─────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge:  _ts(32, FontWeight.w900, primary),
      displayMedium: _ts(28, FontWeight.w900, primary),
      headlineLarge: _ts(24, FontWeight.w800, primary),
      headlineMedium:_ts(20, FontWeight.w800, primary),
      headlineSmall: _ts(18, FontWeight.w800, primary),
      titleLarge:    _ts(17, FontWeight.w800, primary),
      titleMedium:   _ts(15, FontWeight.w700, primary),
      titleSmall:    _ts(13, FontWeight.w700, primary),
      bodyLarge:     _ts(16, FontWeight.w500, primary),
      bodyMedium:    _ts(14, FontWeight.w500, secondary),
      bodySmall:     _ts(12, FontWeight.w500, secondary),
      labelLarge:    _ts(14, FontWeight.w800, primary),
      labelMedium:   _ts(12, FontWeight.w700, primary),
      labelSmall:    _ts(11, FontWeight.w700, secondary),
    );
  }

  static TextStyle _ts(double size, FontWeight w, Color c) =>
      TextStyle(fontSize: size, fontWeight: w, color: c, letterSpacing: -0.5);

  static OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: color, width: 1.5),
  );
}
