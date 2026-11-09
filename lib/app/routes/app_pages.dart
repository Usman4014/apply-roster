
import 'package:get/get.dart';

// Splash & Onboarding
import 'package:apply_roster/features/splash/views/splash_view.dart';
import 'package:apply_roster/features/onboarding/views/onboarding_view.dart';
import 'package:apply_roster/features/onboarding/views/welcome_setup_view.dart';

// Main & Dashboard
import 'package:apply_roster/features/main/views/main_navigation_view.dart';
import 'package:apply_roster/features/dashboard/views/dashboard_view.dart';

// Applications
import 'package:apply_roster/features/applications/models/application_model.dart';
import 'package:apply_roster/features/applications/views/add_application_view.dart';
import 'package:apply_roster/features/applications/views/applications_view.dart';
import 'package:apply_roster/features/applications/views/application_details_view.dart';

// Reminders
import 'package:apply_roster/features/reminders/models/reminder_model.dart';
import 'package:apply_roster/features/reminders/views/add_reminder_view.dart';
import 'package:apply_roster/features/reminders/views/reminders_view.dart';
import 'package:apply_roster/features/reminders/views/reminder_details_view.dart';

// Notifications
import 'package:apply_roster/features/notifications/views/notifications_view.dart';

// Settings
import 'package:apply_roster/features/settings/views/settings_view.dart';
import 'package:apply_roster/features/settings/views/about_view.dart';
import 'package:apply_roster/features/settings/views/privacy_policy_view.dart';

import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final List<GetPage> pages = [
    // Splash
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
    ),

    // Onboarding
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
    ),

    // Welcome Setup
    GetPage(
      name: AppRoutes.welcomeSetup,
      page: () => const WelcomeSetupView(),
    ),

    // Main Navigation
    GetPage(
      name: AppRoutes.main,
      page: () => const MainNavigationView(),
    ),

    // Dashboard
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
    ),

    // Applications
    GetPage(
      name: AppRoutes.applications,
      page: () => const ApplicationsView(),
    ),

    GetPage(
      name: AppRoutes.addApplication,
      page: () => AddApplicationView(
        application: Get.arguments as ApplicationModel?,
      ),
    ),

    GetPage(
      name: AppRoutes.applicationDetails,
      page: () => ApplicationDetailsView(
        application: Get.arguments as ApplicationModel,
      ),
    ),

    // Reminders
    GetPage(
      name: AppRoutes.reminders,
      page: () => const RemindersView(),
    ),

    GetPage(
      name: AppRoutes.addReminder,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};

        return AddReminderView(
          initialApplicationId: args['initialApplicationId'] as int?,
          initialDate: args['initialDate'] as DateTime?,
          reminder: args['reminder'] as ReminderModel?,
        );
      },
    ),

    GetPage(
      name: AppRoutes.reminderDetails,
      page: () => ReminderDetailsView(
        reminder: Get.arguments as ReminderModel,
      ),
    ),

    // Notifications
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsView(),
    ),

    // Settings
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
    ),

    GetPage(
      name: AppRoutes.about,
      page: () => const AboutView(),
    ),

    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const PrivacyPolicyView(),
    ),
  ];
}
