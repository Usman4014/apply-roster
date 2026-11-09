import 'package:apply_roster/features/applications/controllers/application_controller.dart';
import 'package:apply_roster/features/applications/models/application_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class ApplicationsView extends StatefulWidget {
  const ApplicationsView({super.key});

  @override
  State<ApplicationsView> createState() => _ApplicationsViewState();
}

class _ApplicationsViewState extends State<ApplicationsView> {
  final ApplicationController controller = Get.find<ApplicationController>();
  late final Worker _resetWorker;
  final TextEditingController _searchController = TextEditingController();

  final ScrollController _filterScrollController = ScrollController();

  late final PageController _pageController;

  static const List<String> _filters = [
    'All',
    AppConstants.statusApplied,
    AppConstants.statusInterview,
    AppConstants.statusOffer,
    AppConstants.statusRejected,
  ];

  late final List<GlobalKey> _filterKeys = List.generate(
    _filters.length,
    (_) => GlobalKey(),
  );

  @override
  void initState() {
    super.initState();
    _resetWorker = ever(controller.applicationsResetTrigger, (_) {
      if (mounted) {
        _resetApplicationsView();
      }
    });

    // Handle dashboard filter arguments.
    final arguments = Get.arguments;

    String initialStatus = controller.selectedStatus.value;

    if (arguments is Map && arguments['selectedStatus'] is String) {
      initialStatus = arguments['selectedStatus'] as String;
      controller.filterByStatus(initialStatus);
      controller.searchApplications('');
      _searchController.clear();
    }

    int initialIndex = _filters.indexOf(initialStatus);

    if (initialIndex < 0) {
      initialIndex = 0;
      controller.filterByStatus('All');
    }

    _pageController = PageController(initialPage: initialIndex);

    // Keep the initially selected filter visible.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scrollToFilter(initialIndex);
      }
    });
  }

  void _resetApplicationsView() {
  _searchController.clear();
  controller.resetFilters();

  if (_pageController.hasClients) {
    _pageController.jumpToPage(0);
  }

  _scrollToFilter(0);
}

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    _filterScrollController.dispose();
    _resetWorker.dispose();
    super.dispose();
  }

  // Keep the selected filter visible.
  void _scrollToFilter(int index) {
    if (index < 0 || index >= _filterKeys.length) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final filterContext = _filterKeys[index].currentContext;

      if (filterContext == null) return;

      Scrollable.ensureVisible(
        filterContext,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
      );
    });
  }

  // Change selected status.
  void _changeFilter(int index) {
    if (index < 0 || index >= _filters.length) return;

    FocusManager.instance.primaryFocus?.unfocus();

    controller.filterByStatus(_filters[index]);

    if (_pageController.hasClients) {
      final currentPage = _pageController.page?.round();

      if (currentPage != index) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
        );
      } else {
        _scrollToFilter(index);
      }
    }
  }

  void resetToAllFilter() {
    _searchController.clear();
    controller.searchApplications('');
    controller.filterByStatus('All');

    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }

    _scrollToFilter(0);
  }

  // Header.
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Applications',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Manage and track your job applications',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Obx(
              () => Text(
                '${controller.applications.length} Total',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Search field.
 Widget _buildSearchField(BuildContext context) {
  final theme = Theme.of(context);
  final colors = theme.colorScheme;
final isLight = theme.brightness == Brightness.light;
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: TextField(
      controller: _searchController,
      onChanged: controller.searchApplications,
      onTapOutside: (_) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      style: theme.textTheme.bodyMedium?.copyWith(
  color: isLight ? Colors.black : theme.textTheme.bodyMedium?.color,
),
      decoration: InputDecoration(
        hintText: 'Search company or job title...',
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colors.onSurfaceVariant.withValues(alpha: 0.78),
        ),
        prefixIcon: Icon(
          IconsaxPlusLinear.search_normal_1,
          size: 20,
          color: colors.onSurfaceVariant,
        ),
        suffixIcon: Obx(
          () => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    controller.searchApplications('');
                  },
                  icon: const Icon(Icons.close_rounded),
                  color: colors.primary,
                )
              : const SizedBox.shrink(),
        ),
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
          borderSide: BorderSide(
            color: colors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: colors.error),
        ),
      ),
    ),
  );
}
  // Status filters.
  Widget _buildFilters(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      height: 65,
      child: ListView.separated(
        controller: _filterScrollController,
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final filter = _filters[index];

          return Obx(() {
            final selected = controller.selectedStatus.value == filter;

            return GestureDetector(
              onTap: () => _changeFilter(index),
              child: AnimatedContainer(
                key: _filterKeys[index],
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: selected ? colors.primary : theme.cardColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: selected ? colors.primary : theme.dividerColor,
                  ),
                ),
                child: Center(
                  child: Text(
                    filter,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: selected ? colors.onPrimary : colors.onSurface,
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  // Swipeable status pages.
  Widget _buildSwipeablePages(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Obx(() {
        if (controller.isLoading.value && controller.applications.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          );
        }

        return PageView.builder(
          controller: _pageController,
          itemCount: _filters.length,
          onPageChanged: (index) {
            FocusManager.instance.primaryFocus?.unfocus();

            controller.filterByStatus(_filters[index]);

            _scrollToFilter(index);
          },
          itemBuilder: (context, index) {
            return _buildApplicationsPage(context, _filters[index]);
          },
        );
      }),
    );
  }

  // Applications list for each status.
  Widget _buildApplicationsPage(BuildContext context, String status) {
    final theme = Theme.of(context);

    return Obx(() {
      final query = controller.searchQuery.value.toLowerCase().trim();

      final filtered = controller.applications.where((application) {
        final matchesStatus = status == 'All' || application.status == status;

        final matchesSearch =
            query.isEmpty ||
            application.companyName.toLowerCase().contains(query) ||
            application.jobTitle.toLowerCase().contains(query);

        return matchesStatus && matchesSearch;
      }).toList();

      if (filtered.isEmpty) {
        return _buildEmptyState(context);
      }

      return RefreshIndicator(
        color: theme.colorScheme.primary,
        onRefresh: controller.loadApplications,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 25),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const SizedBox(height: 13),
          itemBuilder: (context, index) {
            final application = filtered[index];

            return _buildApplicationCard(context, application);
          },
        ),
      );
    });
  }

  // Application card.
  Widget _buildApplicationCard(
    BuildContext context,
    ApplicationModel application,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final statusColor = _getStatusColor(application.status);

    return InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();

        Get.toNamed(AppRoutes.applicationDetails, arguments: application);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.65)),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.08 : 0.035,
              ),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: Text(
                      application.companyName.isNotEmpty
                          ? application.companyName[0].toUpperCase()
                          : '?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.companyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
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
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(context, application.status, statusColor),
              ],
            ),
            const SizedBox(height: 16),
            Divider(
              height: 1,
              color: theme.dividerColor.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                Icon(
                  IconsaxPlusLinear.calendar_1,
                  size: 15,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Applied ${DateFormat('dd MMM yyyy').format(application.appliedDate)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
                if (application.location != null &&
                    application.location!.isNotEmpty) ...[
                  Icon(
                    IconsaxPlusLinear.location,
                    size: 15,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      application.location!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Status badge.
  Widget _buildStatusBadge(BuildContext context, String status, Color color) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: theme.textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }

  // Status colors.
  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.statusApplied:
        return AppColors.primary;
      case AppConstants.statusInterview:
        return AppColors.info;
      case AppConstants.statusOffer:
        return AppColors.success;
      case AppConstants.statusRejected:
        return AppColors.error;
      default:
        return AppColors.accent;
    }
  }

  // Empty state.
  // Empty State
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            IconsaxPlusLinear.briefcase,
            color: colors.onSurfaceVariant.withValues(alpha: 0.35),
            size: 40,
          ),
          const SizedBox(height: 5),
          Text(
            'No Applications Found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurfaceVariant.withValues(alpha: 0.35),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchField(context),
            _buildFilters(context),
            _buildSwipeablePages(context),
          ],
        ),
      ),
    );
  }
}
