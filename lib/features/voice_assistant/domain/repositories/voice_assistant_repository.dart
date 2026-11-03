import '../entities/voice_message.dart';

abstract class VoiceAssistantRepository {
  Future<VoiceMessage> askAssistant({
    required String userPrompt,
    required List<VoiceMessage> conversationHistory,
  });
}

