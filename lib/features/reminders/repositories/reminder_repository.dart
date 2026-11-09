
import 'package:apply_roster/core/database/database_service.dart';
import 'package:sqflite/sqflite.dart';

import '../models/reminder_model.dart';

class ReminderRepository {
  final DatabaseService _databaseService = DatabaseService.instance;

  // Add Reminder
  Future<int> addReminder(ReminderModel reminder) async {
    final db = await _databaseService.database;

    return db.insert(
      'reminders',
      reminder.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get All Reminders
  Future<List<ReminderModel>> getAllReminders() async {
    final db = await _databaseService.database;

    final result = await db.query(
      'reminders',
      orderBy: 'reminder_date ASC',
    );

    return result.map(ReminderModel.fromMap).toList();
  }

  // Get Upcoming Reminders
  Future<List<ReminderModel>> getUpcomingReminders() async {
    final db = await _databaseService.database;

    final result = await db.query(
      'reminders',
      where: 'is_completed = ? AND reminder_date >= ?',
      whereArgs: [0, DateTime.now().toIso8601String()],
      orderBy: 'reminder_date ASC',
    );

    return result.map(ReminderModel.fromMap).toList();
  }

  // Get Upcoming Interviews
  Future<List<Map<String, dynamic>>> getUpcomingInterviews() async {
    final db = await _databaseService.database;
    final now = DateTime.now().toIso8601String();

    return db.rawQuery(
      '''
      SELECT
        reminders.id,
        reminders.title,
        reminders.description,
        reminders.reminder_date,
        applications.company_name,
        applications.job_title
      FROM reminders
      INNER JOIN applications
        ON reminders.application_id = applications.id
      WHERE reminders.is_completed = 0
        AND reminders.reminder_date >= ?
        AND (
          LOWER(reminders.title) LIKE '%interview%'
          OR LOWER(COALESCE(reminders.description, '')) LIKE '%interview%'
        )
      ORDER BY reminders.reminder_date ASC
      LIMIT 3
      ''',
      [now],
    );
  }

  // Get Reminders By Application
  Future<List<ReminderModel>> getRemindersByApplication(
    int applicationId,
  ) async {
    final db = await _databaseService.database;

    final result = await db.query(
      'reminders',
      where: 'application_id = ?',
      whereArgs: [applicationId],
      orderBy: 'reminder_date ASC',
    );

    return result.map(ReminderModel.fromMap).toList();
  }

  // Update Reminder
  Future<int> updateReminder(ReminderModel reminder) async {
    final db = await _databaseService.database;

    return db.update(
      'reminders',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  // Mark Reminder as Completed
  Future<int> markReminderCompleted(int id) async {
    final db = await _databaseService.database;

    return db.update(
      'reminders',
      {'is_completed': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete Reminder
  Future<int> deleteReminder(int id) async {
    final db = await _databaseService.database;

    return db.delete(
      'reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
