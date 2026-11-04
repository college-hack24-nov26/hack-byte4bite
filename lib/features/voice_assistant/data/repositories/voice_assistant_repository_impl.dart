import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionmate/services/ai/ai_service.dart';
import '../../domain/entities/voice_message.dart';
import '../../domain/repositories/voice_assistant_repository.dart';

class VoiceAssistantRepositoryImpl implements VoiceAssistantRepository {
  final AiService _aiService;

  VoiceAssistantRepositoryImpl(this._aiService);

  @override
  Future<VoiceMessage> askAssistant({
    required String userPrompt,
    required List<VoiceMessage> conversationHistory,
  }) async {
    final historyMaps = conversationHistory.map((m) {
      return {
        'role': m.isUser ? 'user' : 'model',
        'text': m.text,
      };
    }).toList();

    final responseText = await _aiService.generateTextResponse(
      prompt: userPrompt,
      history: historyMaps,
    );

    return VoiceMessage(
      id: 'assistant_${DateTime.now().millisecondsSinceEpoch}',
      text: responseText,
      isUser: false,
      timestamp: DateTime.now(),
    );
  }
}

final voiceAssistantRepositoryProvider =
    Provider<VoiceAssistantRepository>((ref) {
  final ai = ref.watch(aiServiceProvider);
  return VoiceAssistantRepositoryImpl(ai);
});

