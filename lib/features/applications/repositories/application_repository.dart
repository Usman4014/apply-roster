
import 'package:apply_roster/core/constants/app_constants.dart';
import 'package:apply_roster/core/database/database_service.dart';
import 'package:apply_roster/features/applications/models/application_model.dart';

class ApplicationRepository {
  final DatabaseService _databaseService = DatabaseService.instance;

  // Add Application
  Future<int> addApplication(ApplicationModel application) async {
    final db = await _databaseService.database;
    final now = DateTime.now().toIso8601String();

    return db.transaction((txn) async {
      final applicationId = await txn.insert(
        'applications',
        {...application.toMap(), 'created_at': now, 'updated_at': now}
          ..remove('id'),
      );

      await txn.insert('status_history', {
        'application_id': applicationId,
        'old_status': null,
        'new_status': application.status,
        'changed_at': now,
      });

      return applicationId;
    });
  }

  // Get All Applications
  Future<List<ApplicationModel>> getAllApplications() async {
    final db = await _databaseService.database;

    final result = await db.query(
      'applications',
      orderBy: 'applied_date DESC',
    );

    return result.map(ApplicationModel.fromMap).toList();
  }

  // Get Application By ID
  Future<ApplicationModel?> getApplicationById(int id) async {
    final db = await _databaseService.database;

    final result = await db.query(
      'applications',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return ApplicationModel.fromMap(result.first);
  }

  // Update Application
  Future<int> updateApplication(ApplicationModel application) async {
    if (application.id == null) {
      throw ArgumentError('Application ID is required for update.');
    }

    final db = await _databaseService.database;

    return db.update(
      'applications',
      {
        ...application.toMap(),
        'updated_at': DateTime.now().toIso8601String(),
      }..remove('id'),
      where: 'id = ?',
      whereArgs: [application.id],
    );
  }

  // Update Application Status + Save History
  Future<void> updateApplicationStatus(int id, String newStatus) async {
    final db = await _databaseService.database;

    await db.transaction((txn) async {
      final result = await txn.query(
        'applications',
        columns: ['status'],
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (result.isEmpty) {
        throw Exception('Application not found.');
      }

      final oldStatus = result.first['status'] as String;

      if (oldStatus == newStatus) {
        return;
      }

      final now = DateTime.now().toIso8601String();

      await txn.update(
        'applications',
        {
          'status': newStatus,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      await txn.insert('status_history', {
        'application_id': id,
        'old_status': oldStatus,
        'new_status': newStatus,
        'changed_at': now,
      });
    });
  }

  // Get Application Status History
  Future<List<Map<String, dynamic>>> getStatusHistory(
    int applicationId,
  ) async {
    final db = await _databaseService.database;

    return db.query(
      'status_history',
      where: 'application_id = ?',
      whereArgs: [applicationId],
      orderBy: 'changed_at DESC',
    );
  }

  // Delete Application
  Future<int> deleteApplication(int id) async {
    final db = await _databaseService.database;

    return db.delete(
      'applications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get Applications By Status
  Future<List<ApplicationModel>> getApplicationsByStatus(
    String status,
  ) async {
    final db = await _databaseService.database;

    final result = await db.query(
      'applications',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'applied_date DESC',
    );

    return result.map(ApplicationModel.fromMap).toList();
  }

  // Get Dashboard Counts
  Future<Map<String, int>> getDashboardCounts() async {
    final db = await _databaseService.database;

    final result = await db.rawQuery(
      '''
      SELECT
        COUNT(*) AS total,
        SUM(CASE WHEN status = ? THEN 1 ELSE 0 END) AS applied,
        SUM(CASE WHEN status = ? THEN 1 ELSE 0 END) AS interviews,
        SUM(CASE WHEN status = ? THEN 1 ELSE 0 END) AS offers,
        SUM(CASE WHEN status = ? THEN 1 ELSE 0 END) AS rejected
      FROM applications
      ''',
      [
        AppConstants.statusApplied,
        AppConstants.statusInterview,
        AppConstants.statusOffer,
        AppConstants.statusRejected,
      ],
    );

    final row = result.first;

    return {
      'total': (row['total'] as int?) ?? 0,
      'applied': (row['applied'] as int?) ?? 0,
      'interviews': (row['interviews'] as int?) ?? 0,
      'offers': (row['offers'] as int?) ?? 0,
      'rejected': (row['rejected'] as int?) ?? 0,
    };
  }
}
