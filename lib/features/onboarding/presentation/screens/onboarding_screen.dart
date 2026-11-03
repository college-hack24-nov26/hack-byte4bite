import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visionmate/core/constants/app_constants.dart';
import 'package:visionmate/core/routing/app_routes.dart';
import 'package:visionmate/core/theme/app_colors.dart';
import 'package:visionmate/services/speech/tts_service.dart';
import 'package:visionmate/shared/widgets/accessible_button.dart';
import 'package:visionmate/features/onboarding/presentation/controllers/onboarding_controller.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final tts = ref.watch(ttsServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to VisionMate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded),
            tooltip: 'Read screen summary',
            onPressed: () {
              tts.speak(
                'Welcome to VisionMate. Tap Get Started to configure your guide.',
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 24),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(26),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.amberFocus,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.visibility_rounded,
                          size: 56,
                          color: AppColors.amberFocus,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Semantics(
                      header: true,
                      child: Text(
                        'Your Personal Vision Guide',
                        style: theme.textTheme.displaySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Understand what is around you, read signs, locate objects, and navigate safely with spoken feedback.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 36),
                    const _FeatureBullet(
                      icon: Icons.camera_alt_rounded,
                      title: 'Surroundings & Hazards',
                      description: 'Real-time scene descriptions and obstacle alerts.',
                    ),
                    const SizedBox(height: 12),
                    const _FeatureBullet(
                      icon: Icons.document_scanner_rounded,
                      title: 'Smart Text Reader',
                      description: 'Fast offline reading for signs, labels, and pages.',
                    ),
                    const SizedBox(height: 12),
                    const _FeatureBullet(
                      icon: Icons.emergency_rounded,
                      title: 'Emergency SOS',
                      description: 'Instant distress beacon and location broadcast.',
                    ),
                  ],
                ),
              ),
              AccessibleButton(
                label: 'Get Started',
                icon: Icons.arrow_forward_rounded,
                onPressed: () async {
                  await controller.requestPermissions();
                  if (context.mounted) {
                    context.go(AppRoutes.home);
                  }
                },
              ),
              const SizedBox(height: 12),
              AccessibleButton(
                label: 'Sign In / Account',
                isSecondary: true,
                onPressed: () {
                  context.push(AppRoutes.auth);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureBullet({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: AppColors.amberFocus),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.warmWhite,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
