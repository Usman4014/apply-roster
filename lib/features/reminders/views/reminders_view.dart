import 'package:apply_roster/app/routes/app_routes.dart';
import 'package:apply_roster/core/utils/app_snackbar.dart';
import 'package:apply_roster/features/applications/controllers/application_controller.dart';
import 'package:apply_roster/features/applications/models/application_model.dart';
import 'package:apply_roster/features/reminders/controllers/reminder_controller.dart';
import 'package:apply_roster/features/reminders/models/reminder_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';

import '../widgets/reminder_calendar_widget.dart';

class RemindersView extends StatefulWidget {
  const RemindersView({super.key});

  @override
  State<RemindersView> createState() => _RemindersViewState();
}

class _RemindersViewState extends State<RemindersView> {
  final ReminderController _reminderController = Get.find<ReminderController>();

  final ApplicationController _applicationController =
      Get.find<ApplicationController>();

  String _selectedView = 'Agenda';
  late final PageController _viewPageController = PageController();

  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());

  Future<void> _openReminderDetails(ReminderModel reminder) async {
    await Get.toNamed(AppRoutes.reminderDetails, arguments: reminder);

    await _reminderController.loadReminders();
  }

  @override
  void initState() {
    super.initState();
    _reminderController.loadReminders();
    _applicationController.loadApplications();
  }

  @override
  void dispose() {
    _viewPageController.dispose();
    super.dispose();
  }

  Future<void> _openAddReminder({DateTime? initialDate}) async {
    await Get.toNamed(
      AppRoutes.addReminder,
      arguments: {'initialDate': initialDate},
    );

    await _reminderController.loadReminders();
  }

  ApplicationModel? _getApplication(int applicationId) {
    for (final application in _applicationController.applications) {
      if (application.id == applicationId) {
        return application;
      }
    }

    return null;
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  // Complete Reminder
  Future<void> _completeReminder(ReminderModel reminder) async {
    final success = await _reminderController.completeReminder(reminder);

    if (!mounted) return;

    if (success) {
      AppSnackbar.success(
        'Reminder Completed',
        'Your reminder has been marked as completed.',
      );
    }
  }

  // Confirm Reminder Deletion

  List<ReminderModel> _getSelectedDateReminders(List<ReminderModel> reminders) {
    final result = reminders
        .where((reminder) => _isSameDay(reminder.reminderDate, _selectedDate))
        .toList();

    result.sort((a, b) => a.reminderDate.compareTo(b.reminderDate));

    return result;
  }

  // Header - consistent with Applications screen.
  // Header
  Widget _buildHeader(ThemeData theme) {
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Reminders',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Stay on top of your important tasks',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: colors.primary,
            borderRadius: BorderRadius.circular(13),
            child: InkWell(
              onTap: () {
                _openAddReminder(
                  initialDate: _selectedView == 'Calendar'
                      ? _selectedDate
                      : null,
                );
              },
              borderRadius: BorderRadius.circular(13),
              child: SizedBox(
                width: 43,
                height: 43,
                child: Icon(
                  IconsaxPlusLinear.add,
                  color: colors.onPrimary,
                  size: 23,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Obx(() {
          if (_reminderController.isLoading.value &&
              _reminderController.reminders.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: colors.primary),
            );
          }

          final allReminders = _reminderController.reminders.toList()
            ..sort((a, b) => a.reminderDate.compareTo(b.reminderDate));

          return Column(
            children: [
              _buildHeader(theme),

              _buildViewSelector(theme),

              Expanded(
                child: PageView(
                  controller: _viewPageController,
                  physics: const PageScrollPhysics(
                    parent: BouncingScrollPhysics(
                      decelerationRate: ScrollDecelerationRate.fast,
                    ),
                  ),
                  pageSnapping: true,
                  allowImplicitScrolling: true,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedView = index == 0 ? 'Agenda' : 'Calendar';
                    });
                  },
                  children: [
                    RefreshIndicator(
                      color: colors.primary,
                      onRefresh: _reminderController.loadReminders,
                      child: _buildAgendaView(theme, allReminders),
                    ),
                    RefreshIndicator(
                      color: colors.primary,
                      onRefresh: _reminderController.loadReminders,
                      child: _buildCalendarView(theme, allReminders),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // --------------------------------------------------
  // VIEW SELECTOR
  // --------------------------------------------------

  Widget _buildViewSelector(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            _buildViewTab(
              theme,
              label: 'Agenda',
              icon: IconsaxPlusLinear.element,
            ),
            _buildViewTab(
              theme,
              label: 'Calendar',
              icon: IconsaxPlusLinear.calendar_1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewTab(
    ThemeData theme, {
    required String label,
    required IconData icon,
  }) {
    final colors = theme.colorScheme;
    final isSelected = _selectedView == label;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          final index = label == 'Agenda' ? 0 : 1;

          if (_viewPageController.hasClients) {
            _viewPageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 550),
              curve: Curves.easeInOutCubicEmphasized,
            );
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? colors.onPrimary : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isSelected
                      ? colors.onPrimary
                      : colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // AGENDA VIEW
  // --------------------------------------------------

  Widget _buildAgendaView(ThemeData theme, List<ReminderModel> allReminders) {
    final pending = allReminders
        .where((reminder) => !reminder.isCompleted)
        .toList();

    final completed = allReminders
        .where((reminder) => reminder.isCompleted)
        .toList();

    final now = DateTime.now();

    final upcoming = pending
        .where((reminder) => reminder.reminderDate.isAfter(now))
        .toList();

    final overdue = pending
        .where((reminder) => !reminder.reminderDate.isAfter(now))
        .toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
      children: [
        _buildSummaryCard(
          theme,
          upcoming: upcoming.length,
          overdue: overdue.length,
          completed: completed.length,
        ),
        const SizedBox(height: 26),
        _buildSectionHeader(
          theme,
          'Upcoming',
          IconsaxPlusLinear.notification,
          count: upcoming.length,
        ),
        const SizedBox(height: 12),
        if (upcoming.isEmpty)
          _buildEmptyState(
            theme,
            icon: IconsaxPlusLinear.alarm,
            title: 'No Upcoming Reminders',
          )
        else
          ...upcoming.map(
            (reminder) => _buildReminderCard(theme, reminder, isOverdue: false),
          ),
        const SizedBox(height: 24),
        _buildSectionHeader(
          theme,
          'Overdue',
          IconsaxPlusLinear.warning_2,
          count: overdue.length,
        ),
        const SizedBox(height: 12),
        if (overdue.isEmpty)
          _buildEmptyState(
            theme,
            icon: IconsaxPlusLinear.danger,
            title: 'No Overdue Reminders',
          )
        else
          ...overdue.map(
            (reminder) => _buildReminderCard(theme, reminder, isOverdue: true),
          ),
        const SizedBox(height: 24),
        _buildSectionHeader(
          theme,
          'Completed',
          IconsaxPlusLinear.tick_circle,
          count: completed.length,
        ),
        const SizedBox(height: 12),
        if (completed.isEmpty)
          _buildEmptyState(
            theme,
            icon: IconsaxPlusLinear.tick_circle,
            title: 'No Completed Reminders',
          )
        else
          ...completed.reversed.map(
            (reminder) =>
                _buildReminderCard(theme, reminder, isCompleted: true),
          ),
      ],
    );
  }

  // --------------------------------------------------
  // CALENDAR VIEW
  // --------------------------------------------------

  Widget _buildCalendarView(ThemeData theme, List<ReminderModel> allReminders) {
    final selectedReminders = _getSelectedDateReminders(allReminders);

    final pendingCount = selectedReminders
        .where((reminder) => !reminder.isCompleted)
        .length;

    final completedCount = selectedReminders
        .where((reminder) => reminder.isCompleted)
        .length;

    final colors = theme.colorScheme;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
      children: [
        // Calendar Widget
        ReminderCalendarWidget(
          reminders: allReminders,
          selectedDate: _selectedDate,
          onDateSelected: (date) {
            setState(() {
              _selectedDate = DateUtils.dateOnly(date);
            });
          },
        ),
        const SizedBox(height: 25),

        // Selected Date Header
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${selectedReminders.length} scheduled '
                    '${selectedReminders.length == 1 ? 'reminder' : 'reminders'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$pendingCount Pending',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (selectedReminders.isEmpty)
          _buildEmptyState(
            theme,
            icon: IconsaxPlusLinear.calendar_tick,
            title: 'No Events on This Date',
          )
        else ...[
          if (pendingCount > 0)
            _buildSectionHeader(
              theme,
              'Scheduled Reminders',
              IconsaxPlusLinear.notification,
              count: pendingCount,
            ),
          if (pendingCount > 0) const SizedBox(height: 12),
          ...selectedReminders
              .where((reminder) => !reminder.isCompleted)
              .map(
                (reminder) => _buildReminderCard(
                  theme,
                  reminder,
                  isOverdue: !reminder.reminderDate.isAfter(DateTime.now()),
                ),
              ),
          if (completedCount > 0) ...[
            const SizedBox(height: 16),
            _buildSectionHeader(
              theme,
              'Completed',
              IconsaxPlusLinear.tick_circle,
              count: completedCount,
            ),
            const SizedBox(height: 12),
            ...selectedReminders
                .where((reminder) => reminder.isCompleted)
                .map(
                  (reminder) =>
                      _buildReminderCard(theme, reminder, isCompleted: true),
                ),
          ],
        ],
      ],
    );
  }

  // --------------------------------------------------
  // SUMMARY CARD
  // --------------------------------------------------

  // --------------------------------------------------
  // REMINDERS OVERVIEW CARD
  // --------------------------------------------------

  Widget _buildSummaryCard(
    ThemeData theme, {
    required int upcoming,
    required int overdue,
    required int completed,
  }) {
    final colors = theme.colorScheme;

    final total = upcoming + overdue + completed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                IconsaxPlusLinear.chart_1,
                color: colors.onPrimary,
                size: 25,
              ),
              const SizedBox(width: 12),
              Text(
                'Reminders Overview',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // Total Reminders
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Reminders',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colors.onPrimary.withValues(alpha: 0.9),
                ),
              ),
              Text(
                '$total',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Three Statistics
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  theme,
                  'Upcoming',
                  upcoming,
                  IconsaxPlusLinear.notification_bing,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSummaryItem(
                  theme,
                  'Overdue',
                  overdue,
                  IconsaxPlusLinear.warning_2,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSummaryItem(
                  theme,
                  'Completed',
                  completed,
                  IconsaxPlusLinear.tick_circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Individual Statistics Container
  Widget _buildSummaryItem(
    ThemeData theme,
    String label,
    int count,
    IconData icon,
  ) {
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: colors.onPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.onPrimary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$count',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.onPrimary.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // SECTION HEADER
  // --------------------------------------------------

  Widget _buildSectionHeader(
    ThemeData theme,
    String title,
    IconData icon, {
    required int count,
  }) {
    final colors = theme.colorScheme;

    return Row(
      children: [
        Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: theme.textTheme.labelSmall?.copyWith(color: colors.primary),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // REMINDER CARD
  // --------------------------------------------------

  Widget _buildReminderCard(
    ThemeData theme,
    ReminderModel reminder, {
    bool isOverdue = false,
    bool isCompleted = false,
  }) {
    final application = _getApplication(reminder.applicationId);
    final colors = theme.colorScheme;

    final statusColor = isCompleted
        ? colors.tertiary
        : isOverdue
            ? colors.error
            : colors.primary;

    return InkWell(
      onTap: () => _openReminderDetails(reminder),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.65)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isCompleted
                        ? IconsaxPlusLinear.tick_circle
                        : isOverdue
                            ? IconsaxPlusLinear.warning_2
                            : IconsaxPlusLinear.notification,
                    color: statusColor,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        application?.companyName ?? 'Application unavailable',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      if (application != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          application.jobTitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            Divider(height: 1, color: theme.dividerColor),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  IconsaxPlusLinear.calendar_1,
                  size: 15,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    DateFormat('dd MMM yyyy, hh:mm a')
                        .format(reminder.reminderDate),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                if (isCompleted)
                  _buildStatusBadge(theme, 'Completed', colors.tertiary)
                else if (isOverdue)
                  _buildStatusBadge(theme, 'Overdue', colors.error)
                else
                  _buildStatusBadge(theme, 'Upcoming', colors.primary),
              ],
            ),
            if (!isCompleted) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _completeReminder(reminder),
                  icon: const Icon(
                    IconsaxPlusLinear.tick_circle,
                    size: 19,
                  ),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Mark as Completed', maxLines: 1),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.tertiary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    side: BorderSide(
                      color: colors.tertiary.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // STATUS BADGE
  // --------------------------------------------------

  Widget _buildStatusBadge(ThemeData theme, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }

  // --------------------------------------------------
  // EMPTY STATE
  // --------------------------------------------------

  // Empty State
  Widget _buildEmptyState(
    ThemeData theme, {
    required IconData icon,
    required String title,
  }) {
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.45)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: colors.onSurfaceVariant.withValues(alpha: 0.35),
            size: 30,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colors.onSurfaceVariant.withValues(alpha: 0.35),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}