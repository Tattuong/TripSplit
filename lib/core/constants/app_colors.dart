import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFFA29BFE);
  static const Color primaryDark = Color(0xFF5B4BD5);

  static const Color accent = Color(0xFFFF7675);
  static const Color accentAlt = Color(0xFFFD79A8);

  static const Color background = Color(0xFFF8F7FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEEEDF8);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF2D3436);
  static const Color onSurfaceVariant = Color(0xFF636E72);

  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFE17055);
  static const Color coin = Color(0xFFFFD93D);

  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color darkSurface = Color(0xFF252542);

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5B4BD5), Color(0xFF6C5CE7), Color(0xFFA29BFE)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C5CE7), Color(0xFFFF7675)],
  );

  static const List<Color> memberPalette = [
    Color(0xFF6C5CE7),
    Color(0xFFFF7675),
    Color(0xFF00B894),
    Color(0xFFFD79A8),
    Color(0xFF74B9FF),
    Color(0xFFFDCB6E),
    Color(0xFFE17055),
    Color(0xFF81ECEC),
    Color(0xFFA29BFE),
    Color(0xFF55EFC4),
  ];
}
