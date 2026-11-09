import 'package:apply_roster/app/controllers/app_controller.dart';
import 'package:apply_roster/app/routes/app_routes.dart';
import 'package:apply_roster/core/constants/app_constants.dart';
import 'package:apply_roster/core/utils/app_snackbar.dart';
import 'package:apply_roster/features/notifications/controllers/notification_controller.dart';
import 'package:apply_roster/features/user/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class SettingsView extends GetView<AppController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Header
            _buildHeader(context),

            // Scrollable Settings Content
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildPersonalizationSection(context),
                  ),
                  SliverToBoxAdapter(child: _buildAppearanceSection(context)),
                  SliverToBoxAdapter(child: _buildPreferencesSection(context)),
                  SliverToBoxAdapter(child: _buildAboutSection(context)),
                  SliverToBoxAdapter(child: _buildFooter(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HEADER

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              textAlign: TextAlign.left,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Customize your app experience',
              textAlign: TextAlign.left,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PERSONALIZATION

  Widget _buildPersonalizationSection(BuildContext context) {
    final userController = Get.find<UserController>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Obx(() {
        final name = userController.userName.value.trim();

        return Row(
          children: [
            Expanded(
              child: Text(
                name.isEmpty ? 'Your Name' : name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _showEditNameSheet(context, userController),
              child: Padding(
                padding: const EdgeInsets.all(11),
                child: Icon(
                  IconsaxPlusLinear.edit_2,
                  size: 23,
                  color: colors.primary,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showEditNameSheet(BuildContext context, UserController userController) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditNameBottomSheet(userController: userController),
    );
  }

  // APPEARANCE

  Widget _buildAppearanceSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Appearance',
      child: Obx(() {
        final selectedMode = controller.themeMode.value;

        return Column(
          children: [
            _buildThemeOption(
              context,
              title: 'Light Mode',
              mode: ThemeMode.light,
              selectedMode: selectedMode,
            ),
            _buildRowDivider(context),
            _buildThemeOption(
              context,
              title: 'Dark Mode',
              mode: ThemeMode.dark,
              selectedMode: selectedMode,
            ),
            _buildRowDivider(context),
            _buildThemeOption(
              context,
              title: 'System Default',
              mode: ThemeMode.system,
              selectedMode: selectedMode,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required ThemeMode mode,
    required ThemeMode selectedMode,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isSelected = selectedMode == mode;
    final isLight = theme.brightness == Brightness.light;
    return InkWell(
      onTap: () => controller.changeThemeMode(mode),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isLight
                      ? Colors.black
                      : theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? colors.primary : colors.onSurfaceVariant,
              size: 21,
            ),
          ],
        ),
      ),
    );
  }

  // NOTIFICATION PREFERENCES

  Widget _buildPreferencesSection(BuildContext context) {
    final notificationController = Get.find<NotificationController>();

    return _buildSection(
      context,
      title: 'Notification Preferences',
      child: Column(
        children: [
          _buildNotificationSwitch(
            context,
            title: 'Interview Notifications',
            value: notificationController.interviewNotifications,
            onChanged: notificationController.setInterviewNotifications,
          ),
          _buildRowDivider(context),
          _buildNotificationSwitch(
            context,
            title: 'Follow-up Notifications',
            value: notificationController.followUpNotifications,
            onChanged: notificationController.setFollowUpNotifications,
          ),
          _buildRowDivider(context),
          _buildNotificationSwitch(
            context,
            title: 'Application Updates',
            value: notificationController.applicationNotifications,
            onChanged: notificationController.setApplicationNotifications,
          ),
          _buildRowDivider(context),
          _buildNotificationSwitch(
            context,
            title: 'General Notifications',
            value: notificationController.generalNotifications,
            onChanged: notificationController.setGeneralNotifications,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSwitch(
    BuildContext context, {
    required String title,
    required RxBool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isLight
                      ? Colors.black
                      : theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),
            Switch.adaptive(
              value: value.value,
              activeTrackColor: colors.primary,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  // ABOUT

  Widget _buildAboutSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'About',
      child: Column(
        children: [
          _buildSettingTile(
            context,
            title: 'Privacy Policy',
            showArrow: true,
            onTap: () => Get.toNamed(AppRoutes.privacyPolicy),
          ),
          _buildRowDivider(context),
          _buildSettingTile(
            context,
            title: 'About ApplyRoster',
            showArrow: true,
            onTap: () => Get.toNamed(AppRoutes.about),
          ),
          _buildRowDivider(context),
          _buildSettingTile(
            context,
            title: 'Rate ApplyRoster',
            onTap: () {
              AppSnackbar.info(
                'Coming Soon',
                'App rating will be available soon',
              );
            },
          ),
        ],
      ),
    );
  }

  // COMMON SECTION

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 10),
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.5),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  // SETTING TILE

  Widget _buildSettingTile(
    BuildContext context, {
    required String title,
    String? trailingText,
    VoidCallback? onTap,
    bool showArrow = true,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isLight
                      ? Colors.black
                      : theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),
            if (trailingText != null) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  trailingText,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            if (showArrow) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: colors.onSurfaceVariant,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ROW DIVIDER

  Widget _buildRowDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.7,
      indent: 16,
      endIndent: 16,
      color: Theme.of(context).dividerColor.withValues(alpha: 0.45),
    );
  }

  // FOOTER

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 30),
      child: Column(
        children: [
          Text(
            AppConstants.appName,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Version 1.0.0  •  © ${DateTime.now().year} ${AppConstants.appName}. All rights reserved.',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class EditNameBottomSheet extends StatefulWidget {
  final UserController userController;

  const EditNameBottomSheet({super.key, required this.userController});

  @override
  State<EditNameBottomSheet> createState() => _EditNameBottomSheetState();
}

class _EditNameBottomSheetState extends State<EditNameBottomSheet> {
  late final TextEditingController _nameController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.userController.userName.value,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    if (_isSaving) return;

    final name = _nameController.text.trim();

    if (name.isEmpty) {
      AppSnackbar.error('Invalid Name', 'Please enter your name.');
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() => _isSaving = true);

    try {
      final saved = await widget.userController.saveUserName(name);

      if (!mounted) return;

      if (saved) {
        Navigator.of(context).pop();

        AppSnackbar.success('Success', 'Your name has been updated.');
      } else {
        setState(() => _isSaving = false);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSaving = false);

      AppSnackbar.error(
        'Error',
        'Unable to update your name. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.outlineVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Edit Your Name',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                autofocus: true,
                enabled: !_isSaving,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                maxLength: 40,
                onSubmitted: (_) => _saveName(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isLight
                      ? Colors.black
                      : theme.textTheme.bodyMedium?.color,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.78),
                  ),
                  prefixIcon: const Icon(IconsaxPlusLinear.user, size: 20),
                  prefixIconColor: colors.onSurfaceVariant,
                  filled: true,
                  fillColor: theme.cardColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide(color: theme.dividerColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.7),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide(color: colors.primary, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide(color: colors.error),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving
                          ? null
                          : () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              Navigator.of(context).pop();
                            },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveName,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSaving
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.onPrimary,
                              ),
                            )
                          : const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
