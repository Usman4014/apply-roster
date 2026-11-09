import 'package:apply_roster/core/services/notification_service.dart';
import 'package:apply_roster/core/utils/reminder_utils.dart';
import 'package:apply_roster/features/notifications/models/notification_model.dart';
import 'package:apply_roster/features/notifications/repositories/notification_repository.dart';
import 'package:apply_roster/features/reminders/repositories/reminder_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationController extends GetxController {
  final NotificationRepository _repository = Get.find<NotificationRepository>();

  final ReminderRepository _reminderRepository = Get.find<ReminderRepository>();

  // Notification Filters
  final RxString selectedFilter = 'All'.obs;

  // Notifications
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Notification Preferences
  static const String _interviewKey = 'notify_interviews';
  static const String _followUpKey = 'notify_follow_ups';
  static const String _applicationKey = 'notify_applications';
  static const String _generalKey = 'notify_general';

  final RxBool interviewNotifications = true.obs;
  final RxBool followUpNotifications = true.obs;
  final RxBool applicationNotifications = true.obs;
  final RxBool generalNotifications = true.obs;

  List<NotificationModel> get filteredNotifications {
    switch (selectedFilter.value) {
      case 'Reminders':
        return notifications.where((item) {
          final type = item.type.toLowerCase();

          return type == 'reminder' ||
              type == 'interview' ||
              type == 'follow_up';
        }).toList();

      case 'Applications':
        return notifications.where((item) {
          final type = item.type.toLowerCase();

          return type == 'status' || type == 'application';
        }).toList();

      default:
        return notifications.toList();
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    await loadNotificationPreferences();
    await loadNotifications();
  }

  // Load saved preferences
  Future<void> loadNotificationPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      interviewNotifications.value = prefs.getBool(_interviewKey) ?? true;
      followUpNotifications.value = prefs.getBool(_followUpKey) ?? true;
      applicationNotifications.value = prefs.getBool(_applicationKey) ?? true;
      generalNotifications.value = prefs.getBool(_generalKey) ?? true;
    } catch (e) {
      debugPrint('Failed to load notification preferences: $e');
    }
  }

  Future<void> setInterviewNotifications(bool value) async {
    if (interviewNotifications.value == value) return;

    if (await _savePreference(_interviewKey, value)) {
      interviewNotifications.value = value;
      await _syncScheduledReminders('interview', value);
    }
  }

  Future<void> setFollowUpNotifications(bool value) async {
    if (followUpNotifications.value == value) return;

    if (await _savePreference(_followUpKey, value)) {
      followUpNotifications.value = value;
      await _syncScheduledReminders('follow_up', value);
    }
  }

  Future<void> setApplicationNotifications(bool value) async {
    if (applicationNotifications.value == value) return;

    if (await _savePreference(_applicationKey, value)) {
      applicationNotifications.value = value;
    }
  }

  Future<void> setGeneralNotifications(bool value) async {
    if (generalNotifications.value == value) return;

    if (await _savePreference(_generalKey, value)) {
      generalNotifications.value = value;
      await _syncScheduledReminders('reminder', value);
    }
  }

  Future<bool> _savePreference(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(key, value);
    } catch (e, stackTrace) {
      debugPrint('Failed to save notification preference: $e');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage.value = 'Failed to save notification preference.';
      return false;
    }
  }

  // Check whether a notification category is enabled.
  bool isNotificationEnabled(String type) {
    switch (type.toLowerCase()) {
      case 'interview':
        return interviewNotifications.value;

      case 'follow_up':
        return followUpNotifications.value;

      case 'status':
      case 'application':
        return applicationNotifications.value;

      case 'reminder':
        return generalNotifications.value;

      default:
        return generalNotifications.value;
    }
  }

  // Synchronize existing scheduled reminders after preference changes.
  Future<void> _syncScheduledReminders(String category, bool enabled) async {
    try {
      final reminders = await _reminderRepository.getAllReminders();
      final now = DateTime.now();

      int successCount = 0;
      int failureCount = 0;

      for (final reminder in reminders) {
        if (reminder.id == null || reminder.isCompleted) {
          continue;
        }

        if (!reminder.reminderDate.isAfter(now)) {
          continue;
        }

        final reminderType = ReminderUtils.getReminderType(
          reminder.title,
          reminder.description,
        );

        if (reminderType != category) {
          continue;
        }

        final notificationId = reminder.notificationId;

        if (notificationId == null) {
          continue;
        }

        try {
          // Cancel existing scheduled notification.
          await NotificationService.instance.cancelReminder(notificationId);

          // Schedule again only when the category is enabled.
          if (enabled) {
            await NotificationService.instance.scheduleReminder(
              notificationId: notificationId,
              title: reminder.title,
              body: reminder.description?.trim().isNotEmpty == true
                  ? reminder.description!
                  : 'You have an upcoming job application reminder.',
              scheduledDate: reminder.reminderDate,
            );
          }

          successCount++;
        } catch (e, stackTrace) {
          failureCount++;

          debugPrint('REMINDER SYNC FAILED: ID ${reminder.id}, Error: $e');
          debugPrintStack(stackTrace: stackTrace);
        }
      }

      debugPrint('========== REMINDER SYNC ==========');
      debugPrint('Category: $category');
      debugPrint('Enabled: $enabled');
      debugPrint('Successful: $successCount');
      debugPrint('Failed: $failureCount');
      debugPrint('===================================');

      if (failureCount > 0) {
        errorMessage.value = 'Some reminders could not be synchronized.';
      } else {
        errorMessage.value = '';
      }
    } catch (e, stackTrace) {
      debugPrint('REMINDER SYNC ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage.value = 'Failed to update scheduled reminders.';
    }
  }

  // Load notifications
  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final results = await _repository.getAllNotifications();
      notifications.assignAll(results);

      await loadUnreadCount();
    } catch (e) {
      errorMessage.value = 'Failed to load notifications.';
    } finally {
      isLoading.value = false;
    }
  }

  // Load unread notification count
  Future<void> loadUnreadCount() async {
    try {
      unreadCount.value = await _repository.getUnreadCount();
    } catch (e) {
      errorMessage.value = 'Failed to load unread notifications.';
    }
  }

  // Add notification
  Future<bool> addNotification(NotificationModel notification) async {
    try {
      if (!isNotificationEnabled(notification.type)) {
        debugPrint('NOTIFICATION: Skipped because preference is disabled.');
        return false;
      }

      debugPrint('NOTIFICATION: Starting insert...');
      debugPrint('NOTIFICATION: ${notification.title}');

      final id = await _repository.addNotification(notification);

      debugPrint('NOTIFICATION: Inserted with ID: $id');

      await loadNotifications();

      debugPrint('NOTIFICATION: Loaded ${notifications.length} notifications.');

      return id > 0;
    } catch (e, stackTrace) {
      errorMessage.value = 'Failed to save notification: $e';

      debugPrint('NOTIFICATION ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      return false;
    }
  }

  // Mark a notification as read
  Future<void> markAsRead(int id) async {
    try {
      final rowsUpdated = await _repository.markAsRead(id);

      if (rowsUpdated > 0) {
        final index = notifications.indexWhere(
          (notification) => notification.id == id,
        );

        if (index != -1) {
          notifications[index] = notifications[index].copyWith(isRead: true);
        }

        await loadUnreadCount();
      }
    } catch (e, stackTrace) {
      debugPrint('MARK AS READ ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage.value = 'Failed to update notification.';
    }
  }

  // Mark all notifications as read

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      // Update all notifications in database
      await _repository.markAllAsRead();

      // Update UI: keep all notifications, only change read status
      notifications.assignAll(
        notifications.map(
          (notification) => notification.copyWith(isRead: true),
        ),
      );

      // Reset unread count
      unreadCount.value = 0;
    } catch (e, stackTrace) {
      debugPrint('MARK ALL AS READ ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage.value = 'Failed to mark notifications as read.';
    }
  }

  // Delete a notification
  Future<void> deleteNotification(int id) async {
    try {
      await _repository.deleteNotification(id);

      notifications.removeWhere((notification) => notification.id == id);

      await loadUnreadCount();
    } catch (e) {
      errorMessage.value = 'Failed to delete notification.';
    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      await _repository.clearAllNotifications();

      notifications.clear();
      unreadCount.value = 0;
    } catch (e) {
      errorMessage.value = 'Failed to clear notifications.';
    }
  }
}
