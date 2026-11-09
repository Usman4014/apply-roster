
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apply_roster/core/theme/app_colors.dart';

class AppSnackbar {
  AppSnackbar._();

  static void success(
    String title,
    String message,
  ) {
    _show(
      title: title,
      message: message,
      icon: Icons.check_circle_rounded,
    );
  }

  static void error(
    String title,
    String message,
  ) {
    _show(
      title: title,
      message: message,
      icon: Icons.error_rounded,
    );
  }

  static void warning(
    String title,
    String message,
  ) {
    _show(
      title: title,
      message: message,
      icon: Icons.warning_rounded,
    );
  }

  static void info(
    String title,
    String message,
  ) {
    _show(
      title: title,
      message: message,
      icon: Icons.info_rounded,
    );
  }

  static void _show({
    required String title,
    required String message,
    required IconData icon,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      icon: Icon(
        icon,
        color: Colors.white,
        size: 26,
      ),
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 350),
      snackStyle: SnackStyle.FLOATING,
      shouldIconPulse: false,
      isDismissible: true,
      titleText: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
