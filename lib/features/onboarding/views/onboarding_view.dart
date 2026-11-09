
import 'package:apply_roster/core/utils/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/routes/app_routes.dart';

class OnboardingView extends StatefulWidget {
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String userNameKey = 'user_name';

  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();

  int _currentPage = 0;
  bool _isFinishing = false;

  final List<Map<String, String>> _pages = [
    {
      'image': 'assets/page1.png',
      'title': 'Track Your Applications',
      'description':
          'Keep all your job applications organized in one place. Track companies, positions and application statuses.',
    },
    {
      'image': 'assets/page2.png',
      'title': 'Never Miss an Interview',
      'description':
          'Set interview and follow-up reminders so you stay prepared and never miss an important opportunity.',
    },
    {
      'image': 'assets/page3.png',
      'title': 'Stay on Top of Your Progress',
      'description':
          'Monitor your applications, interviews and offers with a clear overview of your job search.',
    },
  ];

  Future<void> _finishOnboarding() async {
    if (_isFinishing) return;

    setState(() {
      _isFinishing = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool(
        OnboardingView.onboardingCompletedKey,
        true,
      );

      if (!mounted) return;

      final userName =
          prefs.getString(OnboardingView.userNameKey)?.trim() ?? '';

      if (userName.isEmpty) {
        Get.offAllNamed(AppRoutes.welcomeSetup);
      } else {
        Get.offAllNamed(AppRoutes.main);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isFinishing = false;
      });

      AppSnackbar.error(
        'Something Went Wrong',
        'Unable to continue. Please try again.',
      );
    }
  }

  void _nextPage() {
    if (_currentPage == _pages.length - 1) {
      _finishOnboarding();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildNextButton(ThemeData theme) {
    return Expanded(
      child: ElevatedButton(
        onPressed: _isFinishing ? null : _nextPage,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          disabledBackgroundColor:
              theme.colorScheme.primary.withValues(alpha: 0.5),
          disabledForegroundColor: theme.colorScheme.onPrimary,
          elevation: 0,
          textStyle: theme.textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          _currentPage == _pages.length - 1
              ? 'Get Started'
              : 'Next',
        ),
      ),
    );
  }

  Widget _buildBackButton(ThemeData theme) {
    return Expanded(
      child: OutlinedButton(
        onPressed: _previousPage,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          foregroundColor: theme.colorScheme.primary,
          side: BorderSide(
            color: theme.dividerColor,
          ),
          textStyle: theme.textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('Back'),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              child: Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: _isFinishing ? null : _finishOnboarding,
                    style: TextButton.styleFrom(
                      foregroundColor: colors.primary,
                      textStyle: textTheme.labelLarge,
                    ),
                    child: const Text('Skip'),
                  ),
                ],
              ),
            ),

            // Onboarding Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const Spacer(flex: 2),

                        // Illustration
                        Expanded(
                          flex: 5,
                          child: Image.asset(
                            page['image']!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.image_not_supported_outlined,
                                size: 80,
                                color: colors.primary,
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Heading
                        Text(
                          page['title']!,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineSmall,
                        ),

                        const SizedBox(height: 14),

                        // Description
                        Text(
                          page['description']!,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                          ),
                        ),

                        const Spacer(flex: 2),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                final isActive = _currentPage == index;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? colors.primary
                        : theme.dividerColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              }),
            ),

            const SizedBox(height: 30),

            // Bottom Navigation Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Row(
                children: [
                  if (_currentPage > 0) ...[
                    _buildBackButton(theme),
                    const SizedBox(width: 16),
                  ],
                  _buildNextButton(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
