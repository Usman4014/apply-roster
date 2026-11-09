
import 'package:apply_roster/app/bindings/app_binding.dart';
import 'package:apply_roster/app/controllers/app_controller.dart';
import 'package:apply_roster/app/routes/app_pages.dart';
import 'package:apply_roster/app/routes/app_routes.dart';
import 'package:apply_roster/core/services/notification_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local notifications.
  await NotificationService.instance.initialize();

  // Register application dependencies.
  AppBinding().dependencies();

  runApp(const ApplyRosterApp());
}

class ApplyRosterApp extends StatelessWidget {
  const ApplyRosterApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AppController controller = Get.find<AppController>();

    return Obx(() {
      final themeMode = controller.themeMode.value;

      final isDarkMode = themeMode == ThemeMode.dark ||
          (themeMode == ThemeMode.system &&
              WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                  Brightness.dark);

      final activeTheme =
          isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

      final backgroundColor = activeTheme.scaffoldBackgroundColor;

      return GetMaterialApp(
        title: 'ApplyRoster',
        debugShowCheckedModeBanner: false,

        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,

        builder: (context, child) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: backgroundColor,
              statusBarIconBrightness:
                  isDarkMode ? Brightness.light : Brightness.dark,
              statusBarBrightness:
                  isDarkMode ? Brightness.dark : Brightness.light,
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },

        initialRoute: AppRoutes.splash,
        getPages: AppPages.pages,
      );
    });
  }
}
