import 'package:apply_roster/app/routes/app_routes.dart';
import 'package:apply_roster/core/utils/app_snackbar.dart';
import 'package:apply_roster/features/applications/controllers/application_controller.dart';
import 'package:apply_roster/features/applications/models/application_model.dart';
import 'package:apply_roster/features/reminders/controllers/reminder_controller.dart';
import 'package:apply_roster/features/reminders/models/reminder_model.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ReminderDetailsView extends StatefulWidget {
  final ReminderModel reminder;

  const ReminderDetailsView({super.key, required this.reminder});

  @override
  State<ReminderDetailsView> createState() => _ReminderDetailsViewState();
}

class _ReminderDetailsViewState extends State<ReminderDetailsView> {
  final ReminderController _reminderController = Get.find<ReminderController>();

  final ApplicationController _applicationController =
      Get.find<ApplicationController>();

  late ReminderModel _reminder;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _reminder = widget.reminder;
  }

  ApplicationModel? get _application {
    for (final application in _applicationController.applications) {
      if (application.id == _reminder.applicationId) {
        return application;
      }
    }

    return null;
  }

  bool get _isOverdue =>
      !_reminder.isCompleted && _reminder.reminderDate.isBefore(DateTime.now());

  String get _status {
    if (_reminder.isCompleted) return 'Completed';
    if (_isOverdue) return 'Overdue';

    return 'Upcoming';
  }

  // Edit Reminder
  Future<void> _editReminder() async {
    if (_isProcessing) return;

    final result = await Get.toNamed(
      AppRoutes.addReminder,
      arguments: {'reminder': _reminder},
    );

    if (!mounted || result == null) return;

    if (result is ReminderModel) {
      setState(() {
        _reminder = result;
      });

      await _reminderController.loadReminders();
    }
  }

  // Complete Reminder
  Future<void> _completeReminder() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    final success = await _reminderController.completeReminder(_reminder);

    if (!mounted) return;

    setState(() => _isProcessing = false);

    if (success) {
      Get.back();

      AppSnackbar.success(
        'Reminder Completed',
        'Your reminder has been marked as completed.',
      );
    } else {
      _showMessage('Unable to complete reminder.');
    }
  }

  // Delete Reminder
  Future<void> _deleteReminder() async {
    if (_isProcessing) return;

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: theme.cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Delete Icon
            Container(
              height: 62,
              width: 62,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                IconsaxPlusLinear.trash,
                color: colors.primary,
                size: 30,
              ),
            ),

            const SizedBox(height: 18),

            // Title
            Text(
              'Delete Reminder?',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 9),

            // Description
            Text(
              'Are you sure you want to delete '
              '"${_reminder.title}" reminder? '
              'This action cannot be undone.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        actions: [
          Row(
            children: [
              // Cancel Button
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(result: false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.onSurface,
                    side: BorderSide(color: theme.dividerColor),
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),

              const SizedBox(width: 12),

              // Delete Button
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      barrierDismissible: true,
    );

    if (confirmed != true || !mounted || _isProcessing) return;

    setState(() => _isProcessing = true);

    final success = await _reminderController.deleteReminder(_reminder);

    if (!mounted) return;

    setState(() => _isProcessing = false);

    if (!success) {
      _showMessage('Unable to delete reminder.');
      return;
    }

    Get.back();

    Future.delayed(const Duration(milliseconds: 300), () {
      AppSnackbar.success(
        'Reminder Deleted!',
        'Your reminder has been deleted successfully.',
      );
    });
  }

  // Show Error Message
  void _showMessage(String message) {
    AppSnackbar.error('Something Went Wrong', message);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final application = _application;
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Reminder Details',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(IconsaxPlusLinear.arrow_left),
        ),
        actions: [
          // Edit Reminder
          IconButton(
            tooltip: 'Edit Reminder',
            onPressed: _isProcessing ? null : _editReminder,
            icon: Icon(
              IconsaxPlusLinear.edit_2,
              color: colors.primary,
              size: 23,
            ),
          ),

          // Delete Reminder
          IconButton(
            tooltip: 'Delete Reminder',
            onPressed: _isProcessing ? null : _deleteReminder,
            icon: Icon(IconsaxPlusLinear.trash, color: colors.error, size: 24),
          ),

          const SizedBox(width: 5),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroCard(theme),
              const SizedBox(height: 24),

              // Reminder Information
              _buildSectionTitle('Reminder Information', theme),
              const SizedBox(height: 12),

              _buildInfoCard(theme, [
                _InfoItem(
                  icon: IconsaxPlusLinear.calendar,
                  label: 'Scheduled Date',
                  value: DateFormat('EEEE, dd MMMM yyyy')
                      .format(_reminder.reminderDate),
                ),
                _InfoItem(
                  icon: IconsaxPlusLinear.clock,
                  label: 'Scheduled Time',
                  value: DateFormat('hh:mm a').format(_reminder.reminderDate),
                ),
                _InfoItem(
                  icon: IconsaxPlusLinear.note,
                  label: 'Description',
                  value: _reminder.description?.trim().isNotEmpty == true
                      ? _reminder.description!
                      : 'No description added.',
                ),
              ]),

              const SizedBox(height: 24),

              // Related Application
              _buildSectionTitle('Related Application', theme),
              const SizedBox(height: 12),

              _buildInfoCard(theme, [
                _InfoItem(
                  icon: IconsaxPlusLinear.building,
                  label: 'Company',
                  value: application?.companyName ?? 'Application unavailable',
                ),
                _InfoItem(
                  icon: IconsaxPlusLinear.briefcase,
                  label: 'Job Position',
                  value: application?.jobTitle ?? 'Not available',
                ),
              ]),

              // Only Mark as Completed button at the bottom.
              if (!_reminder.isCompleted) ...[
                const SizedBox(height: 30),
                _buildCompleteButton(theme),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Hero Card
  Widget _buildHeroCard(ThemeData theme) {
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(IconsaxPlusLinear.alarm, color: colors.onPrimary, size: 28),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.onPrimary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _status,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            _reminder.title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Your job search, one step at a time.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onPrimary.withValues(alpha: 0.85),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // Section Title
  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  // Information Card
  Widget _buildInfoCard(ThemeData theme, List<_InfoItem> items) {
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.65)),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];

          return Padding(
            padding: EdgeInsets.only(
              bottom: index == items.length - 1 ? 0 : 17,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(item.icon, size: 19, color: colors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(item.value, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // Mark as Completed Button
  Widget _buildCompleteButton(ThemeData theme) {
    final colors = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: _isProcessing ? null : _completeReminder,
        icon: _isProcessing
            ? SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.tertiary,
                ),
              )
            : const Icon(IconsaxPlusLinear.tick_circle),
        label: Text(_isProcessing ? 'Processing...' : 'Mark as Completed'),
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.tertiary,
          side: BorderSide(color: colors.tertiary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// Information Item Model
class _InfoItem {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}
