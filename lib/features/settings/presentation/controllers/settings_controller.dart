import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionmate/services/haptics/haptic_service.dart';
import 'package:visionmate/services/speech/tts_service.dart';
import '../../domain/entities/app_settings.dart';
import '../../data/repositories/settings_repository.dart';

class SettingsState {
  final AppSettings settings;
  final String? currentApiKey;
  final bool isSaving;

  const SettingsState({
    this.settings = const AppSettings(),
    this.currentApiKey,
    this.isSaving = false,
  });

  SettingsState copyWith({
    AppSettings? settings,
    String? currentApiKey,
    bool? isSaving,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      currentApiKey: currentApiKey ?? this.currentApiKey,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class SettingsController extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    Future.microtask(() => loadSettings());
    return const SettingsState();
  }

  Future<void> loadSettings() async {
    final repo = ref.read(settingsRepositoryProvider);
    final settings = await repo.loadSettings();
    final key = await repo.getApiKey();
    state = state.copyWith(settings: settings, currentApiKey: key);
  }

  Future<void> setSpeechRate(double rate) async {
    final updated = state.settings.copyWith(speechRate: rate);
    state = state.copyWith(settings: updated);
    final tts = ref.read(ttsServiceProvider);
    await tts.setSpeechRate(rate);
    final repo = ref.read(settingsRepositoryProvider);
    await repo.saveSettings(updated);
  }

  Future<void> setSpeechPitch(double pitch) async {
    final updated = state.settings.copyWith(speechPitch: pitch);
    state = state.copyWith(settings: updated);
    final tts = ref.read(ttsServiceProvider);
    await tts.setPitch(pitch);
    final repo = ref.read(settingsRepositoryProvider);
    await repo.saveSettings(updated);
  }

  Future<void> toggleHaptics(bool value) async {
    final updated = state.settings.copyWith(hapticsEnabled: value);
    state = state.copyWith(settings: updated);
    final repo = ref.read(settingsRepositoryProvider);
    await repo.saveSettings(updated);
  }

  Future<void> saveApiKey(String key) async {
    state = state.copyWith(isSaving: true);
    final repo = ref.read(settingsRepositoryProvider);
    final tts = ref.read(ttsServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    await repo.saveApiKey(key);
    state = state.copyWith(isSaving: false, currentApiKey: key);

    await haptic.success();
    await tts.speak('API key saved successfully.');
  }

  Future<void> testSpeech() async {
    final tts = ref.read(ttsServiceProvider);
    await tts.speak(
      'This is a speech speed and pitch test for VisionMate 3.0.',
    );
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(() {
  return SettingsController();
});

