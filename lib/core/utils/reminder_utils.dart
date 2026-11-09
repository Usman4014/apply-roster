
class ReminderUtils {
  ReminderUtils._();

  /// Identifies reminder category using its title and description.
  static String getReminderType(String title, String? description) {
    final content = '$title ${description ?? ''}'.toLowerCase();

    if (content.contains('interview')) {
      return 'interview';
    }

    if (content.contains('follow-up') ||
        content.contains('follow up') ||
        content.contains('followup')) {
      return 'follow_up';
    }

    return 'reminder';
  }
}
