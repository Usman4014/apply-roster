
import 'package:apply_roster/features/applications/controllers/application_controller.dart';
import 'package:apply_roster/features/applications/models/application_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';

class RecentApplicationsWidget extends GetView<ApplicationController> {
  const RecentApplicationsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final applications = controller.applications.take(4).toList();
      final isLoading = controller.isLoading.value;

      if (isLoading && applications.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
              strokeWidth: 2,
            ),
          ),
        );
      }

      if (applications.isEmpty) {
        return _buildEmptyState(context);
      }

      return Column(
        children: List.generate(applications.length, (index) {
          final application = applications[index];

          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 350 + (index * 100)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 14 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: _buildApplicationCard(context, application),
          );
        }),
      );
    });
  }

  Widget _buildApplicationCard(
    BuildContext context,
    ApplicationModel application,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final statusColor = _getStatusColor(application.status);

    final date = DateFormat('dd MMM yyyy').format(application.appliedDate);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(19),
        onTap: () {
          Get.toNamed(AppRoutes.applicationDetails, arguments: application);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.45),
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Company Avatar
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    _getInitials(application.companyName),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.primary,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 13),

              // Application Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.companyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        letterSpacing: -0.2,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      application.jobTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          IconsaxPlusLinear.calendar_1,
                          size: 12,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          date,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.15),
                  ),
                ),
                child: Text(
                  application.status,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
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
            IconsaxPlusLinear.briefcase,
            color: colors.onSurfaceVariant.withValues(alpha: 0.35),
            size: 30,
          ),
          const SizedBox(height: 10),
          Text(
            'No Recent Applications',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colors.onSurfaceVariant.withValues(alpha: 0.35),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getInitials(String companyName) {
    final words = companyName.trim().split(RegExp(r'\s+'));

    if (words.isEmpty || words.first.isEmpty) {
      return '?';
    }

    if (words.length == 1) {
      return words.first.substring(0, 1).toUpperCase();
    }

    return '${words.first[0]}${words[1][0]}'.toUpperCase();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Applied':
        return AppColors.primary;
      case 'Interview':
        return AppColors.accent;
      case 'Offer':
        return AppColors.success;
      case 'Rejected':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }
}
