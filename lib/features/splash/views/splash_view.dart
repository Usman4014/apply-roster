
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/routes/app_routes.dart';
import '../../onboarding/views/onboarding_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with TickerProviderStateMixin {
  static const String _userNameKey = 'user_name';

  late final AnimationController _animationController;
  late final AnimationController _loadingController;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // Logo entrance animation.
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.75,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();

    // Animated loading indicator.
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    // Navigate after splash delay.
    _navigationTimer = Timer(
      const Duration(milliseconds: 2500),
      _navigateNext,
    );
  }

  Future<void> _navigateNext() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    final bool onboardingCompleted =
        prefs.getBool(OnboardingView.onboardingCompletedKey) ?? false;

    if (!onboardingCompleted) {
      Get.offAllNamed(AppRoutes.onboarding);
      return;
    }

    final String userName =
        prefs.getString(_userNameKey)?.trim() ?? '';

    if (userName.isEmpty) {
      Get.offAllNamed(AppRoutes.welcomeSetup);
      return;
    }

    Get.offAllNamed(AppRoutes.main);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _animationController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  Widget _buildLoadingIndicator(Color primaryColor) {
    return AnimatedBuilder(
      animation: _loadingController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            final double phase =
                (_loadingController.value * 2 * math.pi) -
                    (index * 0.8);

            final double animationValue =
                (math.sin(phase) + 1) / 2;

            final double height = 12 + (animationValue * 18);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: height,
              decoration: BoxDecoration(
                color: primaryColor.withValues(
                  alpha: 0.3 + (animationValue * 0.7),
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/apply_roster_logo.png',
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                ),
                Text(
                  'Apply Roster',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 65),
                _buildLoadingIndicator(colorScheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
