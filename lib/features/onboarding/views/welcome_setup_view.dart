import 'package:apply_roster/app/routes/app_routes.dart';
import 'package:apply_roster/core/utils/app_snackbar.dart';
import 'package:apply_roster/features/user/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class WelcomeSetupView extends StatefulWidget {
  const WelcomeSetupView({super.key});

  @override
  State<WelcomeSetupView> createState() => _WelcomeSetupViewState();
}

class _WelcomeSetupViewState extends State<WelcomeSetupView> {
  final UserController userController = Get.find<UserController>();

  final TextEditingController nameController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isSaving = false;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (isSaving) return;

    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isSaving = true;
    });

    try {
      final saved = await userController.saveUserName(
        nameController.text.trim(),
      );

      if (!mounted) return;

      if (saved) {
        Get.offAllNamed(AppRoutes.main);
      } else {
        setState(() {
          isSaving = false;
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      AppSnackbar.error(
        'Something Went Wrong',
        'Unable to save your name. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Center Content
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ApplyRoster Logo
                        Center(
                          child: Image.asset(
                            'assets/apply_roster_logo.png',
                            height: 150,
                            width: 150,
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Welcome Heading
                        Text(
                          'Welcome to ApplyRoster!',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.6,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Name Field
                        TextFormField(
                          controller: nameController,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.name,
                          maxLength: 40,
                          onFieldSubmitted: (_) => _continue(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isLight
                                ? Colors.black
                                : theme.textTheme.bodyMedium?.color,
                          ),
                          validator: (value) {
                            final name = value?.trim() ?? '';

                            if (name.isEmpty) {
                              return 'Please enter your name';
                            }

                            if (name.length < 2) {
                              return 'Name must contain at least 2 characters';
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Enter your name',
                            hintStyle: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant.withValues(
                                alpha: 0.78,
                              ),
                            ),
                            prefixIcon: const Icon(
                              IconsaxPlusLinear.user,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: theme.cardColor,
                            counterText: '',
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
                                color: theme.dividerColor.withValues(
                                  alpha: 0.7,
                                ),
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
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Button
        Padding(
  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
  child: SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: isSaving ? null : _continue,
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
      child: isSaving
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
              ),
            )
          : const Text('Get Started'),
    ),
  ),
),
          ],
        ),
      ),
    );
  }
}
