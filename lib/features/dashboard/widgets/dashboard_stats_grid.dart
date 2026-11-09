
import 'package:apply_roster/features/applications/controllers/application_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';

class DashboardStatsGrid extends GetView<ApplicationController> {
  const DashboardStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final counts = controller.dashboardCounts;
      final isLoading = controller.isLoading.value;

      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 13,
        crossAxisSpacing: 13,
        childAspectRatio: 1.48,
        children: [
          _StatCard(
            title: 'Total Applications',
            count: counts['total'] ?? 0,
            icon: Icons.work_outline_rounded,
            color: AppColors.primary,
            isLoading: isLoading,
          ),
          _StatCard(
            title: 'Interviews',
            count: counts['interviews'] ?? 0,
            icon: Icons.calendar_month_rounded,
            color: AppColors.accent,
            isLoading: isLoading,
          ),
          _StatCard(
            title: 'Offers',
            count: counts['offers'] ?? 0,
            icon: Icons.emoji_events_rounded,
            color: AppColors.success,
            isLoading: isLoading,
          ),
          _StatCard(
            title: 'Rejected',
            count: counts['rejected'] ?? 0,
            icon: Icons.cancel_outlined,
            color: AppColors.error,
            isLoading: isLoading,
          ),
        ],
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final bool isLoading;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surface;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.alphaBlend(
              color.withValues(alpha: 0.09),
              surfaceColor,
            ),
            Color.alphaBlend(
              color.withValues(alpha: 0.025),
              surfaceColor,
            ),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.20),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 39,
                width: 39,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 21,
                ),
              ),
              Icon(
                Icons.arrow_outward_rounded,
                size: 17,
                color: color.withValues(alpha: 0.65),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  isLoading ? '—' : '$count',
                  key: ValueKey(isLoading ? 'loading' : count),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    letterSpacing: -1,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
