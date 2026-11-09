import 'package:apply_roster/app/routes/app_routes.dart';
import 'package:apply_roster/core/constants/app_constants.dart';
import 'package:apply_roster/features/applications/controllers/application_controller.dart';
import 'package:apply_roster/features/applications/models/application_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class UpcomingInterviewsWidget extends StatelessWidget {
  UpcomingInterviewsWidget({super.key});

  final ApplicationController _applicationController =
      Get.find<ApplicationController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Obx(() {
      final interviews = _applicationController.applications
          .where(
            (application) => application.status == AppConstants.statusInterview,
          )
          .toList();

      if (interviews.isEmpty) {
        return _buildEmptyState(theme, colors);
      }

      return Column(
        children: interviews
            .map(
              (application) => _buildInterviewCard(theme, colors, application),
            )
            .toList(),
      );
    });
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colors) {
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
            IconsaxPlusLinear.clock,
            color: colors.onSurfaceVariant.withValues(alpha: 0.35),
            size: 30,
          ),
          const SizedBox(height: 10),
          Text(
            'No Upcoming Interviews',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.onSurfaceVariant.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterviewCard(
  ThemeData theme,
  ColorScheme colors,
  ApplicationModel application,
) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: colors.primary.withValues(alpha: 0.14)),
      boxShadow: [
        BoxShadow(
          color: colors.shadow.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Get.toNamed(AppRoutes.applicationDetails, arguments: application);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  IconsaxPlusLinear.briefcase,
                  color: colors.primary,
                  size: 23,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.companyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
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
                    const SizedBox(height: 5),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          IconsaxPlusLinear.calendar,
                          size: 13,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Interview',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                IconsaxPlusLinear.arrow_right_3,
                color: colors.onSurfaceVariant,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
