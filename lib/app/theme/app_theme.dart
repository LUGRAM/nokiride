import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // ─────────────────────────────────────────────
  // DARK — Charte CEMAC Production (Inspired by Telegram)
  // ─────────────────────────────────────────────
  static ThemeData get dark {
    final base = ThemeData.dark();

    return base.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,

      colorScheme: const ColorScheme.dark(
        primary:       AppColors.accentDark,
        onPrimary:     AppColors.green950,
        secondary:     AppColors.green400,
        onSecondary:   AppColors.bgDark,
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
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderDark, width: 0.5),
        ),
      ),

      dividerColor: AppColors.borderDark,
      dividerTheme: const DividerThemeData(color: AppColors.borderDark, thickness: 0.5),

      inputDecorationTheme: InputDecorationTheme(
        filled:              true,
        fillColor:           AppColors.bgDarkSurface,
        border:              _inputBorder(AppColors.borderDark),
        enabledBorder:       _inputBorder(AppColors.borderDark),
        focusedBorder:       _inputBorder(AppColors.accentDark),
        hintStyle:           const TextStyle(color: AppColors.textDarkMuted, fontSize: 14),
        contentPadding:      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:  AppColors.accentDark,
          foregroundColor:  AppColors.green950,
          elevation:        0,
          minimumSize:      const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accentDark,
          foregroundColor: AppColors.green950,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),

      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.green300,
        selectionColor: Color(0x5522C55E),
        selectionHandleColor: AppColors.green500,
      ),

      splashColor: AppColors.green500.withValues(alpha: .10),
      highlightColor: AppColors.green500.withValues(alpha: .06),
    );
  }

  // ─────────────────────────────────────────────
  // LIGHT — Charte CEMAC Clean Edition
  // ─────────────────────────────────────────────
  static ThemeData get light {
    final base = ThemeData.light();

    return base.copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgLight,

      colorScheme: const ColorScheme.light(
        primary:       AppColors.accentLight,
        onPrimary:     Colors.white,
        secondary:     AppColors.green700,
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
        elevation:    0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderLight, width: 0.5),
        ),
      ),

      dividerColor: AppColors.borderLight,
      dividerTheme: const DividerThemeData(color: AppColors.borderLight, thickness: 0.5),

      inputDecorationTheme: InputDecorationTheme(
        filled:              true,
        fillColor:           AppColors.bgLightSurface,
        border:              _inputBorder(AppColors.borderLight),
        enabledBorder:       _inputBorder(AppColors.borderLight),
        focusedBorder:       _inputBorder(AppColors.accentLight),
        hintStyle:           const TextStyle(color: AppColors.textLightMuted, fontSize: 14),
        contentPadding:      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:  AppColors.accentLight,
          foregroundColor:  Colors.white,
          elevation:        0,
          minimumSize:      const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accentLight,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),

      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.green700,
        selectionColor: Color(0x44DCFCE7),
        selectionHandleColor: AppColors.green700,
      ),

      splashColor: AppColors.green700.withValues(alpha: .08),
      highlightColor: AppColors.green700.withValues(alpha: .05),
    );
  }

  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge:  _ts(32, FontWeight.w900, primary),
      headlineLarge: _ts(24, FontWeight.w800, primary),
      titleLarge:    _ts(17, FontWeight.w800, primary),
      bodyLarge:     _ts(16, FontWeight.w500, primary),
      bodyMedium:    _ts(14, FontWeight.w500, secondary),
      labelSmall:    _ts(11, FontWeight.w700, secondary),
    );
  }

  static TextStyle _ts(double size, FontWeight w, Color c) =>
      TextStyle(fontSize: size, fontWeight: w, color: c, letterSpacing: -0.5);

  static OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color, width: 1.0),
  );
}
