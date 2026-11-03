import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/feature_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tts = ref.watch(ttsServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('VisionMate 3.0'),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded),
            tooltip: 'Read screen summary',
            onPressed: () {
              tts.speak(
                'VisionMate main menu. Explore surroundings, Read text, AI voice assistant, Navigation guidance, or Settings.',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Open settings',
            onPressed: () {
              context.push(AppRoutes.settings);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          children: [
            Semantics(
              header: true,
              child: Text(
                'Assistance Tools',
                style: theme.textTheme.displayMedium,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select an assistive mode below or tap Read Screen Summary above.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FeatureCard(
              title: 'Explore Surroundings',
              description: 'AI camera scene understanding & object detection',
              icon: Icons.camera_alt_rounded,
              semanticAction: 'Scene Explorer',
              onTap: () {
                tts.speak('Opening Surroundings Explorer.');
                context.push(AppRoutes.vision);
              },
            ),
            FeatureCard(
              title: 'Read Text',
              description: 'High-speed offline OCR for signs, menus & papers',
              icon: Icons.document_scanner_rounded,
              semanticAction: 'Text Reader',
              onTap: () {
                tts.speak('Opening Text Reader.');
                context.push(AppRoutes.ocr);
              },
            ),
            FeatureCard(
              title: 'AI Assistant',
              description: 'Ask questions and converse with Gemini 2.5',
              icon: Icons.record_voice_over_rounded,
              semanticAction: 'AI Assistant',
              onTap: () {
                tts.speak('Opening AI Assistant.');
                context.push(AppRoutes.assistant);
              },
            ),
            FeatureCard(
              title: 'Navigation Guidance',
              description: 'GPS location, orientation & route directions',
              icon: Icons.navigation_rounded,
              semanticAction: 'Navigation Guidance',
              onTap: () {
                tts.speak('Opening Navigation Guidance.');
                context.push(AppRoutes.navigation);
              },
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: AppColors.navyMedium,
                borderRadius:
                    BorderRadius.circular(AppConstants.defaultBorderRadius),
                border: Border.all(
                  color: AppColors.highContrastFocus,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.accessibility_new_rounded,
                    size: 36,
                    color: AppColors.highContrastFocus,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TalkBack Ready',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.warmWhite,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Fully optimized with high-contrast tactile elements and screen reader semantic trees.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textLightSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

