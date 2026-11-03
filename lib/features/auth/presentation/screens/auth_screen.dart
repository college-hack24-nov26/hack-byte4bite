import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/accessible_button.dart';
import '../controllers/auth_controller.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSignUpMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both email and password.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final controller = ref.read(authControllerProvider.notifier);
    final success = _isSignUpMode
        ? await controller.signUpWithEmail(email, password)
        : await controller.signInWithEmail(email, password);

    if (success && mounted) {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _submitGuest() async {
    final controller = ref.read(authControllerProvider.notifier);
    final success = await controller.signInAnonymously();
    if (success && mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('VisionMate Account'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          children: [
            Semantics(
              header: true,
              child: Text(
                _isSignUpMode ? 'Create Account' : 'Sign In',
                style: theme.textTheme.displayMedium,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to sync your assistive preferences, speech rates, and bookmarks.',
              style: theme.textTheme.bodyMedium,
            ),
            if (authState.errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.error, width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AppColors.error, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        authState.errorMessage!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Semantics(
              label: 'Email address text field',
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  filled: true,
                  fillColor: AppColors.navyMedium,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.navyBorder),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              label: 'Password text field',
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: AppColors.navyMedium,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.navyBorder),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            AccessibleButton(
              label: _isSignUpMode ? 'Register Account' : 'Sign In',
              icon: _isSignUpMode ? Icons.person_add_rounded : Icons.login_rounded,
              isLoading: authState.isLoading,
              onPressed: authState.isLoading ? null : _submit,
            ),
            const SizedBox(height: 16),
            AccessibleButton(
              label: 'Continue as Guest',
              icon: Icons.person_outline_rounded,
              isSecondary: true,
              isLoading: authState.isLoading,
              onPressed: authState.isLoading ? null : _submitGuest,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() => _isSignUpMode = !_isSignUpMode);
              },
              child: Text(
                _isSignUpMode
                    ? 'Already have an account? Sign In'
                    : 'Need an account? Create one here',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.highContrastFocus,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
