import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visionmate/core/constants/app_constants.dart';
import 'package:visionmate/core/routing/app_routes.dart';
import 'package:visionmate/core/theme/app_colors.dart';
import 'package:visionmate/shared/widgets/accessible_button.dart';
import 'package:visionmate/features/authentication/presentation/controllers/auth_controller.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref.read(authControllerProvider.notifier).authenticate(
            email: _emailController.text,
            password: _passwordController.text,
          );
      if (success && mounted) {
        context.go(AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(authState.isSignUp ? 'Create Account' : 'Sign In'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Semantics(
                  header: true,
                  child: Text(
                    authState.isSignUp ? 'Join VisionMate' : 'Welcome Back',
                    style: theme.textTheme.displaySmall,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  authState.isSignUp
                      ? 'Create an account to sync preferences and emergency contacts.'
                      : 'Sign in to access your saved places and configurations.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 28),
                Semantics(
                  label: 'Email address text field',
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    style: const TextStyle(color: AppColors.warmWhite),
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email_outlined, size: 20),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!val.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 18),
                Semantics(
                  label: 'Password text field',
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: AppColors.warmWhite),
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline_rounded, size: 20),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ),
                if (authState.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.crimson.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.crimson),
                    ),
                    child: Text(
                      authState.errorMessage!,
                      style: const TextStyle(
                        color: AppColors.warmWhite,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                AccessibleButton(
                  label: authState.isSignUp ? 'Create Account' : 'Sign In',
                  icon: authState.isSignUp ? Icons.person_add_rounded : Icons.login_rounded,
                  isLoading: authState.isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 14),
                AccessibleButton(
                  label: authState.isSignUp
                      ? 'Already have an account? Sign In'
                      : "Don't have an account? Create one",
                  isSecondary: true,
                  onPressed: () => controller.toggleMode(),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () => context.go(AppRoutes.home),
                  child: const Text(
                    'Continue as Guest',
                    style: TextStyle(
                      color: AppColors.amberFocus,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
