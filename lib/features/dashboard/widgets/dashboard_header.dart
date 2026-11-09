
import 'package:apply_roster/app/routes/app_routes.dart';
import 'package:apply_roster/features/notifications/controllers/notification_controller.dart';
import 'package:apply_roster/features/user/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class DashboardHeader extends StatelessWidget {
  final VoidCallback? onNotificationTap;

  const DashboardHeader({super.key, this.onNotificationTap});

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notificationController = Get.find<NotificationController>();
    final userController = Get.find<UserController>();

    return Row(
      children: [
        // Personalized Greeting
        Expanded(
          child: Obx(() {
            final name = userController.userName.value.trim();
            final displayName = name.isEmpty
                ? 'there'
                : name.split(RegExp(r'\s+')).first;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_getGreeting()}, $displayName!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Ready for your next opportunity?',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
          }),
        ),

        // Iconsax Notification Icon
        Obx(
          () => _HeaderActionButton(
            icon: IconsaxPlusLinear.notification,
            onTap: onNotificationTap ??
                () {
                  Get.toNamed(AppRoutes.notifications);
                },
            showNotificationDot:
                notificationController.unreadCount.value > 0,
          ),
        ),
      ],
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool showNotificationDot;

  const _HeaderActionButton({
    required this.icon,
    this.onTap,
    this.showNotificationDot = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      onPressed: onTap,
      tooltip: 'Notifications',
      splashRadius: 24,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            icon,
            size: 27,
            color: theme.colorScheme.primary,
          ),
          if (showNotificationDot)
            Positioned(
              top: -2,
              right: -3,
              child: Container(
                height: 9,
                width: 9,
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.scaffoldBackgroundColor,
                    width: 1.2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
