import 'dart:typed_data';
import '../../../../core/services/gemini_service.dart';

class AssistantRemoteDataSource {
  final GeminiService _geminiService;

  AssistantRemoteDataSource(this._geminiService);

  Future<String> askQuestion({
    required String question,
    List<Map<String, String>> history = const [],
  }) async {
    return await _geminiService.sendChatMessage(
      message: question,
      history: history,
    );
  }

  Future<String> askVisualQuestion({
    required Uint8List imageBytes,
    required String question,
  }) async {
    return await _geminiService.askVisualQuestion(
      imageBytes: imageBytes,
      question: question,
    );
  }
}

