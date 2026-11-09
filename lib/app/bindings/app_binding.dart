
import 'package:apply_roster/features/applications/controllers/application_controller.dart';
import 'package:apply_roster/features/applications/repositories/application_repository.dart';
import 'package:apply_roster/features/notifications/controllers/notification_controller.dart';
import 'package:apply_roster/features/notifications/repositories/notification_repository.dart';
import 'package:apply_roster/features/reminders/controllers/reminder_controller.dart';
import 'package:apply_roster/features/reminders/repositories/reminder_repository.dart';
import 'package:apply_roster/features/user/controllers/user_controller.dart';
import 'package:get/get.dart';

import '../controllers/app_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories
    Get.put<ApplicationRepository>(
      ApplicationRepository(),
      permanent: true,
    );

    Get.put<ReminderRepository>(
      ReminderRepository(),
      permanent: true,
    );

    Get.put<NotificationRepository>(
      NotificationRepository(),
      permanent: true,
    );

    // App Controllers
    Get.put<AppController>(
      AppController(),
      permanent: true,
    );

    Get.put<UserController>(
      UserController(),
      permanent: true,
    );

    Get.put<ApplicationController>(
      ApplicationController(),
      permanent: true,
    );

    Get.put<ReminderController>(
      ReminderController(),
      permanent: true,
    );

    Get.put<NotificationController>(
      NotificationController(),
      permanent: true,
    );
  }
}
