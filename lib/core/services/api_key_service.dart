import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import 'secure_storage_service.dart';

class ApiKeyService {
  final SecureStorageService _secureStorage;

  ApiKeyService(this._secureStorage);

  Future<String?> getGeminiApiKey() async {
    if (AppConfig.geminiApiKey.isNotEmpty) {
      return AppConfig.geminiApiKey;
    }
    return await _secureStorage.read(key: 'GEMINI_API_KEY');
  }

  Future<void> saveGeminiApiKey(String key) async {
    await _secureStorage.write(key: 'GEMINI_API_KEY', value: key.trim());
  }

  Future<void> clearGeminiApiKey() async {
    await _secureStorage.delete(key: 'GEMINI_API_KEY');
  }

  Future<bool> hasValidKey() async {
    final key = await getGeminiApiKey();
    return key != null && key.trim().isNotEmpty;
  }
}

final apiKeyServiceProvider = Provider<ApiKeyService>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return ApiKeyService(secureStorage);
});

