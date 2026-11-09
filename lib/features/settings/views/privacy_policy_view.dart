import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(IconsaxPlusLinear.arrow_left),
        ),
        title: const Text('Privacy Policy'),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 24),
              _buildIntro(theme),
              const SizedBox(height: 24),
              _buildPolicySection(
                theme,
                icon: IconsaxPlusLinear.archive_1,
                title: '1. Information We Store',
                content:
                    'ApplyRoster allows you to save job application '
                    'details such as company names, job titles, job links, '
                    'application dates, statuses, notes and reminders. '
                    'This information is stored locally on your device '
                    'using the app database and local preferences.',
              ),
              _buildPolicySection(
                theme,
                icon: IconsaxPlusLinear.cloud,
                title: '2. No Account or Cloud Sync',
                content:
                    'ApplyRoster currently does not require account '
                    'registration or login. The app does not provide '
                    'cloud synchronization or a remote user account. '
                    'Your application records are intended to remain '
                    'on your device.',
              ),
              _buildPolicySection(
                theme,
                icon: IconsaxPlusLinear.notification,
                title: '3. Notifications',
                content:
                    'ApplyRoster can schedule local notifications for '
                    'interviews, follow-ups and other reminders. '
                    'Notification permission is requested so your device '
                    'can display these reminders. You can manage '
                    'notification preferences from Settings or your '
                    'device settings.',
              ),
              _buildPolicySection(
                theme,
                icon: IconsaxPlusLinear.shield_security,
                title: '4. Data Security',
                content:
                    'Your application information is stored locally '
                    'within the app on your device. We recommend keeping '
                    'your device protected with its screen lock and '
                    'operating system security updates.',
              ),
              _buildPolicySection(
                theme,
                icon: IconsaxPlusLinear.trash,
                title: '5. Data Deletion',
                content:
                    'You can delete individual applications and reminders '
                    'within the app. Clearing the app storage or '
                    'uninstalling ApplyRoster may permanently remove '
                    'locally stored information. Make sure you no longer '
                    'need your data before clearing app storage.',
              ),
              _buildPolicySection(
                theme,
                icon: IconsaxPlusLinear.profile_2user,
                title: '6. Children’s Privacy',
                content:
                    'ApplyRoster is a job application management tool '
                    'and is not designed specifically for children. '
                    'The app does not knowingly collect personal '
                    'information from children through an online account.',
              ),
              _buildPolicySection(
                theme,
                icon: IconsaxPlusLinear.refresh_2,
                title: '7. Policy Updates',
                content:
                    'This Privacy Policy may be updated when app '
                    'features or data practices change. Please review '
                    'this screen periodically for the latest information.',
              ),
              _buildPolicySection(
                theme,
                icon: IconsaxPlusLinear.message_question,
                title: '8. Contact',
                content:
                    'If you have questions about this Privacy Policy, '
                    'please contact the ApplyRoster developer through '
                    'the support contact provided on the app’s '
                    'official store listing.',
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Last updated: 5 November 2026',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(IconsaxPlusLinear.shield_tick, color: colors.primary, size: 42),
        const SizedBox(height: 18),
        Text(
          'Your Privacy Matters',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Understand how ApplyRoster handles your '
          'information and reminders.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildIntro(ThemeData theme) {
    final colors = theme.colorScheme;

    return Text(
      'ApplyRoster is designed to help you organize your job search. '
      'This policy explains how information is handled by the current '
      'version of the application.',
      style: theme.textTheme.bodyLarge?.copyWith(
        height: 1.7,
        color: colors.onSurfaceVariant,
      ),
    );
  }

  Widget _buildPolicySection(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.65)),
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
                child: Icon(icon, color: colors.primary, size: 22),
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
            content,
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
