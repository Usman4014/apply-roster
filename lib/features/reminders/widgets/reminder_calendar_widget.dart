
import 'package:apply_roster/features/reminders/models/reminder_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReminderCalendarWidget extends StatefulWidget {
  final List<ReminderModel> reminders;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const ReminderCalendarWidget({
    super.key,
    required this.reminders,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<ReminderCalendarWidget> createState() =>
      _ReminderCalendarWidgetState();
}

class _ReminderCalendarWidgetState extends State<ReminderCalendarWidget> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _displayedMonth = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
    );
  }

  @override
  void didUpdateWidget(covariant ReminderCalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedDate != widget.selectedDate) {
      if (oldWidget.selectedDate.month != widget.selectedDate.month ||
          oldWidget.selectedDate.year != widget.selectedDate.year) {
        _displayedMonth = DateTime(
          widget.selectedDate.year,
          widget.selectedDate.month,
        );
      }
    }
  }

  void _changeMonth(int offset) {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + offset,
      );
    });
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  List<ReminderModel> _getRemindersForDate(DateTime date) {
    return widget.reminders.where((reminder) {
      return _isSameDay(reminder.reminderDate, date);
    }).toList();
  }

  Color _getCategoryColor(
    ReminderModel reminder,
    ColorScheme colors,
  ) {
    final text = '${reminder.title} ${reminder.description ?? ''}'
        .toLowerCase();

    if (text.contains('interview')) {
      return colors.primary;
    }

    if (text.contains('follow-up') ||
        text.contains('follow up') ||
        text.contains('followup')) {
      return colors.secondary;
    }

    return colors.tertiary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final firstDayOfMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      1,
    );

    final daysInMonth = DateUtils.getDaysInMonth(
      _displayedMonth.year,
      _displayedMonth.month,
    );

    // Monday is the first day of the week.
    final startOffset = firstDayOfMonth.weekday - 1;

    final today = DateUtils.dateOnly(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month Header
          Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat('MMMM yyyy').format(_displayedMonth),
                  style: theme.textTheme.titleMedium,
                ),
              ),
              _MonthNavigationButton(
                icon: Icons.chevron_left_rounded,
                onTap: () => _changeMonth(-1),
              ),
              const SizedBox(width: 8),
              _MonthNavigationButton(
                icon: Icons.chevron_right_rounded,
                onTap: () => _changeMonth(1),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Weekday Labels
          Row(
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),

          // Calendar Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 42,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 7,
              crossAxisSpacing: 4,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) {
              final dayNumber = index - startOffset + 1;

              final isCurrentMonth =
                  dayNumber >= 1 && dayNumber <= daysInMonth;

              final date = DateTime(
                _displayedMonth.year,
                _displayedMonth.month,
                dayNumber,
              );

              final reminders = isCurrentMonth
                  ? _getRemindersForDate(date)
                  : <ReminderModel>[];

              final isSelected = _isSameDay(date, widget.selectedDate);
              final isToday = _isSameDay(date, today);

              return InkWell(
                onTap: isCurrentMonth
                    ? () => widget.onDateSelected(date)
                    : null,
                borderRadius: BorderRadius.circular(11),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primary
                        : isToday
                            ? colors.primary.withValues(alpha: 0.08)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                    border: isToday && !isSelected
                        ? Border.all(
                            color: colors.primary.withValues(alpha: 0.35),
                          )
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${date.day}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: !isCurrentMonth
                              ? theme.disabledColor
                              : isSelected
                                  ? colors.onPrimary
                                  : colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Reminder Indicators
                      SizedBox(
                        height: 5,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: reminders.take(3).map((reminder) {
                            return Container(
                              width: 4,
                              height: 4,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 1,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colors.onPrimary
                                    : _getCategoryColor(reminder, colors),
                                shape: BoxShape.circle,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 18),

          // Legend
          Wrap(
            spacing: 15,
            runSpacing: 9,
            children: [
              _LegendItem(
                color: colors.primary,
                label: 'Interview',
              ),
              _LegendItem(
                color: colors.secondary,
                label: 'Follow-up',
              ),
              _LegendItem(
                color: colors.tertiary,
                label: 'General',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthNavigationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MonthNavigationButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.scaffoldBackgroundColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 36,
          width: 36,
          child: Icon(
            icon,
            color: theme.colorScheme.onSurface,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 7,
          width: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
