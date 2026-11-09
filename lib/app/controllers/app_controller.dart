
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppController extends GetxController {
  static const String _themeKey = 'app_theme_mode';

  final Rx<ThemeMode> themeMode = ThemeMode.light.obs;

  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();
  }

  // Load Saved Theme Preference
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey);

      switch (savedTheme) {
        case 'dark':
          themeMode.value = ThemeMode.dark;
          break;
        case 'system':
          themeMode.value = ThemeMode.system;
          break;
        default:
          themeMode.value = ThemeMode.light;
      }

      Get.changeThemeMode(themeMode.value);
    } catch (e, stackTrace) {
      debugPrint('Failed to load theme preference: $e');
      debugPrintStack(stackTrace: stackTrace);

      themeMode.value = ThemeMode.light;
      Get.changeThemeMode(ThemeMode.light);
    }
  }

  // Change Theme
  Future<void> changeThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = await prefs.setString(_themeKey, mode.name);

      if (!saved) {
        debugPrint('Failed to save theme preference.');
        return;
      }

      themeMode.value = mode;
      Get.changeThemeMode(mode);
    } catch (e, stackTrace) {
      debugPrint('Failed to change theme mode: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
