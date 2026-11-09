import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(IconsaxPlusLinear.arrow_left),
        ),
        title: const Text('About ApplyRoster'),
        centerTitle: false,
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App Logo
              Image.asset(
                'assets/apply_roster_logo.png',
                height: 110,
                width: 110,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    IconsaxPlusLinear.briefcase,
                    size: 90,
                    color: colors.primary,
                  );
                },
              ),

              const SizedBox(height: 16),

              // App Name
              Text(
                'Apply Roster',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Job Application Tracker',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Track Applications. Manage Interviews. Stay Organized.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 30),

              _buildInfoCard(
                theme,
                icon: IconsaxPlusLinear.flag,
                title: 'Our Purpose',
                description:
                    'ApplyRoster helps you organize your job search, '
                    'track applications, manage interviews and stay '
                    'on top of important follow-ups.',
              ),

              _buildInfoCard(
                theme,
                icon: IconsaxPlusLinear.element_3,
                title: 'What You Can Do',
                description:
                    'Manage job applications, monitor application '
                    'statuses, schedule reminders and review your '
                    'job search progress from one place.',
              ),

              _buildInfoCard(
                theme,
                icon: IconsaxPlusLinear.devices,
                title: 'Offline First',
                description:
                    'The current version stores your application '
                    'records locally on your device. No account '
                    'registration is required.',
              ),

              const SizedBox(height: 28),

              Text(
                'Made to keep your career journey organized.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                '© 2026 ApplyRoster',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.65),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: colors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.7,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}