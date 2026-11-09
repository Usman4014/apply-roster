import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../app/routes/app_routes.dart';
import '../../dashboard/views/dashboard_view.dart';
import '../../applications/controllers/application_controller.dart';
import '../../applications/views/applications_view.dart';
import '../../reminders/views/reminders_view.dart';
import '../../settings/views/settings_view.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  final ApplicationController controller = Get.find<ApplicationController>();

  final List<Widget> _screens = const [
    DashboardView(),
    ApplicationsView(),
    RemindersView(),
    SettingsView(),
  ];

  void _onItemTapped(int index) {
    controller.selectedNavigationIndex.value = index;
  }

  void _openAddApplication() {
  Get.toNamed(AppRoutes.addApplication);
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final selectedIndex = controller.selectedNavigationIndex.value;

      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: IndexedStack(index: selectedIndex, children: _screens),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: SizedBox(
          height: 58,
          width: 58,
          child: FloatingActionButton(
            heroTag: 'main_navigation_add_application',
            onPressed: _openAddApplication,
            elevation: 3,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            shape: const CircleBorder(),
            tooltip: 'Add Application',
            child: const Icon(IconsaxPlusBold.add, size: 28),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          elevation: 10,
          color: theme.colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _NavigationItem(
                    icon: IconsaxPlusLinear.home_1,
                    selectedIcon: IconsaxPlusBold.home_1,
                    label: 'Home',
                    isSelected: selectedIndex == 0,
                    onTap: () => _onItemTapped(0),
                  ),
                ),
                Expanded(
                  child: _NavigationItem(
                    icon: IconsaxPlusLinear.briefcase,
                    selectedIcon: IconsaxPlusBold.briefcase,
                    label: 'Applications',
                    isSelected: selectedIndex == 1,
                    onTap: () => _onItemTapped(1),
                  ),
                ),
                const SizedBox(width: 64),
                Expanded(
                  child: _NavigationItem(
                    icon: IconsaxPlusLinear.calendar_1,
                    selectedIcon: IconsaxPlusBold.calendar_1,
                    label: 'Reminders',
                    isSelected: selectedIndex == 2,
                    onTap: () => _onItemTapped(2),
                  ),
                ),
                Expanded(
                  child: _NavigationItem(
                    icon: IconsaxPlusLinear.setting_2,
                    selectedIcon: IconsaxPlusBold.setting_2,
                    label: 'Settings',
                    isSelected: selectedIndex == 3,
                    onTap: () => _onItemTapped(3),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final color = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? selectedIcon : icon, size: 23, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
