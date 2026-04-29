import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand colors
  static const Color primaryBlue = Color(0xFF1360FA);
  static const Color primary = primaryBlue;
  static const Color yellow = Color(0xFFFFA12E);

  // Text colors
  static const Color primaryText = Color(0xFF0C1F42);
  static const Color secondaryText = Color(0xFF787B8A);

  // UI colors
  static const Color stroke = Color(0xFFE0E0E0);
  static const Color background = Color(0xFFF6F6F6);
  static const Color white = Color(0xFFFFFFFF);

  // Light mode backgrounds
  static const Color lightScaffoldBackground = Color(0xFFF6F6F6);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);

  // Dark mode backgrounds
  static const Color darkScaffoldBackground = Color(0xFF0B1220);
  static const Color darkSurface = Color(0xFF111A2B);
  static const Color darkCard = Color(0xFF1A2438);

  // Semantic colors
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF22C55E);

  // Neutral shades
  static const Color neutral900 = Color(0xFF111827);
  static const Color neutral800 = Color(0xFF1F2937);
  static const Color neutral700 = Color(0xFF374151);
  static const Color neutral600 = Color(0xFF4B5563);
  static const Color neutral500 = Color(0xFF6B7280);
  static const Color neutral400 = Color(0xFF9CA3AF);
  static const Color neutral300 = Color(0xFFD1D5DB);
  static const Color neutral200 = Color(0xFFE5E7EB);
  static const Color neutral100 = Color(0xFFF3F4F6);
}
