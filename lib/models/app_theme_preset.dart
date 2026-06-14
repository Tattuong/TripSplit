import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';

class AppThemePreset {
  final String id;
  final Color primary;
  final Color primaryLight;
  final Color background;
  final Color surface;
  final Color darkBackground;
  final Color darkSurface;
  final LinearGradient headerGradient;
  final LinearGradient balanceGradient;

  const AppThemePreset({
    required this.id,
    required this.primary,
    required this.primaryLight,
    required this.background,
    required this.surface,
    required this.darkBackground,
    required this.darkSurface,
    required this.headerGradient,
    required this.balanceGradient,
  });

  ThemeData lightTheme() => _buildTheme(
        brightness: Brightness.light,
        scaffold: background,
        surfaceColor: surface,
        onSurface: AppColors.onSurface,
      );

  ThemeData darkTheme() => _buildTheme(
        brightness: Brightness.dark,
        scaffold: darkBackground,
        surfaceColor: darkSurface,
        onSurface: const Color(0xFFF1F5F9),
      );

  ThemeData _buildTheme({
    required Brightness brightness,
    required Color scaffold,
    required Color surfaceColor,
    required Color onSurface,
  }) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffold,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: primaryLight,
              secondary: primary,
              surface: surfaceColor,
              onSurface: onSurface,
              onPrimary: AppColors.onPrimary,
            )
          : ColorScheme.light(
              primary: primary,
              secondary: primaryLight,
              surface: surfaceColor,
              onPrimary: AppColors.onPrimary,
              onSurface: onSurface,
            ),
      textTheme: GoogleFonts.outfitTextTheme(isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: onSurface),
        iconTheme: IconThemeData(color: onSurface),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: isDark ? primaryLight : primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 6,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? darkSurface : AppColors.surfaceVariant,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: isDark ? primaryLight : primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

class AppThemePresets {
  AppThemePresets._();

  static const AppThemePreset defaultPreset = AppThemePreset(
    id: 'theme_default',
    primary: AppColors.primary,
    primaryLight: AppColors.primaryLight,
    background: AppColors.background,
    surface: AppColors.surface,
    darkBackground: AppColors.darkBackground,
    darkSurface: AppColors.darkSurface,
    headerGradient: AppColors.headerGradient,
    balanceGradient: AppColors.heroGradient,
  );

  static const AppThemePreset sunset = AppThemePreset(
    id: 'theme_sunset',
    primary: Color(0xFFE17055),
    primaryLight: Color(0xFFFF7675),
    background: Color(0xFFFFF5F3),
    surface: Color(0xFFFFFFFF),
    darkBackground: Color(0xFF2D1B1B),
    darkSurface: Color(0xFF4A2C2C),
    headerGradient: LinearGradient(colors: [Color(0xFFD63031), Color(0xFFE17055), Color(0xFFFF7675)]),
    balanceGradient: LinearGradient(colors: [Color(0xFFE17055), Color(0xFFFF7675)]),
  );

  static const AppThemePreset midnight = AppThemePreset(
    id: 'theme_midnight',
    primary: Color(0xFF0984E3),
    primaryLight: Color(0xFF74B9FF),
    background: Color(0xFFF0F8FF),
    surface: Color(0xFFFFFFFF),
    darkBackground: Color(0xFF0C1B2A),
    darkSurface: Color(0xFF1A2F45),
    headerGradient: LinearGradient(colors: [Color(0xFF0652DD), Color(0xFF0984E3), Color(0xFF74B9FF)]),
    balanceGradient: LinearGradient(colors: [Color(0xFF0984E3), Color(0xFF74B9FF)]),
  );

  static const AppThemePreset tropical = AppThemePreset(
    id: 'theme_tropical',
    primary: Color(0xFF00B894),
    primaryLight: Color(0xFF55EFC4),
    background: Color(0xFFF0FFF8),
    surface: Color(0xFFFFFFFF),
    darkBackground: Color(0xFF0D2818),
    darkSurface: Color(0xFF1A3D2A),
    headerGradient: LinearGradient(colors: [Color(0xFF00A085), Color(0xFF00B894), Color(0xFF55EFC4)]),
    balanceGradient: LinearGradient(colors: [Color(0xFF00B894), Color(0xFF55EFC4)]),
  );

  static const AppThemePreset sakura = AppThemePreset(
    id: 'theme_sakura',
    primary: Color(0xFFFD79A8),
    primaryLight: Color(0xFFFFB8D0),
    background: Color(0xFFFFF0F5),
    surface: Color(0xFFFFFFFF),
    darkBackground: Color(0xFF3D1F2E),
    darkSurface: Color(0xFF5C2D42),
    headerGradient: LinearGradient(colors: [Color(0xFFE84393), Color(0xFFFD79A8), Color(0xFFFFB8D0)]),
    balanceGradient: LinearGradient(colors: [Color(0xFFFD79A8), Color(0xFFFFB8D0)]),
  );

  static const Map<String, AppThemePreset> byId = {
    'theme_default': defaultPreset,
    'theme_sunset': sunset,
    'theme_midnight': midnight,
    'theme_tropical': tropical,
    'theme_sakura': sakura,
  };

  static AppThemePreset get(String? id) => byId[id] ?? defaultPreset;
}

class DashboardBackground {
  final String id;
  final LinearGradient gradient;

  const DashboardBackground({required this.id, required this.gradient});

  static const DashboardBackground defaultBg = DashboardBackground(
    id: 'bg_default',
    gradient: AppColors.heroGradient,
  );

  static const DashboardBackground ticket = DashboardBackground(
    id: 'bg_ticket',
    gradient: LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE), Color(0xFFFF7675)]),
  );

  static const DashboardBackground ocean = DashboardBackground(
    id: 'bg_ocean',
    gradient: LinearGradient(colors: [Color(0xFF0984E3), Color(0xFF74B9FF), Color(0xFF81ECEC)]),
  );

  static const DashboardBackground mountain = DashboardBackground(
    id: 'bg_mountain',
    gradient: LinearGradient(colors: [Color(0xFF2D3436), Color(0xFF636E72), Color(0xFFB2BEC3)]),
  );

  static const Map<String, DashboardBackground> byId = {
    'bg_default': defaultBg,
    'bg_ticket': ticket,
    'bg_ocean': ocean,
    'bg_mountain': mountain,
  };

  static DashboardBackground get(String? id) => byId[id] ?? defaultBg;
}
