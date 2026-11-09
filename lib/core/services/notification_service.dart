import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'apply_roster_reminders',
    'Apply Roster Reminders',
    description: 'Interview and job application reminders.',
    importance: Importance.max,
  );

  Future<void> initialize() async {
    // Initialize timezone database.
    tzdata.initializeTimeZones();

    // Get device timezone.
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings: initializationSettings);

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(_channel);

    await requestPermission();
  }

  Future<void> requestPermission() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> scheduleReminder({
    required int notificationId,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!scheduledDate.isAfter(DateTime.now())) {
      throw ArgumentError('Reminder time must be in the future.');
    }

    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,

      // ApplyRoster logo instead of bell
      icon: 'ic_stat_apply_roster',

      // No large logo on the right
      // No colorized background
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,

      subText: 'Reminder',

      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: 'Reminder',
      ),

      showWhen: true,
      autoCancel: true,
    );
    await _notifications.zonedSchedule(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: notificationId.toString(),
    );

    debugPrint('========== REMINDER DEBUG ==========');
    debugPrint('App: Apply Roster');
    debugPrint('Device Time: ${DateTime.now()}');
    debugPrint('Device Timezone: ${tz.local.name}');
    debugPrint('Scheduled Date: $scheduledDate');
    debugPrint(
      'Timezone Scheduled Date: '
      '${tz.TZDateTime.from(scheduledDate, tz.local)}',
    );

    final pending = await _notifications.pendingNotificationRequests();

    debugPrint('Pending Notifications: ${pending.length}');

    for (final notification in pending) {
      debugPrint('ID: ${notification.id}, Title: ${notification.title}');
    }

    debugPrint('====================================');
  }

  Future<void> cancelReminder(int notificationId) async {
    await _notifications.cancel(id: notificationId);
  }

  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }
}
