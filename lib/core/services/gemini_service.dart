import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/app_config.dart';
import '../errors/app_exception.dart';
import 'api_key_service.dart';

class GeminiService {
  final ApiKeyService _apiKeyService;

  GeminiService(this._apiKeyService);

  List<String> get _candidateModels => [
        'gemini-3.5-flash',
        'gemini-3.8-flash',
        'gemini-3.7-flash',
        'gemini-3.6-flash',
        'gemini-2.5-pro',
        'gemini-flash-latest',
        AppConfig.geminiModel,
        'gemini-2.0-flash',
        'gemini-1.5-flash',
      ];

  bool _isRecoverableModelError(String errorString) {
    final lower = errorString.toLowerCase();
    return lower.contains('not found') ||
        lower.contains('not supported') ||
        lower.contains('no longer available') ||
        lower.contains('deprecated') ||
        lower.contains('unavailable') ||
        lower.contains('high demand') ||
        lower.contains('resource_exhausted') ||
        lower.contains('503') ||
        lower.contains('404');
  }

  Future<GenerateContentResponse> _generateWithFallback(
    List<Content> content,
  ) async {
    final apiKey = await _apiKeyService.getGeminiApiKey();
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

  Future<String> describeScene(Uint8List imageBytes) async {
    try {
      const prompt =
          'You are VisionMate, an assistive vision guide for blind and visually impaired individuals. '
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
      throw AiServiceException('AI scene analysis failed: ${e.toString()}');
    }
  }

  Future<String> askVisualQuestion({
    required Uint8List imageBytes,
    required String question,
  }) async {
    try {
      final prompt =
          'You are VisionMate, assisting a visually impaired user. '
          'The user captured an image and asked this specific question: "$question". '
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

  Future<String> sendChatMessage({
    required String message,
    List<Map<String, String>> history = const [],
  }) async {
    try {
      final apiKey = await _apiKeyService.getGeminiApiKey();
      if (apiKey == null || apiKey.trim().isEmpty) {
        throw const AiServiceException(
          'Gemini API key is not configured. Please supply it via --dart-define=GEMINI_API_KEY or configure it in Settings.',
        );
      }

      const systemInstruction =
          'You are VisionMate, an empathetic, concise, and helpful AI assistant for blind and visually impaired people. '
          'Provide clear, audio-friendly descriptions and answers without markdown tables, ascii art, or visual formatting that cannot be spoken well by a text-to-speech engine.';

      final cleanHistory = <Content>[];
      String expectedRole = 'user';
      for (final item in history) {
        final role = (item['sender'] == 'user') ? 'user' : 'model';
        final text = (item['text'] ?? '').trim();
        if (text.isEmpty) continue;
        if (role == expectedRole) {
          cleanHistory.add(Content(role, [TextPart(text)]));
          expectedRole = (role == 'user') ? 'model' : 'user';
        }
      }

      if (cleanHistory.isNotEmpty && cleanHistory.last.role == 'user') {
        cleanHistory.removeLast();
      }

      Object? lastError;
      for (final modelName in _candidateModels) {
        try {
          final model = GenerativeModel(
            model: modelName,
            apiKey: apiKey,
            systemInstruction: Content.system(systemInstruction),
          );
          final chat = model.startChat(history: cleanHistory);
          final response = await chat.sendMessage(Content.text(message));
          final text = response.text;
          if (text == null || text.trim().isEmpty) {
            throw const AiServiceException('Empty response received from AI assistant.');
          }
          return text.trim();
        } catch (e) {
          lastError = e;
          if (_isRecoverableModelError(e.toString())) {
            continue;
          }
          rethrow;
        }
      }
      throw AiServiceException('Assistant conversation error: ${lastError.toString()}');
    } catch (e) {
      if (e is AiServiceException) rethrow;
      throw AiServiceException('Assistant conversation error: ${e.toString()}');
    }
  }
}

final geminiServiceProvider = Provider<GeminiService>((ref) {
  final apiKeyService = ref.watch(apiKeyServiceProvider);
  return GeminiService(apiKeyService);
});
