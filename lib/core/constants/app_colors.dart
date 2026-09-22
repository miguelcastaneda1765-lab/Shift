import 'package:flutter/material.dart';

/// Centralized color palette for the "Side by Side" app.
/// Keeping every color here makes it trivial to re-theme the app
/// or swap the palette without touching widget code.
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background = Color(0xFF1B1B1F);
  static const Color surface = Color(0xFF1B1B1F);
  static const Color topBar = Color(0xFF141416);

  // Brand / accent
  static const Color primaryTeal = Color(0xFF3FD6C4);
  static const Color primaryTealDark = Color(0xFF2FB6A6);
  static const Color accentGreen = Color(0xFF7FE0B4);

  // Gradient used on the big "Side by Side" logo text
  static const List<Color> logoGradient = [
    accentGreen,
    primaryTeal,
  ];

  // Text
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = primaryTeal;
  static const Color textMuted = Color(0xFF8A8F98);

  // Inputs / borders
  static const Color borderTeal = primaryTeal;
  static const Color inputBackground = Color(0xFF1B1B1F);
  static const Color divider = Color(0xFF4A2E2E);

  // Buttons
  static const Color buttonFilled = primaryTeal;
  static const Color buttonText = Color(0xFF102A27);
  static const Color danger = Color(0xFFE5453F);

  // Placeholder for images/icons that will be swapped later
  static const Color placeholderGray = Color(0xFFD9D9D9);
  static const Color placeholderTextDark = Color(0xFF1B1B1F);
}
