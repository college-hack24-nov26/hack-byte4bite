import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionmate/core/utils/secure_storage_helper.dart';
import '../../domain/entities/app_settings.dart';

abstract class SettingsRepository {
  Future<AppSettings> loadSettings();
  Future<void> saveSettings(AppSettings settings);
  Future<String?> getApiKey();
  Future<void> saveApiKey(String apiKey);
}

class SettingsRepositoryImpl implements SettingsRepository {
  final SecureStorageHelper _storage;

  SettingsRepositoryImpl(this._storage);

  @override
  Future<AppSettings> loadSettings() async {
    final rateStr = await _storage.read('setting_speech_rate');
    final pitchStr = await _storage.read('setting_speech_pitch');
    final contrastStr = await _storage.read('setting_high_contrast');
    final hapticsStr = await _storage.read('setting_haptics');

    return AppSettings(
      speechRate: rateStr != null ? double.tryParse(rateStr) ?? 0.5 : 0.5,
      speechPitch: pitchStr != null ? double.tryParse(pitchStr) ?? 1.0 : 1.0,
      highContrast: contrastStr != null ? contrastStr == 'true' : true,
      hapticsEnabled: hapticsStr != null ? hapticsStr == 'true' : true,
    );
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    await _storage.write('setting_speech_rate', settings.speechRate.toString());
    await _storage.write('setting_speech_pitch', settings.speechPitch.toString());
    await _storage.write('setting_high_contrast', settings.highContrast.toString());
    await _storage.write('setting_haptics', settings.hapticsEnabled.toString());
  }

  @override
  Future<String?> getApiKey() async {
    return await _storage.getGeminiApiKey();
  }

  @override
  Future<void> saveApiKey(String apiKey) async {
    await _storage.saveGeminiApiKey(apiKey);
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final storage = ref.watch(secureStorageHelperProvider);
  return SettingsRepositoryImpl(storage);
});

