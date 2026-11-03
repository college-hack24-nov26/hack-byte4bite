import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

abstract class SecureStorageHelper {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<String?> getGeminiApiKey();
  Future<void> saveGeminiApiKey(String apiKey);
}

class SecureStorageHelperImpl implements SecureStorageHelper {
  final FlutterSecureStorage _storage;

  const SecureStorageHelperImpl([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  @override
  Future<String?> getGeminiApiKey() async {
    const dartDefineKey = String.fromEnvironment('GEMINI_API_KEY');
    if (dartDefineKey.isNotEmpty) {
      return dartDefineKey;
    }
    return await read(AppConstants.secureStorageApiKeyKey);
  }

  @override
  Future<void> saveGeminiApiKey(String apiKey) async {
    await write(AppConstants.secureStorageApiKeyKey, apiKey.trim());
  }
}

final secureStorageHelperProvider = Provider<SecureStorageHelper>((ref) {
  return const SecureStorageHelperImpl();
});

