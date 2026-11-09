
import 'package:apply_roster/core/services/notification_service.dart';
import 'package:apply_roster/core/utils/reminder_utils.dart';
import 'package:apply_roster/features/notifications/controllers/notification_controller.dart';
import 'package:apply_roster/features/notifications/models/notification_model.dart';
import 'package:apply_roster/features/reminders/models/reminder_model.dart';
import 'package:apply_roster/features/reminders/repositories/reminder_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class ReminderController extends GetxController {
  final ReminderRepository _repository = Get.find<ReminderRepository>();

  // Observable States
  final RxList<ReminderModel> reminders = <ReminderModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Upcoming Reminders
  List<ReminderModel> get upcomingReminders {
    final now = DateTime.now();

    return reminders
        .where(
          (reminder) =>
              !reminder.isCompleted && reminder.reminderDate.isAfter(now),
        )
        .toList()
      ..sort((a, b) => a.reminderDate.compareTo(b.reminderDate));
  }

  // Completed Reminders
  List<ReminderModel> get completedReminders {
    return reminders.where((reminder) => reminder.isCompleted).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadReminders();
  }

  // Generate Unique Notification ID
  int _generateNotificationId() {
    return DateTime.now().microsecondsSinceEpoch.remainder(2147483647);
  }

  // Schedule Reminder Notification
  Future<void> _scheduleReminderNotification({
    required ReminderModel reminder,
    required int notificationId,
    required String reminderType,
    required NotificationController notificationController,
  }) async {
    if (!notificationController.isNotificationEnabled(reminderType)) {
      return;
    }

    await NotificationService.instance.scheduleReminder(
      notificationId: notificationId,
      title: reminder.title,
      body: reminder.description?.trim().isNotEmpty == true
          ? reminder.description!
          : 'You have an upcoming job application reminder.',
      scheduledDate: reminder.reminderDate,
    );
  }

  // Load Reminders
  Future<void> loadReminders() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _repository.getAllReminders();
      reminders.assignAll(result);
    } catch (e, stackTrace) {
      debugPrint('LOAD REMINDERS ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage.value = 'Failed to load reminders.';
    } finally {
      isLoading.value = false;
    }
  }

  // Add Reminder
  Future<bool> addReminder(ReminderModel reminder) async {
    try {
      errorMessage.value = '';

      if (!reminder.reminderDate.isAfter(DateTime.now())) {
        errorMessage.value = 'Reminder time must be in the future.';
        return false;
      }

      final notificationController = Get.find<NotificationController>();

      final reminderType = ReminderUtils.getReminderType(
        reminder.title,
        reminder.description,
      );

      final notificationId = _generateNotificationId();

      final reminderWithNotificationId = reminder.copyWith(
        notificationId: notificationId,
      );

      final reminderId = await _repository.addReminder(
        reminderWithNotificationId,
      );

      if (reminderId <= 0) {
        return false;
      }

      final savedReminder = reminderWithNotificationId.copyWith(
        id: reminderId,
      );

      // Schedule Local Notification
      try {
        await _scheduleReminderNotification(
          reminder: savedReminder,
          notificationId: notificationId,
          reminderType: reminderType,
          notificationController: notificationController,
        );
      } catch (e, stackTrace) {
        debugPrint('REMINDER SCHEDULING ERROR: $e');
        debugPrintStack(stackTrace: stackTrace);
      }

      // Add Inbox Notification
      await notificationController.addNotification(
        NotificationModel(
          title: 'Reminder Scheduled',
          message: '${reminder.title} — ${reminder.reminderDate.toLocal()}',
          type: reminderType,
          relatedId: reminderId,
          createdAt: DateTime.now(),
        ),
      );

      await loadReminders();

      return true;
    } catch (e, stackTrace) {
      debugPrint('ADD REMINDER ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage.value = 'Failed to create reminder.';
      return false;
    }
  }

  // Update Reminder
  Future<bool> updateReminder(ReminderModel reminder) async {
    if (reminder.id == null) {
      return false;
    }

    errorMessage.value = '';

    if (!reminder.reminderDate.isAfter(DateTime.now())) {
      errorMessage.value = 'Reminder time must be in the future.';
      return false;
    }

    try {
      final notificationController = Get.find<NotificationController>();

      final reminderType = ReminderUtils.getReminderType(
        reminder.title,
        reminder.description,
      );

      final oldNotificationId = reminder.notificationId;
      final newNotificationId = _generateNotificationId();

      final updatedReminder = reminder.copyWith(
        notificationId: newNotificationId,
      );

      // 1. Database update is the primary operation.
      final rowsUpdated = await _repository.updateReminder(updatedReminder);

      if (rowsUpdated == 0) {
        errorMessage.value = 'Reminder could not be updated.';
        return false;
      }

      // 2. Cancel the previous notification.
      if (oldNotificationId != null) {
        try {
          await NotificationService.instance.cancelReminder(
            oldNotificationId,
          );
        } catch (e, stackTrace) {
          debugPrint('OLD NOTIFICATION CANCEL ERROR: $e');
          debugPrintStack(stackTrace: stackTrace);
        }
      }

      // 3. Schedule the updated notification.
      try {
        await _scheduleReminderNotification(
          reminder: updatedReminder,
          notificationId: newNotificationId,
          reminderType: reminderType,
          notificationController: notificationController,
        );
      } catch (e, stackTrace) {
        debugPrint('UPDATED NOTIFICATION SCHEDULING ERROR: $e');
        debugPrintStack(stackTrace: stackTrace);
      }

      // 4. Add an entry to the notification inbox.
      try {
        await notificationController.addNotification(
          NotificationModel(
            title: 'Reminder Updated',
            message:
                '${updatedReminder.title} — '
                '${updatedReminder.reminderDate.toLocal()}',
            type: reminderType,
            relatedId: updatedReminder.id,
            createdAt: DateTime.now(),
          ),
        );
      } catch (e, stackTrace) {
        debugPrint('INBOX NOTIFICATION ERROR: $e');
        debugPrintStack(stackTrace: stackTrace);
      }

      // 5. Refresh the reminder list.
      await loadReminders();

      debugPrint('Reminder updated successfully: ${updatedReminder.id}');

      return true;
    } catch (e, stackTrace) {
      debugPrint('REMINDER UPDATE ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage.value = 'Failed to update reminder.';
      return false;
    }
  }

  // Complete Reminder
  Future<bool> completeReminder(ReminderModel reminder) async {
    if (reminder.id == null) {
      return false;
    }

    try {
      // 1. Mark reminder as completed in database.
      await _repository.markReminderCompleted(reminder.id!);

      // 2. Cancel its scheduled notification.
      if (reminder.notificationId != null) {
        try {
          await NotificationService.instance.cancelReminder(
            reminder.notificationId!,
          );
        } catch (e, stackTrace) {
          debugPrint('REMINDER CANCELLATION ERROR: $e');
          debugPrintStack(stackTrace: stackTrace);
        }
      }

      // 3. Refresh reminders.
      await loadReminders();

      return true;
    } catch (e, stackTrace) {
      debugPrint('COMPLETE REMINDER ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage.value = 'Failed to complete reminder.';
      return false;
    }
  }

  // Delete Reminder
  Future<bool> deleteReminder(ReminderModel reminder) async {
    if (reminder.id == null) {
      return false;
    }

    try {
      // 1. Delete reminder from database.
      await _repository.deleteReminder(reminder.id!);

      // 2. Cancel its scheduled notification.
      if (reminder.notificationId != null) {
        try {
          await NotificationService.instance.cancelReminder(
            reminder.notificationId!,
          );
        } catch (e, stackTrace) {
          debugPrint('REMINDER CANCELLATION ERROR: $e');
          debugPrintStack(stackTrace: stackTrace);
        }
      }

      // 3. Refresh reminders.
      await loadReminders();

      return true;
    } catch (e, stackTrace) {
      debugPrint('DELETE REMINDER ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage.value = 'Failed to delete reminder.';
      return false;
    }
  }

  // Get Reminders for Application
  Future<List<ReminderModel>> getRemindersForApplication(
    int applicationId,
  ) async {
    return _repository.getRemindersByApplication(applicationId);
  }

  // Get Upcoming Interviews
  Future<List<Map<String, dynamic>>> getUpcomingInterviews() async {
    try {
      return await _repository.getUpcomingInterviews();
    } catch (e, stackTrace) {
      debugPrint('LOAD UPCOMING INTERVIEWS ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage.value = 'Failed to load upcoming interviews.';
      return [];
    }
  }
}
