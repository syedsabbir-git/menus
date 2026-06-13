import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryDark = Color(0xFFE55A24);
  static const Color secondary = Color(0xFF2EC4B6);

  // Semantic
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF59E0B);

  // Light theme
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textHintLight = Color(0xFFADB5BD);
  static const Color dividerLight = Color(0xFFE9ECEF);
  static const Color shimmerLight = Color(0xFFE0E0E0);

  // Dark theme
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textPrimaryDark = Color(0xFFF1F1F1);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color textHintDark = Color(0xFF6B7280);
  static const Color dividerDark = Color(0xFF2A2A2A);
  static const Color shimmerDark = Color(0xFF2C2C2C);

  // Convenience aliases (light values — kept for files that import these directly)
  static const Color background = backgroundLight;
  static const Color surface = surfaceLight;
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;
  static const Color textHint = textHintLight;
  static const Color divider = dividerLight;
  static const Color shimmer = shimmerLight;
}
