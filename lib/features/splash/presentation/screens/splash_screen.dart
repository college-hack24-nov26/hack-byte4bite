import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visionmate/core/constants/app_constants.dart';
import 'package:visionmate/core/router/app_routes.dart';
import 'package:visionmate/core/services/tts_service.dart';
import 'package:visionmate/core/theme/app_colors.dart';
import 'package:visionmate/features/auth/data/repositories/auth_repository_impl.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startInitialization();
  }

  Future<void> _startInitialization() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final tts = ref.read(ttsServiceProvider);
    await tts.speak('VisionMate 3.0 loaded. Welcome.');

    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.getCurrentUser();
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Semantics(
        label: 'VisionMate 3.0 assistive application starting up.',
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.navyMedium,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.highContrastFocus,
                      width: 4,
                    ),
                  ),
                  child: const Icon(
                    Icons.visibility_rounded,
                    size: 64,
                    color: AppColors.warmWhite,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Version ${AppConstants.appVersion}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.highContrastFocus,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  AppConstants.tagLine,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.highContrastFocus,
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
