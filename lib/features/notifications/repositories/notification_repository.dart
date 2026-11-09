import 'package:apply_roster/core/database/database_service.dart';
import 'package:sqflite/sqflite.dart';

import '../models/notification_model.dart';

class NotificationRepository {
  final DatabaseService _databaseService = DatabaseService.instance;

  Future<Database> get _database => _databaseService.database;

  Future<int> addNotification(NotificationModel notification) async {
    final db = await _database;

    return db.insert(
      'notifications',
      notification.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<NotificationModel>> getAllNotifications() async {
    final db = await _database;

    final result = await db.query(
      'notifications',
      orderBy: 'created_at DESC',
    );

    return result.map(NotificationModel.fromMap).toList();
  }

  Future<int> getUnreadCount() async {
    final db = await _database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM notifications WHERE is_read = 0',
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> markAsRead(int id) async {
    final db = await _database;

    return db.update(
      'notifications',
      {'is_read': 1},
      where: 'id = ? AND is_read = ?',
      whereArgs: [id, 0],
    );
  }

  Future<int> markAllAsRead() async {
    final db = await _database;

    return db.update(
      'notifications',
      {'is_read': 1},
      where: 'is_read = ?',
      whereArgs: [0],
    );
  }

  Future<void> deleteNotification(int id) async {
    final db = await _database;

    await db.delete(
      'notifications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAllNotifications() async {
    final db = await _database;

    await db.delete('notifications');
  }
}