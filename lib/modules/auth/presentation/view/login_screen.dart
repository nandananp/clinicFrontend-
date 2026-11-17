import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_toast.dart';
import '../providers/auth_provider.dart';
import '../state/auth_state.dart';

/// Login Screen — the entry point of the application.
/// Follows VIPER View pattern: renders state from AuthNotifier and
/// forwards user actions to the Presenter.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  /// Validates the form, performs login and shows the result as a toast.
  ///
  /// The toast is shown right after the awaited login() call, so it does
  /// not depend on a listener. It works even if this screen was rebuilt or
  /// disposed while the request was running (AppToast falls back to the
  /// root navigator overlay when the context is not mounted).
  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      AppToast.showWarning(
        context,
        'Please enter your username and password.',
        title: 'Missing Information',
      );
      return;
    }

    // Read the notifier before the await, it stays valid after disposal.
    final notifier = ref.read(authNotifierProvider.notifier);

    final result = await notifier.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    final ctx = mounted ? context : null;

    if (result is AuthError) {
      AppToast.showError(
        ctx,
        result.message,
        title: 'Login Unsuccessful',
      );
    } else if (result is AuthAuthenticated) {
      AppToast.showSuccess(
        ctx,
        result.message ?? 'Welcome back!',
        title: 'Login Successful',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // Left Panel — Branding
            Expanded(
              flex: 5,
              child: _BrandingPanel(),
            ),

            // Right Panel — Login Form
            Expanded(
              flex: 4,
              child: _buildLoginFormPanel(isLoading),
            ),
          ],
        ),
      );
    }

    // Mobile / Tablet Layout
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.sidebar,
              AppColors.sidebarHover,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withAlpha(26),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(36),
              child: _buildFormContent(isLoading),
            ),
          ),
        ),
      ),
    );
  }

  /// Right panel for desktop layout containing the login form.
  Widget _buildLoginFormPanel(bool isLoading) {
    return Container(
      color: AppColors.background,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 48,
            vertical: 32,
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            child: _buildFormContent(isLoading),
          ),
        ),
      ),
    );
  }

  /// The actual login form fields and button.
  Widget _buildFormContent(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome heading
          Text(
            'Welcome Back',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 8),

          Text(
            'Sign in to access your clinic dashboard',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 36),

          // Username field
          AppTextField(
            label: 'Username',
            hint: 'Enter your username',
            controller: _usernameController,
            focusNode: _usernameFocus,
            isRequired: true,
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 12),
              child: Icon(
                Icons.person_outline_rounded,
                color: AppColors.textLight,
                size: 20,
              ),
            ),
            validator: (value) => Validators.required(value, 'Username'),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_passwordFocus);
            },
          ),

          const SizedBox(height: 20),

          // Password field
          AppTextField(
            label: 'Password',
            hint: 'Enter your password',
            controller: _passwordController,
            focusNode: _passwordFocus,
            obscureText: _obscurePassword,
            isRequired: true,
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 12),
              child: Icon(
                Icons.lock_outline_rounded,
                color: AppColors.textLight,
                size: 20,
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textLight,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: (value) => Validators.required(value, 'Password'),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleLogin(),
          ),

          const SizedBox(height: 32),

          // Login button
          AppButton(
            label: 'Sign In',
            onPressed: _handleLogin,
            isLoading: isLoading,
            isFullWidth: true,
            size: AppButtonSize.large,
            icon: Icons.login_rounded,
          ),

          const SizedBox(height: 24),

          // Footer hint
          Center(
            child: Text(
              'Contact your administrator if you need access',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// Branding Panel

/// Left side branding panel displayed on desktop layouts.
class _BrandingPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.sidebar,
            AppColors.sidebarHover,
            AppColors.sidebarDark,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Subtle background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _CirclePatternPainter(),
            ),
          ),

          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo icon
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(77),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_hospital_rounded,
                      size: 48,
                      color: AppColors.white,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // App name
                  Text(
                    'Clinic Management',
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.white,
                      fontSize: 32,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Tagline
                  Text(
                    'Electronic Medical Record System',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.white.withAlpha(179),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // Feature highlights
                  _FeatureItem(
                    icon: Icons.people_outline_rounded,
                    text: 'Patient Management',
                  ),
                  const SizedBox(height: 16),

                  _FeatureItem(
                    icon: Icons.medical_services_outlined,
                    text: 'Consultation & EMR',
                  ),
                  const SizedBox(height: 16),

                  _FeatureItem(
                    icon: Icons.description_outlined,
                    text: 'Digital Prescriptions',
                  ),
                  const SizedBox(height: 16),

                  _FeatureItem(
                    icon: Icons.calendar_today_outlined,
                    text: 'Appointment Scheduling',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual feature highlight item.
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(38),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),

        Text(
          text,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.white.withAlpha(230),
          ),
        ),
      ],
    );
  }
}

/// Subtle decorative circles for the branding panel background.
class _CirclePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white.withAlpha(8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      size.width * 0.4,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.8),
      size.width * 0.35,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.6),
      size.width * 0.2,
      paint..color = AppColors.white.withAlpha(5),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}