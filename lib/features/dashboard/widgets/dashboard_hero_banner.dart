import 'package:apply_roster/features/applications/controllers/application_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class DashboardHeroBanner extends GetView<ApplicationController> {
  const DashboardHeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Obx(() {
      final counts = controller.dashboardCounts;
      final isLoading = controller.isLoading.value;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading
            Row(
              children: [
                const Icon(
                  IconsaxPlusLinear.chart_1,
                  color: Colors.white,
                  size: 25,
                ),
                const SizedBox(width: 9),
                Text(
                  'Application Overview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Total Applications
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Applications',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  isLoading ? '—' : '${counts['total'] ?? 0}',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1.2,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // First Row
            Row(
              children: [
                Expanded(
                  child: _OverviewStatTile(
                    title: 'Applied',
                    count: counts['applied'] ?? 0,
                    isLoading: isLoading,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _OverviewStatTile(
                    title: 'Interviews',
                    count: counts['interviews'] ?? 0,
                    isLoading: isLoading,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Second Row
            Row(
              children: [
                Expanded(
                  child: _OverviewStatTile(
                    title: 'Offers',
                    count: counts['offers'] ?? 0,
                    isLoading: isLoading,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _OverviewStatTile(
                    title: 'Rejected',
                    count: counts['rejected'] ?? 0,
                    isLoading: isLoading,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _OverviewStatTile extends StatelessWidget {
  final String title;
  final int count;
  final bool isLoading;

  const _OverviewStatTile({
    required this.title,
    required this.count,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              isLoading ? '—' : '$count',
              key: ValueKey(isLoading ? 'loading' : count),
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
