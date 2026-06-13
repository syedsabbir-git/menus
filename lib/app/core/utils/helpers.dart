import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

class AppSnackBar {
  static void error(String message) => _show(
        title: 'Error',
        message: message,
        icon: Icons.error_outline_rounded,
        backgroundColor: const Color(0xFFB71C1C),
      );

  static void success(String message) => _show(
        title: 'Success',
        message: message,
        icon: Icons.check_circle_outline_rounded,
        backgroundColor: const Color(0xFF1B5E20),
      );

  static void warning(String message) => _show(
        title: 'Warning',
        message: message,
        icon: Icons.warning_amber_rounded,
        backgroundColor: const Color(0xFFE65100),
      );

  static void info(String message) => _show(
        title: 'Info',
        message: message,
        icon: Icons.info_outline_rounded,
        backgroundColor: AppColors.primary,
      );

  static void _show({
    required String title,
    required String message,
    required IconData icon,
    required Color backgroundColor,
  }) {
    // Dismiss any existing snackbar first
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      icon: Icon(icon, color: Colors.white, size: 26),
      shouldIconPulse: false,
      duration: const Duration(seconds: 4),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      animationDuration: const Duration(milliseconds: 300),
      boxShadows: [
        BoxShadow(
          color: backgroundColor.withValues(alpha: 0.4),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

// Backwards-compatible helper kept for any direct call sites
void showSnackBar({required String message, bool isError = false}) {
  if (isError) {
    AppSnackBar.error(message);
  } else {
    AppSnackBar.success(message);
  }
}
