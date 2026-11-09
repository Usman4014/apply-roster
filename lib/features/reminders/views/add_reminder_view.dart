import 'package:apply_roster/core/utils/app_snackbar.dart';
import 'package:apply_roster/features/applications/controllers/application_controller.dart';
import 'package:apply_roster/features/applications/models/application_model.dart';
import 'package:apply_roster/features/reminders/controllers/reminder_controller.dart';
import 'package:apply_roster/features/reminders/models/reminder_model.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddReminderView extends StatefulWidget {
  final int? initialApplicationId;
  final DateTime? initialDate;
  final ReminderModel? reminder;

  const AddReminderView({
    super.key,
    this.initialApplicationId,
    this.initialDate,
    this.reminder,
  });

  @override
  State<AddReminderView> createState() => _AddReminderViewState();
}

class _AddReminderViewState extends State<AddReminderView> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final ApplicationController _applicationController =
      Get.find<ApplicationController>();

  final ReminderController _reminderController =
      Get.find<ReminderController>();

  int? _selectedApplicationId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  bool _isSaving = false;

  bool get isEditMode => widget.reminder != null;

  @override
  void initState() {
    super.initState();

    final applications = _applicationController.applications;

    if (isEditMode) {
      final reminder = widget.reminder!;

      _titleController.text = reminder.title;
      _descriptionController.text = reminder.description ?? '';

      _selectedApplicationId = reminder.applicationId;

      _selectedDate = DateUtils.dateOnly(reminder.reminderDate);

      _selectedTime = TimeOfDay(
        hour: reminder.reminderDate.hour,
        minute: reminder.reminderDate.minute,
      );
    } else {
      if (applications.isNotEmpty) {
        final requestedId = widget.initialApplicationId;

        final matchingApplication = applications.where(
          (application) => application.id == requestedId,
        );

        _selectedApplicationId = matchingApplication.isNotEmpty
            ? matchingApplication.first.id
            : applications.first.id;
      }

      _selectedDate = widget.initialDate != null
          ? DateUtils.dateOnly(widget.initialDate!)
          : DateTime.now().add(const Duration(days: 1));

      _selectedTime = const TimeOfDay(hour: 10, minute: 0);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  DateTime get _reminderDateTime {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  // Select Reminder Date
  Future<void> _selectDate() async {
    final theme = Theme.of(context);

    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(data: theme, child: child!);
      },
    );

    if (selected != null) {
      setState(() {
        _selectedDate = selected;
      });
    }
  }

  // Select Reminder Time
  Future<void> _selectTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (selected != null) {
      setState(() {
        _selectedTime = selected;
      });
    }
  }

  // Save Reminder
  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedApplicationId == null) {
      _showMessage(
        'Application Required',
        'Please select an application first.',
        isError: true,
      );
      return;
    }

    if (!_reminderDateTime.isAfter(DateTime.now())) {
      _showMessage(
        'Invalid Date & Time',
        'Please select a future date and time.',
        isError: true,
      );
      return;
    }

    setState(() => _isSaving = true);

    final existingReminder = widget.reminder;

    final reminder = ReminderModel(
      id: existingReminder?.id,
      applicationId: _selectedApplicationId!,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      reminderDate: _reminderDateTime,
      notificationId: existingReminder?.notificationId,
      isCompleted: existingReminder?.isCompleted ?? false,
      createdAt: existingReminder?.createdAt,
    );

    final success = isEditMode
        ? await _reminderController.updateReminder(reminder)
        : await _reminderController.addReminder(reminder);

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      Get.back(result: reminder);

      AppSnackbar.success(
        isEditMode ? 'Reminder Updated' : 'Reminder Created',
        isEditMode
            ? 'Your reminder has been updated successfully.'
            : 'Your reminder has been scheduled successfully.',
      );
    } else {
      _showMessage(
        isEditMode ? 'Unable to Update Reminder' : 'Unable to Create Reminder',
        _reminderController.errorMessage.value.isEmpty
            ? 'Something went wrong. Please try again.'
            : _reminderController.errorMessage.value,
        isError: true,
      );
    }
  }

  // Show Feedback Message
  void _showMessage(String title, String message, {bool isError = false}) {
    if (isError) {
      AppSnackbar.error(title, message);
    } else {
      AppSnackbar.info(title, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final applications = _applicationController.applications;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Edit Reminder' : 'Add Reminder',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
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
      ),
      body: SafeArea(
        child: applications.isEmpty
            ? _buildEmptyState(theme)
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildHeader(theme),
                    const SizedBox(height: 28),

                    _buildSectionTitle('Application Details', theme),
                    const SizedBox(height: 12),
                    _buildApplicationDropdown(applications, theme),

                    const SizedBox(height: 28),

                    _buildSectionTitle('Reminder Information', theme),
                    const SizedBox(height: 12),
                    _buildTitleField(theme),
                    const SizedBox(height: 16),
                    _buildDescriptionField(theme),

                    const SizedBox(height: 28),

                    _buildSectionTitle('Schedule Reminder', theme),
                    const SizedBox(height: 12),
                    _buildDateTimeSelector(theme),

                    const SizedBox(height: 32),
                    _buildSaveButton(theme),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  // Header Banner
  Widget _buildHeader(ThemeData theme) {
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            IconsaxPlusLinear.alarm,
            color: colors.onPrimary,
            size: 30,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay One Step Ahead',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Never miss an interview or follow-up.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onPrimary.withValues(alpha: 0.85),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Section Title
  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(title, style: theme.textTheme.titleMedium);
  }

  // Application Dropdown
  Widget _buildApplicationDropdown(
    List<ApplicationModel> applications,
    ThemeData theme,
  ) {
    final colors = theme.colorScheme;

    return DropdownButtonFormField<int>(
      initialValue: _selectedApplicationId,
      isExpanded: true,
        icon: Icon(
            IconsaxPlusLinear.arrow_circle_down,
            color: colors.onSurfaceVariant,
          ),
      decoration: _inputDecoration(
        label: 'Select Application',
        icon: IconsaxPlusLinear.briefcase,
      ),
      dropdownColor: colors.surface,
      style: theme.textTheme.bodyLarge?.copyWith(color: colors.onSurface),
      items: applications
          .where((application) => application.id != null)
          .map(
            (application) => DropdownMenuItem<int>(
              value: application.id!,
              child: Text(
                '${application.companyName} • ${application.jobTitle}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedApplicationId = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select an application';
        }
        return null;
      },
    );
  }

  // Reminder Title Field
  // Reminder Title Field
Widget _buildTitleField(ThemeData theme) {
  final isLight = theme.brightness == Brightness.light;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildFieldLabel('Reminder Title', theme),
      const SizedBox(height: 8),

      TextFormField(
        controller: _titleController,
        textCapitalization: TextCapitalization.sentences,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isLight
              ? Colors.black
              : theme.textTheme.bodyMedium?.color,
        ),
        decoration: _reminderInputDecoration(
          theme: theme,
          hint: 'e.g. Google Interview',
          icon: IconsaxPlusLinear.edit,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter a reminder title';
          }
          return null;
        },
      ),
    ],
  );
}
  // Reminder Description Field
  // Reminder Description Field
Widget _buildDescriptionField(ThemeData theme) {
  final isLight = theme.brightness == Brightness.light;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildFieldLabel('Description (Optional)', theme),
      const SizedBox(height: 8),

      TextFormField(
        controller: _descriptionController,
        textCapitalization: TextCapitalization.sentences,
        maxLines: 3,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isLight
              ? Colors.black
              : theme.textTheme.bodyMedium?.color,
        ),
        decoration: _reminderInputDecoration(
          theme: theme,
          hint: 'Add any important details...',
          icon: IconsaxPlusLinear.note,
          alignLabelWithHint: true,
        ),
      ),
    ],
  );
}

// Field Label - Same as Add Application
Widget _buildFieldLabel(String label, ThemeData theme) {
  return Padding(
    padding: const EdgeInsets.only(left: 1, top: 1),
    child: Text(
      label,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

// Reminder Input Decoration - Same as Add Application
InputDecoration _reminderInputDecoration({
  required ThemeData theme,
  required String hint,
  required IconData icon,
  bool alignLabelWithHint = false,
}) {
  final colors = theme.colorScheme;
  final isLight = theme.brightness == Brightness.light;

  return InputDecoration(
    hintText: hint,
    alignLabelWithHint: alignLabelWithHint,

    hintStyle: theme.textTheme.bodyMedium?.copyWith(
      color: isLight
          ? Colors.grey.shade600
          : colors.onSurfaceVariant.withValues(alpha: 0.78),
    ),

    prefixIcon: Icon(
      icon,
      size: 20,
      color: isLight ? Colors.black : colors.onSurfaceVariant,
    ),

    filled: true,
    fillColor: theme.cardColor,

    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 16,
    ),

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(color: theme.dividerColor),
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(
        color: theme.dividerColor.withValues(alpha: 0.7),
      ),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(
        color: colors.primary,
        width: 1.5,
      ),
    ),

    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(color: colors.error),
    ),

    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(
        color: colors.error,
        width: 1.5,
      ),
    ),
  );
}

  // Date and Time Selector
  Widget _buildDateTimeSelector(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildDateTimeCard(
            theme: theme,
            icon: IconsaxPlusLinear.calendar,
            label: 'Date',
            value: DateFormat('dd MMM yyyy').format(_selectedDate),
            onTap: _selectDate,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDateTimeCard(
            theme: theme,
            icon: IconsaxPlusLinear.clock,
            label: 'Time',
            value: _selectedTime.format(context),
            onTap: _selectTime,
          ),
        ),
      ],
    );
  }

  // Date and Time Card
  Widget _buildDateTimeCard({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final colors = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.65),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: colors.primary),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tap to change',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Save Button
  Widget _buildSaveButton(ThemeData theme) {
    final colors = theme.colorScheme;

    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _saveReminder,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          disabledBackgroundColor: colors.primary.withValues(alpha: 0.6),
          disabledForegroundColor: colors.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: _isSaving
            ? SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.onPrimary,
                ),
              )
            : const Icon(IconsaxPlusLinear.notification),
        label: Text(
          _isSaving
              ? (isEditMode ? 'Updating...' : 'Scheduling...')
              : (isEditMode ? 'Update Reminder' : 'Save Reminder'),
          style: theme.textTheme.titleSmall?.copyWith(
            color: colors.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // Empty Applications State
  Widget _buildEmptyState(ThemeData theme) {
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              IconsaxPlusLinear.briefcase,
             size: 45,
            color: colors.onSurfaceVariant.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 18),
            Text(
              'No Applications Yet',
              style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurfaceVariant.withValues(alpha: 0.35),
              fontWeight: FontWeight.w600,
            ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a job application first. Then you can create interview and follow-up reminders.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Shared Input Decoration
  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    required IconData icon,
    bool alignLabelWithHint = false,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(color: theme.dividerColor),
    );

    return InputDecoration(
      labelText: label,
      hintText: hint,
      alignLabelWithHint: alignLabelWithHint,
      prefixIcon: Icon(
        icon,
        size: 20,
        color: colors.onSurfaceVariant,
      ),
      hintStyle: theme.textTheme.bodyMedium?.copyWith(
        color: colors.onSurfaceVariant.withValues(alpha: 0.78),
      ),
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: colors.onSurfaceVariant,
      ),
      floatingLabelStyle: theme.textTheme.bodySmall?.copyWith(
        color: colors.primary,
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: theme.cardColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: border,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.7),
        ),
      ),
      disabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(
          color: colors.primary,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: colors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(
          color: colors.error,
          width: 1.5,
        ),
      ),
    );
  }
}