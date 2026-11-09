import 'package:apply_roster/features/applications/controllers/application_controller.dart';
import 'package:apply_roster/features/reminders/controllers/reminder_controller.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../core/constants/app_constants.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/routes/app_routes.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_hero_banner.dart';
import '../widgets/upcoming_interviews_widget.dart';
import '../widgets/recent_applications_widget.dart';

class DashboardView extends GetView<ApplicationController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Dashboard Header
            const Padding(
              padding: EdgeInsets.fromLTRB(22, 20, 13, 10),
              child: DashboardHeader(),
            ),

            // Scrollable Dashboard Content
            Expanded(
              child: RefreshIndicator(
                color: theme.colorScheme.primary,
                onRefresh: () async {
                  await controller.loadApplications();
                  await Get.find<ReminderController>().loadReminders();
                },
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Application Overview Hero Banner
                          const DashboardHeroBanner(),

                          const SizedBox(height: 25),

                          // Upcoming Interviews
                          Row(
                            children: [
                              Expanded(
                                child: _buildSectionHeading(
                                  context,
                                  'Upcoming Interviews',
                                ),
                              ),
                              _buildSeeAllButton(
                                context,
                                onPressed: () {
                                  controller.filterByStatus(
                                    AppConstants.statusInterview,
                                  );

                                  controller.searchApplications('');

                                  controller.selectedNavigationIndex.value = 1;
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          UpcomingInterviewsWidget(),

                          const SizedBox(height: 28),

                          // Upcoming Reminders
                          _buildUpcomingRemindersSection(context),

                          const SizedBox(height: 28),

                          // Recent Applications
                          Row(
                            children: [
                              Expanded(
                                child: _buildSectionHeading(
                                  context,
                                  'Recent Applications',
                                ),
                              ),
                              _buildSeeAllButton(
                                context,
                                onPressed: () {
                                  controller.searchApplications('');
                                  controller.filterByStatus('All');
                                  controller.selectedNavigationIndex.value = 1;
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          const RecentApplicationsWidget(),

                          const SizedBox(height: 12),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingRemindersSection(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final reminderController = Get.find<ReminderController>();

    return Obx(() {
      final reminders = reminderController.upcomingReminders.take(3).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSectionHeading(context, 'Upcoming Reminders'),
              ),
              _buildSeeAllButton(
                context,
                onPressed: () {
                  controller.selectedNavigationIndex.value = 2;
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (reminders.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.45),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    IconsaxPlusLinear.alarm,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.35),
                    size: 30,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No Upcoming Reminders',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.35),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...reminders.map((reminder) {
              final application = controller.applications.firstWhereOrNull(
                (item) => item.id == reminder.applicationId,
              );

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.65),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () {
                      Get.toNamed(
                        AppRoutes.reminderDetails,
                        arguments: reminder,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.09,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              IconsaxPlusLinear.alarm,
                              color: theme.colorScheme.primary,
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
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  application?.companyName ??
                                      'Application unavailable',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  DateFormat('dd MMM, hh:mm a')
                                      .format(reminder.reminderDate),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
        ],
      );
    });
  }

  Widget _buildSectionHeading(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(letterSpacing: -0.35),
    );
  }

  Widget _buildSeeAllButton(
    BuildContext context, {
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: theme.colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        'See All',
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
