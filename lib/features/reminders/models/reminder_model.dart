
class ReminderModel {
  final int? id;
  final int applicationId;
  final String title;
  final String? description;
  final DateTime reminderDate;
  final int? notificationId;
  final bool isCompleted;
  final DateTime? createdAt;

  const ReminderModel({
    this.id,
    required this.applicationId,
    required this.title,
    this.description,
    required this.reminderDate,
    this.notificationId,
    this.isCompleted = false,
    this.createdAt,
  });

  // Convert Model to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'application_id': applicationId,
      'title': title,
      'description': description,
      'reminder_date': reminderDate.toIso8601String(),
      'notification_id': notificationId,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  // Create Model from Map
  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] as int?,
      applicationId: map['application_id'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      reminderDate: DateTime.parse(
        map['reminder_date'] as String,
      ),
      notificationId: map['notification_id'] as int?,
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }

  // Copy Model with Updated Values
  ReminderModel copyWith({
    int? id,
    int? applicationId,
    String? title,
    String? description,
    DateTime? reminderDate,
    int? notificationId,
    bool? isCompleted,
    DateTime? createdAt,
    bool clearDescription = false,
    bool clearNotificationId = false,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      applicationId: applicationId ?? this.applicationId,
      title: title ?? this.title,
      description: clearDescription
          ? null
          : description ?? this.description,
      reminderDate: reminderDate ?? this.reminderDate,
      notificationId: clearNotificationId
          ? null
          : notificationId ?? this.notificationId,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
