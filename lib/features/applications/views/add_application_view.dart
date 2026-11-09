import 'package:apply_roster/core/utils/app_snackbar.dart';
import 'package:apply_roster/features/applications/controllers/application_controller.dart';
import 'package:apply_roster/features/applications/models/application_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../core/constants/app_constants.dart';

class AddApplicationView extends StatefulWidget {
  final ApplicationModel? application;

  const AddApplicationView({super.key, this.application});

  bool get isEditMode => application != null;

  @override
  State<AddApplicationView> createState() => _AddApplicationViewState();
}

class _AddApplicationViewState extends State<AddApplicationView> {
  final _formKey = GlobalKey<FormState>();
  final ApplicationController _controller = Get.find<ApplicationController>();

  final _companyController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _locationController = TextEditingController();
  final _jobUrlController = TextEditingController();
  final _salaryController = TextEditingController();
  final _notesController = TextEditingController();

  final List<String> _employmentTypes = [
    AppConstants.employmentFullTime,
    AppConstants.employmentPartTime,
    AppConstants.employmentContract,
    AppConstants.employmentInternship,
    AppConstants.employmentRemote,
  ];

  final List<String> _sources = [
    AppConstants.sourceLinkedIn,
    AppConstants.sourceIndeed,
    AppConstants.sourceCompanyWebsite,
    AppConstants.sourceReferral,
    AppConstants.sourceOther,
  ];

  final List<String> _statuses = [
    AppConstants.statusApplied,
    AppConstants.statusInterview,
    AppConstants.statusOffer,
    AppConstants.statusRejected,
  ];

  String? _employmentType;
  String? _source = AppConstants.sourceLinkedIn;
  String _status = AppConstants.statusApplied;

  DateTime _appliedDate = DateTime.now();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final application = widget.application;

    if (application != null) {
      _companyController.text = application.companyName;
      _jobTitleController.text = application.jobTitle;
      _locationController.text = application.location ?? '';
      _jobUrlController.text = application.jobUrl ?? '';
      _salaryController.text = application.salary ?? '';
      _notesController.text = application.notes ?? '';

      _employmentType = application.employmentType;
      _source = application.source;
      _status = application.status;
      _appliedDate = application.appliedDate;
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _jobTitleController.dispose();
    _locationController.dispose();
    _jobUrlController.dispose();
    _salaryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectAppliedDate() async {
    final theme = Theme.of(context);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _appliedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        _appliedDate = selectedDate;
      });
    }
  }

  Future<void> _saveApplication() async {
    if (_isSaving) return;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final existingApplication = widget.application;

    if (widget.isEditMode && existingApplication?.id == null) {
      AppSnackbar.error(
        'Unable to update',
        'This application is missing its record ID.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final application = ApplicationModel(
      id: existingApplication?.id,
      companyName: _companyController.text.trim(),
      jobTitle: _jobTitleController.text.trim(),
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      employmentType: _employmentType,
      jobUrl: _jobUrlController.text.trim().isEmpty
          ? null
          : _jobUrlController.text.trim(),
      salary: _salaryController.text.trim().isEmpty
          ? null
          : _salaryController.text.trim(),
      appliedDate: _appliedDate,
      source: _source,
      // Status is updated separately to maintain status history.
      status: existingApplication?.status ?? _status,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: existingApplication?.createdAt,
      updatedAt: DateTime.now(),
    );

    final success = widget.isEditMode
        ? await _controller.updateApplication(application)
        : await _controller.addApplication(application);

    debugPrint(
      '${widget.isEditMode ? 'APPLICATION UPDATE' : 'APPLICATION SAVE'} SUCCESS: $success',
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (!success) return;

    if (widget.isEditMode) {
      // Return updated application to Details screen.
      Navigator.of(context).pop(application);
   } else {
  _controller.resetFilters();
  _controller.applicationsResetTrigger.value++;

  // Select Applications tab.
  _controller.selectedNavigationIndex.value = 1;

  Get.back();

  Future.delayed(const Duration(milliseconds: 400), () {
    AppSnackbar.success(
      'Application Added!',
      'Your job application has been saved successfully.',
    );
  });
}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: Text(
          widget.isEditMode ? 'Edit Application' : 'New Application',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(IconsaxPlusLinear.arrow_left),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIntro(context),
                    const SizedBox(height: 25),

                    _buildSectionTitle(context, 'Company Information'),
                    const SizedBox(height: 15),

                    _buildTextField(
                      context,
                      controller: _companyController,
                      label: 'Company Name',
                      hint: 'e.g. Google, Microsoft',
                      icon: IconsaxPlusLinear.building_4,
                      required: true,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      context,
                      controller: _jobTitleController,
                      label: 'Job Title',
                      hint: 'e.g. Flutter Developer',
                      icon: IconsaxPlusLinear.briefcase,
                      required: true,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      context,
                      controller: _locationController,
                      label: 'Job Location',
                      hint: 'e.g. Islamabad, Pakistan',
                      icon: IconsaxPlusLinear.location,
                    ),

                    const SizedBox(height: 27),

                    _buildSectionTitle(context, 'Job Details'),
                    const SizedBox(height: 15),

                    _buildDropdown(
                      context,
                      label: 'Employment Type',
                      hint: 'Select employment type',
                      icon: IconsaxPlusLinear.brifecase_timer,
                      value: _employmentType,
                      items: _employmentTypes,
                      onChanged: (value) {
                        setState(() {
                          _employmentType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      context,
                      controller: _jobUrlController,
                      label: 'Job Posting URL',
                      hint: 'https://company.com/careers',
                      icon: IconsaxPlusLinear.link,
                      keyboardType: TextInputType.url,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return null;
                        }

                        final uri = Uri.tryParse(value.trim());

                        if (uri == null ||
                            !uri.hasScheme ||
                            (uri.scheme != 'http' && uri.scheme != 'https') ||
                            uri.host.isEmpty) {
                          return 'Enter a valid HTTP or HTTPS URL';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      context,
                      controller: _salaryController,
                      label: 'Salary',
                      hint: 'e.g. \$80,000 / year',
                      icon: IconsaxPlusLinear.money,
                    ),

                    const SizedBox(height: 27),

                    _buildSectionTitle(context, 'Application Information'),
                    const SizedBox(height: 15),

                    _buildDateField(context),
                    const SizedBox(height: 16),

                    _buildDropdown(
                      context,
                      label: 'Application Source',
                      hint: 'Select source',
                      icon: IconsaxPlusLinear.folder_open,
                      value: _source,
                      items: _sources,
                      onChanged: (value) {
                        setState(() {
                          _source = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    if (!widget.isEditMode)
                      _buildDropdown(
                        context,
                        label: 'Application Status',
                        hint: 'Select status',
                        icon: IconsaxPlusLinear.flag,
                        value: _status,
                        items: _statuses,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _status = value;
                            });
                          }
                        },
                      ),

                    const SizedBox(height: 27),

                    _buildSectionTitle(context, 'Additional Notes'),
                    const SizedBox(height: 15),

                    _buildTextField(
                      context,
                      controller: _notesController,
                      label: 'Notes',
                      hint: 'Add interview details, contact info or other notes...',
                      icon: IconsaxPlusLinear.note_2,
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
            ),

            _buildBottomButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildIntro(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: colors.onPrimary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.onPrimary.withValues(alpha: 0.12),
              ),
            ),
            child: Icon(
              widget.isEditMode
                  ? IconsaxPlusLinear.note_2
                  : IconsaxPlusLinear.shop_add,
              color: colors.onPrimary,
              size: 28,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isEditMode
                      ? 'Update Your Application'
                      : 'Track Your Progress',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    letterSpacing: -0.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.isEditMode
                      ? 'Keep every important detail accurate and up to date.'
                      : 'Save the details today. Stay ready for what comes next.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onPrimary.withValues(alpha: 0.88),
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 1, top: 1),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.35,
        ),
      ),
    );
  }

 Widget _buildTextField(
  BuildContext context, {
  required TextEditingController controller,
  required String label,
  required String hint,
  required IconData icon,
  bool required = false,
  int maxLines = 1,
  TextInputType keyboardType = TextInputType.text,
  String? Function(String?)? validator,
}) {
  final theme = Theme.of(context);
  final colors = theme.colorScheme;
  final isLight = theme.brightness == Brightness.light;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildFieldLabel(context, label, required),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        textCapitalization: TextCapitalization.sentences,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isLight ? Colors.black : theme.textTheme.bodyMedium?.color,
        ),
        validator: validator ??
            (required
                ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '$label is required';
                    }
                    return null;
                  }
                : null),
        decoration: InputDecoration(
          hintText: hint,
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
        ),
      ),
    ],
  );
}

  Widget _buildDropdown(
    BuildContext context, {
    required String label,
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(context, label, false),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          elevation: 8,
          menuMaxHeight: 320,
          borderRadius: BorderRadius.circular(16),
          dropdownColor: theme.cardColor,
          icon: Icon(
            IconsaxPlusLinear.arrow_circle_down,
            color: colors.onSurfaceVariant,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant.withValues(alpha: 0.78),
            ),
            prefixIcon: Icon(icon, size: 20, color: colors.onSurfaceVariant),
            filled: true,
            fillColor: theme.cardColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.7),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(color: colors.primary, width: 1.5),
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDateField(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(context, 'Applied Date', false),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectAppliedDate,
          borderRadius: BorderRadius.circular(13),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.7),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  IconsaxPlusLinear.calendar_1,
                  color: colors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    DateFormat('dd MMMM, yyyy').format(_appliedDate),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  IconsaxPlusLinear.arrow_circle_down,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(BuildContext context, String label, bool required) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return RichText(
      text: TextSpan(
        text: label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colors.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
        children: [
          if (required)
            TextSpan(
              text: ' *',
              style: theme.textTheme.bodyMedium?.copyWith(color: colors.error),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    final theme = Theme.of(context);

   return Container(
  padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
  decoration: BoxDecoration(
    color: theme.cardColor,
    border: Border(
      top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
    ),
  ),
  child: SafeArea(
    top: false,
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveApplication,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          disabledBackgroundColor:
              theme.colorScheme.primary.withValues(alpha: 0.5),
          disabledForegroundColor: theme.colorScheme.onPrimary,
          elevation: 0,
          textStyle: theme.textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSaving
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: theme.colorScheme.onPrimary,
                  strokeWidth: 2,
                ),
              )
            : Text(
                widget.isEditMode ? 'Save Changes' : 'Save Application',
              ),
      ),
    ),
  ),
);
  }
}
