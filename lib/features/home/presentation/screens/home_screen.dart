import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visionmate/core/routing/app_routes.dart';
import 'package:visionmate/core/theme/app_colors.dart';
import 'package:visionmate/services/speech/tts_service.dart';
import '../controllers/home_accessibility_controller.dart';
import '../widgets/assistance_tool_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _readInstructions(WidgetRef ref) {
    final tts = ref.read(ttsServiceProvider);
    tts.speak(
      'Vision Mate. AI Sight and Acoustic Guide. '
      'Assistance Tools. '
      'Key 1: Explore surroundings, real-time obstacle alerts. '
      'Key 2: Smart text reader, instant OCR for signs and labels. '
      'Key 3: Find object and items, auditory locator. '
      'Key 4: Voice AI assistant, ask natural questions. '
      'Key 5: Navigation guidance, spoken compass and steps. '
      'Key 6 or E: Emergency SOS, broadcast live coordinates and siren. '
      'Keyboard shortcuts: V for Voice, E for SOS, 1 through 6 for tools.',
    );
  }

  void _handleKey(KeyEvent event, BuildContext context, WidgetRef ref) {
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;
    final tts = ref.read(ttsServiceProvider);

    if (key == LogicalKeyboardKey.digit1 || key == LogicalKeyboardKey.numpad1) {
      tts.speak('Opening Explore Surroundings.');
      context.push(AppRoutes.sceneUnderstanding);
    } else if (key == LogicalKeyboardKey.digit2 || key == LogicalKeyboardKey.numpad2) {
      tts.speak('Opening Smart Text Reader.');
      context.push(AppRoutes.smartReader);
    } else if (key == LogicalKeyboardKey.digit3 || key == LogicalKeyboardKey.numpad3) {
      tts.speak('Opening Find Object.');
      context.push(AppRoutes.objectFinder);
    } else if (key == LogicalKeyboardKey.digit4 || key == LogicalKeyboardKey.numpad4 || key == LogicalKeyboardKey.keyV) {
      tts.speak('Opening Voice AI Assistant.');
      context.push(AppRoutes.voiceAssistant);
    } else if (key == LogicalKeyboardKey.digit5 || key == LogicalKeyboardKey.numpad5) {
      tts.speak('Opening Navigation Guidance.');
      context.push(AppRoutes.navigation);
    } else if (key == LogicalKeyboardKey.digit6 || key == LogicalKeyboardKey.numpad6 || key == LogicalKeyboardKey.keyE) {
      tts.speak('Opening Emergency Assistance.');
      context.push(AppRoutes.emergency);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tts = ref.watch(ttsServiceProvider);
    final a11yState = ref.watch(accessibilityControlsProvider);
    final a11yController = ref.read(accessibilityControlsProvider.notifier);

    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      autofocus: true,
      onKeyEvent: (event) => _handleKey(event, context, ref),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(a11yState.textScale),
        ),
        child: Scaffold(
          backgroundColor: AppColors.obsidian,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context, ref, a11yState, a11yController, tts),
                  const SizedBox(height: 24),
                  _buildTitleSection(),
                  const SizedBox(height: 20),
                  _buildToolGrid(context, tts),
                  const SizedBox(height: 20),
                  _buildBottomBanner(context, ref),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    AccessibilityControlsState a11yState,
    AccessibilityControlsController a11yController,
    TtsService tts,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.amberFocus,
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.visibility_outlined,
                size: 22,
                color: AppColors.amberFocus,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Vision Mate',
                  style: TextStyle(
                    color: AppColors.warmWhite,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'AI Sight & Acoustic Guide',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _HeaderIconButton(
                label: 'A-',
                onTap: () {
                  HapticFeedback.selectionClick();
                  a11yController.decreaseTextSize();
                },
              ),
              _HeaderIconButton(
                label: 'A+',
                onTap: () {
                  HapticFeedback.selectionClick();
                  a11yController.increaseTextSize();
                },
              ),
              _HeaderIconButton(
                icon: Icons.light_mode_outlined,
                onTap: () {
                  HapticFeedback.selectionClick();
                  a11yController.toggleHighContrast();
                },
              ),
              _HeaderIconButton(
                icon: a11yState.isSoundEnabled
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                hasBadgeDot: a11yState.isSoundEnabled,
                onTap: () {
                  HapticFeedback.selectionClick();
                  a11yController.toggleSound();
                  if (a11yState.isSoundEnabled) {
                    tts.speak('Sound guidance active.');
                  } else {
                    tts.stop();
                  }
                },
              ),
              _HeaderIconButton(
                icon: Icons.info_outline_rounded,
                onTap: () {
                  HapticFeedback.selectionClick();
                  _readInstructions(ref);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Assistance Tools',
          style: TextStyle(
            color: AppColors.warmWhite,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Choose a tool below, tap with sound guidance, or use keys ',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
            _InlineKeyTag(label: '1'),
            const Text(
              ' through ',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
            _InlineKeyTag(label: '6'),
            const Text(
              ' .',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToolGrid(BuildContext context, TtsService tts) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 560;

        final cards = [
          AssistanceToolCard(
            title: 'Explore Surround...',
            description: 'Real-time obstacle alerts, pathways & walking hazards.',
            keyLabel: 'KEY 1',
            icon: Icons.camera_alt_outlined,
            accentColor: AppColors.amberFocus,
            onTap: () {
              tts.speak('Opening Explore Surroundings.');
              context.push(AppRoutes.sceneUnderstanding);
            },
          ),
          AssistanceToolCard(
            title: 'Smart Text Reader',
            description: 'Instant OCR for signs, medication, labels & bills.',
            keyLabel: 'KEY 2',
            icon: Icons.menu_book_rounded,
            accentColor: AppColors.cyanAccent,
            onTap: () {
              tts.speak('Opening Smart Text Reader.');
              context.push(AppRoutes.smartReader);
            },
          ),
          AssistanceToolCard(
            title: 'Find Object & Ca...',
            description: 'Auditory locator for keys, banknotes, doors & cups.',
            keyLabel: 'KEY 3',
            icon: Icons.search_rounded,
            accentColor: AppColors.indigoAccent,
            onTap: () {
              tts.speak('Opening Find Object.');
              context.push(AppRoutes.objectFinder);
            },
          ),
          AssistanceToolCard(
            title: 'Voice AI Assistant',
            description: 'Ask natural questions about what is in front of you.',
            keyLabel: 'KEY 4',
            icon: Icons.mic_none_rounded,
            accentColor: AppColors.emeraldAccent,
            onTap: () {
              tts.speak('Opening Voice AI Assistant.');
              context.push(AppRoutes.voiceAssistant);
            },
          ),
          AssistanceToolCard(
            title: 'Navigation Guida...',
            description: 'Spoken compass, street name & door-to-door steps.',
            keyLabel: 'KEY 5',
            icon: Icons.navigation_outlined,
            accentColor: AppColors.blueAccent,
            onTap: () {
              tts.speak('Opening Navigation Guidance.');
              context.push(AppRoutes.navigation);
            },
          ),
          AssistanceToolCard(
            title: 'Emergency S...',
            description: 'Tap to broadcast live coordinates & siren to emergency contacts.',
            keyLabel: 'KEY 6 / E',
            icon: Icons.warning_amber_rounded,
            accentColor: AppColors.crimsonAccent,
            isDanger: true,
            onTap: () {
              tts.speak('Opening Emergency Assistance.');
              context.push(AppRoutes.emergency);
            },
          ),
        ];

        if (isWide) {
          return GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 2.35,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: cards,
          );
        }

        return Column(
          children: cards
              .map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: c,
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildBottomBanner(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.amberFocus.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: AppColors.amberFocus,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Blind & Low Vision Optimization',
                  style: TextStyle(
                    color: AppColors.warmWhite,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Full screen-reader compatible. Keyboard shortcuts: V (Voice), E (SOS), 1-6 (Tools), Escape (Back).',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                _readInstructions(ref);
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.amberFocus.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.volume_up_rounded,
                      size: 14,
                      color: AppColors.amberFocus,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Read Instructions',
                      style: TextStyle(
                        color: AppColors.warmWhite,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final bool hasBadgeDot;
  final VoidCallback onTap;

  const _HeaderIconButton({
    this.label,
    this.icon,
    this.hasBadgeDot = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (label != null)
                Text(
                  label!,
                  style: const TextStyle(
                    color: AppColors.warmWhite,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                )
              else if (icon != null)
                Icon(
                  icon!,
                  size: 16,
                  color: AppColors.warmWhite,
                ),
              if (hasBadgeDot)
                Positioned(
                  top: -3,
                  right: -3,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.amberFocus,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineKeyTag extends StatelessWidget {
  final String label;

  const _InlineKeyTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.amberFocus,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}
