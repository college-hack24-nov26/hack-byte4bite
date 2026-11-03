import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionmate/core/constants/app_constants.dart';
import 'package:visionmate/core/theme/app_colors.dart';
import 'package:visionmate/shared/widgets/accessible_button.dart';
import 'package:visionmate/shared/widgets/accessible_header.dart';
import 'package:visionmate/features/settings/presentation/controllers/settings_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(settingsControllerProvider.notifier).loadSettings();
      final key = ref.read(settingsControllerProvider).currentApiKey;
      if (key != null) {
        _apiKeyController.text = key;
      }
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: const AccessibleHeader(
        title: 'Settings',
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          children: [
            Text(
              'Speech & Audio Feedback',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Speech Speed',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warmWhite,
                        ),
                      ),
                      Text(
                        '${(state.settings.speechRate * 2).toStringAsFixed(1)}x',
                        style: const TextStyle(
                          color: AppColors.amberFocus,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: state.settings.speechRate,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    activeColor: AppColors.amberFocus,
                    inactiveColor: AppColors.surfaceBorder,
                    onChanged: (val) => controller.setSpeechRate(val),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Speech Pitch',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warmWhite,
                        ),
                      ),
                      Text(
                        '${state.settings.speechPitch.toStringAsFixed(1)}x',
                        style: const TextStyle(
                          color: AppColors.amberFocus,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: state.settings.speechPitch,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    activeColor: AppColors.amberFocus,
                    inactiveColor: AppColors.surfaceBorder,
                    onChanged: (val) => controller.setSpeechPitch(val),
                  ),
                  const SizedBox(height: 14),
                  AccessibleButton(
                    label: 'Test Voice Output',
                    icon: Icons.volume_up_rounded,
                    isSecondary: true,
                    onPressed: () => controller.testSpeech(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Intelligence Engine',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    label: 'API Key input field',
                    child: TextField(
                      controller: _apiKeyController,
                      obscureText: true,
                      style: const TextStyle(color: AppColors.warmWhite),
                      decoration: const InputDecoration(
                        labelText: 'Gemini API Key',
                        hintText: 'Enter your API key',
                        prefixIcon: Icon(Icons.key_outlined, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  AccessibleButton(
                    label: 'Save Configuration',
                    icon: Icons.check_circle_outline_rounded,
                    isLoading: state.isSaving,
                    onPressed: () => controller.saveApiKey(_apiKeyController.text),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Haptic Response',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                title: const Text(
                  'Tactile Vibrations',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warmWhite,
                  ),
                ),
                subtitle: const Text(
                  'Physical pulse confirmations on button taps and alerts',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
                value: state.settings.hapticsEnabled,
                activeThumbColor: AppColors.obsidian,
                activeTrackColor: AppColors.amberFocus,
                onChanged: (val) => controller.toggleHaptics(val),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'VisionMate v${AppConstants.appVersion}',
                style: const TextStyle(
                  color: AppColors.textDisabled,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
