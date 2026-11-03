import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visionmate/core/constants/app_constants.dart';
import 'package:visionmate/core/router/app_routes.dart';
import 'package:visionmate/core/services/api_key_service.dart';
import 'package:visionmate/core/services/tts_service.dart';
import 'package:visionmate/core/theme/app_colors.dart';
import 'package:visionmate/core/widgets/accessible_button.dart';
import 'package:visionmate/features/auth/presentation/controllers/auth_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  double _speechRate = 0.5;
  bool _hapticsEnabled = true;
  bool _hasCustomKey = false;

  @override
  void initState() {
    super.initState();
    _checkKeyStatus();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _checkKeyStatus() async {
    final apiKeyService = ref.read(apiKeyServiceProvider);
    final key = await apiKeyService.getGeminiApiKey();
    if (mounted) {
      setState(() {
        _hasCustomKey = key != null && key.isNotEmpty;
      });
    }
  }

  Future<void> _saveKey() async {
    final newKey = _apiKeyController.text.trim();
    if (newKey.isNotEmpty) {
      final apiKeyService = ref.read(apiKeyServiceProvider);
      await apiKeyService.saveGeminiApiKey(newKey);
      _apiKeyController.clear();
      await _checkKeyStatus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gemini API key saved securely to device Keystore.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tts = ref.watch(ttsServiceProvider);
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          children: [
            Semantics(
              header: true,
              child: Text(
                'AI Configuration',
                style: theme.textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: AppColors.navyMedium,
                borderRadius:
                    BorderRadius.circular(AppConstants.defaultBorderRadius),
                border: Border.all(
                  color: AppColors.navyBorder,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _hasCustomKey
                            ? Icons.check_circle_rounded
                            : Icons.key_rounded,
                        color: _hasCustomKey
                            ? AppColors.accessibleCyan
                            : AppColors.highContrastFocus,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _hasCustomKey
                            ? 'Gemini 2.5 API Key Configured'
                            : 'Enter Gemini API Key',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.warmWhite,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Stored securely in Android EncryptedSharedPreferences.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textLightSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _apiKeyController,
                    obscureText: true,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Paste Gemini API Key...',
                      filled: true,
                      fillColor: AppColors.cardDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.navyBorder),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AccessibleButton(
                    label: 'Save Key Securely',
                    icon: Icons.save_rounded,
                    isSecondary: true,
                    onPressed: _saveKey,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Semantics(
              header: true,
              child: Text(
                'Voice & Audio',
                style: theme.textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: AppColors.navyMedium,
                borderRadius:
                    BorderRadius.circular(AppConstants.defaultBorderRadius),
                border: Border.all(
                  color: AppColors.navyBorder,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Speech Rate: ${(_speechRate * 2).toStringAsFixed(1)}x',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.warmWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: _speechRate,
                    min: 0.2,
                    max: 1.0,
                    divisions: 8,
                    activeColor: AppColors.highContrastFocus,
                    inactiveColor: AppColors.navyLight,
                    onChanged: (value) {
                      setState(() => _speechRate = value);
                      tts.setRate(value);
                    },
                  ),
                  const SizedBox(height: 8),
                  AccessibleButton(
                    label: 'Test Voice Rate',
                    icon: Icons.record_voice_over_rounded,
                    isSecondary: true,
                    onPressed: () {
                      tts.speak('This is VisionMate speaking at this speech speed.');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Semantics(
              header: true,
              child: Text(
                'Tactile Feedback',
                style: theme.textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: AppColors.navyMedium,
                borderRadius:
                    BorderRadius.circular(AppConstants.defaultBorderRadius),
                border: Border.all(
                  color: AppColors.navyBorder,
                  width: 2,
                ),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Haptic Vibrations',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.warmWhite,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  'Provide tactile feedback when tapping and receiving detections.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textLightSecondary,
                  ),
                ),
                value: _hapticsEnabled,
                activeThumbColor: AppColors.highContrastFocus,
                onChanged: (val) {
                  setState(() => _hapticsEnabled = val);
                  tts.speak(
                    val ? 'Haptic feedback enabled.' : 'Haptic feedback disabled.',
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Semantics(
              header: true,
              child: Text(
                'Account & Cloud Sync',
                style: theme.textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: AppColors.navyMedium,
                borderRadius:
                    BorderRadius.circular(AppConstants.defaultBorderRadius),
                border: Border.all(
                  color: AppColors.navyBorder,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authState.user != null
                        ? (authState.user!.isAnonymous
                            ? 'Signed in as Guest'
                            : 'Signed in: ${authState.user!.email}')
                        : 'Not signed in',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.warmWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (authState.user != null)
                    AccessibleButton(
                      label: 'Sign Out',
                      icon: Icons.logout_rounded,
                      isSecondary: true,
                      onPressed: () => authController.signOut(),
                    )
                  else
                    AccessibleButton(
                      label: 'Sign In / Register',
                      icon: Icons.login_rounded,
                      onPressed: () => context.push(AppRoutes.auth),
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
