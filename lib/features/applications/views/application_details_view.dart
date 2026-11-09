import 'package:apply_roster/core/utils/app_snackbar.dart';
import 'package:apply_roster/features/applications/controllers/application_controller.dart';
import 'package:apply_roster/features/applications/models/application_model.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class ApplicationDetailsView extends StatefulWidget {
  final ApplicationModel application;

  const ApplicationDetailsView({super.key, required this.application});

  @override
  State<ApplicationDetailsView> createState() => _ApplicationDetailsViewState();
}

class _ApplicationDetailsViewState extends State<ApplicationDetailsView> {
  final ApplicationController _controller = Get.find<ApplicationController>();

  late ApplicationModel _application;
  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _application = widget.application;
    _loadHistory();
  }

  Future<void> _editApplication() async {
    final result = await Get.toNamed(
      AppRoutes.addApplication,
      arguments: _application,
    );

    if (!mounted || result == null) return;

    if (result is ApplicationModel) {
      setState(() {
        _application = result;
        _loadHistory();
      });

      debugPrint('REFRESHED COMPANY: ${_application.companyName}');
      debugPrint('REFRESHED JOB TITLE: ${_application.jobTitle}');
    }
  }

  Future<void> _openJobUrl(String url) async {
    var value = url.trim();

    if (value.isEmpty) return;

    // Add HTTPS if the URL has no scheme.
    if (!value.startsWith(RegExp(r'https?://', caseSensitive: false))) {
      value = 'https://$value';
    }

    final uri = Uri.tryParse(value);

    if (uri == null ||
        uri.host.isEmpty ||
        !['http', 'https'].contains(uri.scheme.toLowerCase())) {
      Get.snackbar('Invalid URL', 'Please check the job posting URL.');
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        Get.snackbar(
          'Unable to Open Link',
          'Could not open the job posting URL.',
        );
      }
    } catch (e) {
      Get.snackbar(
        'Unable to Open Link',
        'Something went wrong while opening the URL.',
      );
    }
  }

  Future<void> _addReminder() async {
    if (_application.id == null) return;

    await Get.toNamed(
      AppRoutes.addReminder,
      arguments: {'initialApplicationId': _application.id},
    );
  }

  Future<void> _confirmDeleteApplication() async {
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
            Text(
              'Delete Application?',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              'Are you sure you want to delete '
              '${_application.companyName} application? '
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
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onError,
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

    if (confirmed != true || _application.id == null) return;

    final success = await _controller.deleteApplication(_application.id!);

    if (!mounted || !success) return;

    Get.back();

    Future.delayed(const Duration(milliseconds: 300), () {
      AppSnackbar.success(
        'Application Deleted!',
        'Your application has been deleted successfully.',
      );
    });
  }

  void _loadHistory() {
    final id = _application.id;

    if (id != null) {
      _historyFuture = _controller.getStatusHistory(id);
    } else {
      _historyFuture = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final application = _application;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: Text('Application Details', style: theme.textTheme.titleLarge),
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(IconsaxPlusLinear.arrow_left),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit Application',
            onPressed: _editApplication,
            icon: Icon(
              IconsaxPlusLinear.edit_2,
              color: colors.primary,
              size: 23,
            ),
          ),
          IconButton(
            tooltip: 'Delete Application',
            onPressed: _confirmDeleteApplication,
            icon: Icon(IconsaxPlusLinear.trash, color: colors.error),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCompanyHeader(context),
            const SizedBox(height: 22),
            _buildSectionTitle(context, 'Application Status'),
            const SizedBox(height: 12),
            _buildStatusCard(context),
            const SizedBox(height: 14),
            _buildAddReminderButton(context),
            const SizedBox(height: 25),
            _buildSectionTitle(context, 'Job Details'),
            const SizedBox(height: 12),
            _buildInfoCard(context, [
              _InfoItem(
                icon: IconsaxPlusLinear.briefcase,
                label: 'Employment Type',
                value: application.employmentType,
              ),
              _InfoItem(
                icon: IconsaxPlusLinear.wallet,
                label: 'Salary',
                value: application.salary,
              ),
              _InfoItem(
                icon: IconsaxPlusLinear.link,
                label: 'Job Posting URL',
                value: application.jobUrl,
              ),
              _InfoItem(
                icon: IconsaxPlusLinear.folder,
                label: 'Application Source',
                value: application.source,
              ),
              _InfoItem(
                icon: IconsaxPlusLinear.calendar,
                label: 'Applied Date',
                value: DateFormat('dd MMMM, yyyy')
                    .format(application.appliedDate),
              ),
            ]),
            if (application.notes != null &&
                application.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 25),
              _buildSectionTitle(context, 'Additional Notes'),
              const SizedBox(height: 12),
              _buildNotesCard(context),
            ],
            const SizedBox(height: 25),
            _buildSectionTitle(context, 'Status History'),
            const SizedBox(height: 12),
            _buildHistorySection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAddReminderButton(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.65)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _application.id == null ? null : _addReminder,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    IconsaxPlusLinear.notification,
                    color: colors.primary,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Set a Reminder', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text(
                        'Schedule an interview or follow-up',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  IconsaxPlusLinear.arrow_right,
                  size: 17,
                  color: colors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final application = _application;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: colors.onPrimary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(17),
            ),
            alignment: Alignment.center,
            child: Text(
              application.companyName.isNotEmpty
                  ? application.companyName[0].toUpperCase()
                  : '?',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: colors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 17),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  application.companyName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  application.jobTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onPrimary.withValues(alpha: 0.9),
                  ),
                ),
                if (application.location != null &&
                    application.location!.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        IconsaxPlusLinear.location,
                        size: 17,
                        color: colors.onPrimary.withValues(alpha: 0.85),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          application.location!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onPrimary.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final status = _application.status;
    final color = _getStatusColor(status);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        debugPrint('STATUS CARD PRESSED');
        _showStatusSelector();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.65)),
        ),
        child: Row(
          children: [
            Container(
              height: 43,
              width: 43,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(_getStatusIcon(status), color: color, size: 22),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Status',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: theme.textTheme.titleSmall?.copyWith(color: color),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Current',
                style: theme.textTheme.labelSmall?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusSelector() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final statuses = [
      AppConstants.statusApplied,
      AppConstants.statusInterview,
      AppConstants.statusOffer,
      AppConstants.statusRejected,
    ];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 25),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 42,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Update Application Status',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Select the latest status of this application.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              ...statuses.map((status) {
                final selected = _application.status == status;
                final color = _getStatusColor(status);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(13),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                        side: BorderSide(
                          color: selected ? colors.primary : theme.dividerColor,
                        ),
                      ),
                      leading: Icon(_getStatusIcon(status), color: color),
                      title: Text(status, style: theme.textTheme.titleSmall),
                      trailing: selected
                          ? Icon(
                              IconsaxPlusLinear.tick_circle,
                              color: colors.primary,
                            )
                          : null,
                      onTap: () async {
                        Get.back();

                        if (selected || _application.id == null) {
                          return;
                        }

                        final success = await _controller.updateStatus(
                          _application.id!,
                          status,
                        );

                        if (!mounted || !success) return;

                        setState(() {
                          _application = _application.copyWith(status: status);

                          _loadHistory();
                        });

                        if (status == AppConstants.statusInterview &&
                            _application.id != null) {
                          await Future.delayed(
                            const Duration(milliseconds: 300),
                          );

                          if (!mounted) return;

                          await Get.toNamed(
                            AppRoutes.addReminder,
                            arguments: {
                              'initialApplicationId': _application.id,
                            },
                          );
                        }
                      },
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildInfoCard(BuildContext context, List<_InfoItem> items) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final visibleItems = items
        .where((item) => item.value != null && item.value!.trim().isNotEmpty)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.65)),
      ),
      child: Column(
        children: List.generate(visibleItems.length, (index) {
          final item = visibleItems[index];

          return Padding(
            padding: EdgeInsets.only(
              bottom: index == visibleItems.length - 1 ? 0 : 17,
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
                      const SizedBox(height: 4),
                      if (item.label == 'Job Posting URL')
                        InkWell(
                          onTap: () => _openJobUrl(item.value!),
                          borderRadius: BorderRadius.circular(4),
                          child: Text(
                            item.value!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: colors.primary,
                            ),
                          ),
                        )
                      else
                        Text(item.value!, style: theme.textTheme.bodyMedium),
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

  Widget _buildNotesCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.65)),
      ),
      child: Text(
        _application.notes!,
        style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return _historyMessage(
            context,
            'Unable to load status history.',
            IconsaxPlusLinear.info_circle,
          );
        }

        final history = snapshot.data ?? [];

        if (history.isEmpty) {
          return _historyMessage(
            context,
            'No status history available.',
            IconsaxPlusLinear.clock,
          );
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.65),
            ),
          ),
          child: Column(
            children: List.generate(history.length, (index) {
              final entry = history[index];
              final newStatus = entry['new_status']?.toString() ?? '';
              final oldStatus = entry['old_status']?.toString();
              final changedAt = DateTime.tryParse(
                entry['changed_at']?.toString() ?? '',
              );

              return _buildHistoryItem(
                context,
                oldStatus: oldStatus,
                newStatus: newStatus,
                changedAt: changedAt,
                isLast: index == history.length - 1,
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildHistoryItem(
    BuildContext context, {
    required String? oldStatus,
    required String newStatus,
    required DateTime? changedAt,
    required bool isLast,
  }) {
    final theme = Theme.of(context);
    final color = _getStatusColor(newStatus);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            child: Column(
              children: [
                Container(
                  height: 12,
                  width: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: theme.dividerColor),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    oldStatus == null || oldStatus.isEmpty
                        ? 'Application created'
                        : '$oldStatus → $newStatus',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    changedAt != null
                        ? DateFormat('dd MMM yyyy, hh:mm a').format(changedAt)
                        : 'Date unavailable',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyMessage(BuildContext context, String message, IconData icon) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.65)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: colors.onSurfaceVariant),
          const SizedBox(height: 9),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
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
      padding: const EdgeInsets.only(left: 1),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.statusApplied:
        return AppColors.primary;
      case AppConstants.statusInterview:
        return AppColors.info;
      case AppConstants.statusOffer:
        return AppColors.success;
      case AppConstants.statusRejected:
        return AppColors.error;
      default:
        return AppColors.accent;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case AppConstants.statusApplied:
        return IconsaxPlusLinear.send_2;
      case AppConstants.statusInterview:
        return IconsaxPlusLinear.calendar_tick;
      case AppConstants.statusOffer:
        return IconsaxPlusLinear.medal_star;
      case AppConstants.statusRejected:
        return IconsaxPlusLinear.close_circle;
      default:
        return IconsaxPlusLinear.flag;
    }
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String? value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}
