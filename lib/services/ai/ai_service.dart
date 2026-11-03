import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:visionmate/core/constants/app_constants.dart';
import 'package:visionmate/core/errors/app_exception.dart';
import 'package:visionmate/core/utils/secure_storage_helper.dart';

abstract class AiService {
  Future<String> describeScene(Uint8List imageBytes);
  Future<String> locateObject({
    required Uint8List imageBytes,
    required String targetObject,
  });
  Future<String> askVisualQuestion({
    required Uint8List imageBytes,
    required String question,
  });
  Future<String> generateTextResponse({
    required String prompt,
    List<Map<String, String>>? history,
  });
}

class GeminiAiService implements AiService {
  final SecureStorageHelper _secureStorageHelper;

  GeminiAiService(this._secureStorageHelper);

  List<String> get _candidateModels => [
        AppConstants.defaultGeminiModel,
        'gemini-1.5-flash',
        'gemini-flash-latest',
        'gemini-2.5-flash',
      ];

  bool _isRecoverableModelError(String errorString) {
    final lower = errorString.toLowerCase();
    return lower.contains('not found') ||
        lower.contains('not supported') ||
        lower.contains('no longer available') ||
        lower.contains('deprecated') ||
        lower.contains('unavailable') ||
        lower.contains('404');
  }

  Future<GenerateContentResponse> _generateWithFallback(
    List<Content> content,
  ) async {
    final apiKey = await _secureStorageHelper.getGeminiApiKey();
    if (apiKey == null || apiKey.trim().isEmpty) {
      throw const AiServiceException(
        'Gemini API key is not configured. Please supply it via --dart-define=GEMINI_API_KEY or configure it in Settings.',
      );
    }

    Object? lastError;
    for (final modelName in _candidateModels) {
      try {
        final model = GenerativeModel(model: modelName, apiKey: apiKey);
        return await model.generateContent(content);
      } catch (e) {
        lastError = e;
        if (_isRecoverableModelError(e.toString())) {
          continue;
        }
        rethrow;
      }
    }
    throw AiServiceException('Generation failed: ${lastError.toString()}');
  }

  @override
  Future<String> describeScene(Uint8List imageBytes) async {
    try {
      const prompt =
          'You are VisionMate, an assistive vision guide. '
          'Examine this camera image carefully. Describe what is in front of the user clearly, concisely, and practically. '
          'Focus on: 1) What the environment is, 2) Immediate obstacles, stairs, doorways, or trip hazards, '
          '3) People, vehicles, or notable objects with relative positions (left, right, center, distance in steps or meters), '
          '4) Clear text or signage if visible. Speak directly, calmly, and avoid fluff.';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _generateWithFallback(content);
      final text = response.text;
      if (text == null || text.trim().isEmpty) {
        throw const AiServiceException('No description could be generated for this scene.');
      }
      return text.trim();
    } catch (e) {
      if (e is AiServiceException) rethrow;
      throw AiServiceException('Scene analysis failed: ${e.toString()}');
    }
  }

  @override
  Future<String> locateObject({
    required Uint8List imageBytes,
    required String targetObject,
  }) async {
    try {
      final prompt =
          'You are VisionMate, an assistive AI helping a visually impaired user locate "$targetObject" during an active 360-degree pan scan. '
          'Examine this camera image carefully. '
          'Is "$targetObject" visible in this frame? '
          'If YES, reply in this format: '
          'FOUND: State its exact relative position (straight ahead, to your left, or to your right, and where it rests like on table or floor) and estimated distance in meters or steps. '
          'Provide a clear, reassuring spoken guidance (for example: "Found! Your $targetObject is straight ahead on the table, about 1 meter away."). '
          'If NO, reply strictly with: '
          'NOT_FOUND: $targetObject is not visible in this angle. Keep turning slowly.';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _generateWithFallback(content);
      final text = response.text;
      if (text == null || text.trim().isEmpty) {
        throw const AiServiceException('Unable to locate object in scene.');
      }
      return text.trim();
    } catch (e) {
      if (e is AiServiceException) rethrow;
      throw AiServiceException('Object search failed: ${e.toString()}');
    }
  }

  @override
  Future<String> askVisualQuestion({
    required Uint8List imageBytes,
    required String question,
  }) async {
    try {
      final prompt =
          'You are VisionMate, assisting a visually impaired user. '
          'The user captured an image and asked: "$question". '
          'Answer the question accurately, directly, and concisely based strictly on what is visible in the image.';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _generateWithFallback(content);
      final text = response.text;
      if (text == null || text.trim().isEmpty) {
        throw const AiServiceException('No answer could be generated.');
      }
      return text.trim();
    } catch (e) {
      if (e is AiServiceException) rethrow;
      throw AiServiceException('Visual query failed: ${e.toString()}');
    }
  }

  @override
  Future<String> generateTextResponse({
    required String prompt,
    List<Map<String, String>>? history,
  }) async {
    try {
      const systemInstruction =
          'You are VisionMate, a friendly, respectful, and concise audio guide. '
          'Keep your answers brief, conversational, and direct for audio text-to-speech output. '
          'Never use markdown formatting like bullet points or bold asterisks, as they sound awkward when spoken aloud.';

      final List<Content> contents = [];
      if (history != null) {
        for (final entry in history) {
          final role = entry['role'] == 'user' ? 'user' : 'model';
          final text = entry['text'] ?? '';
          if (role == 'user') {
            contents.add(Content.text(text));
          } else {
            contents.add(Content.model([TextPart(text)]));
          }
        }
      }

      contents.add(Content.text('$systemInstruction\nUser: $prompt'));

      final response = await _generateWithFallback(contents);
      final text = response.text;
      if (text == null || text.trim().isEmpty) {
        throw const AiServiceException('No response generated.');
      }
      return text.trim();
    } catch (e) {
      if (e is AiServiceException) rethrow;
      throw AiServiceException('Assistant request failed: ${e.toString()}');
    }
  }
}

final aiServiceProvider = Provider<AiService>((ref) {
  final storage = ref.watch(secureStorageHelperProvider);
  return GeminiAiService(storage);
});
