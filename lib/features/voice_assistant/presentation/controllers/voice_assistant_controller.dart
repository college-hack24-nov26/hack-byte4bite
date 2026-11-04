import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionmate/core/errors/error_handler.dart';
import 'package:visionmate/services/haptics/haptic_service.dart';
import 'package:visionmate/services/speech/stt_service.dart';
import 'package:visionmate/services/speech/tts_service.dart';
import 'package:visionmate/features/voice_assistant/domain/entities/voice_message.dart';
import 'package:visionmate/features/voice_assistant/data/repositories/voice_assistant_repository_impl.dart';

class VoiceAssistantState {
  final List<VoiceMessage> messages;
  final bool isListening;
  final bool isThinking;
  final String? errorMessage;
  final String recognizedDraft;

  const VoiceAssistantState({
    this.messages = const [],
    this.isListening = false,
    this.isThinking = false,
    this.errorMessage,
    this.recognizedDraft = '',
  });

  VoiceAssistantState copyWith({
    List<VoiceMessage>? messages,
    bool? isListening,
    bool? isThinking,
    String? errorMessage,
    String? recognizedDraft,
  }) {
    return VoiceAssistantState(
      messages: messages ?? this.messages,
      isListening: isListening ?? this.isListening,
      isThinking: isThinking ?? this.isThinking,
      errorMessage: errorMessage,
      recognizedDraft: recognizedDraft ?? this.recognizedDraft,
    );
  }
}

class VoiceAssistantController extends Notifier<VoiceAssistantState> {
  @override
  VoiceAssistantState build() {
    return const VoiceAssistantState();
  }

  Future<void> startListening() async {
    final stt = ref.read(sttServiceProvider);
    final tts = ref.read(ttsServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    await tts.stop();
    await haptic.scanTick();

    state = state.copyWith(
      isListening: true,
      errorMessage: null,
      recognizedDraft: '',
    );

    await stt.startListening(
      onResult: (text) {
        state = state.copyWith(
          recognizedDraft: text,
        );
      },
      onDone: () {
        if (state.recognizedDraft.trim().isNotEmpty) {
          sendMessage(state.recognizedDraft.trim());
        } else {
          state = state.copyWith(
            isListening: false,
          );
        }
      },
    );
  }

  Future<void> stopListening() async {
    final stt = ref.read(sttServiceProvider);
    await stt.stopListening();
    state = state.copyWith(
      isListening: false,
    );
    if (state.recognizedDraft.trim().isNotEmpty) {
      sendMessage(state.recognizedDraft.trim());
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || state.isThinking) return;

    final repo = ref.read(voiceAssistantRepositoryProvider);
    final tts = ref.read(ttsServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    final userMessage = VoiceMessage(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    final updated = List<VoiceMessage>.from(state.messages)..add(userMessage);

    state = state.copyWith(
      messages: updated,
      isThinking: true,
      isListening: false,
      recognizedDraft: '',
      errorMessage: null,
    );

    await haptic.scanTick();

    try {
      final answer = await repo.askAssistant(
        userPrompt: text.trim(),
        conversationHistory: updated,
      );

      final withAnswer = List<VoiceMessage>.from(updated)..add(answer);
      state = state.copyWith(
        messages: withAnswer,
        isThinking: false,
      );

      await haptic.success();
      await tts.speak(answer.text);
    } catch (e) {
      final message = ErrorHandler.getUserMessage(e);
      state = state.copyWith(
        isThinking: false,
        errorMessage: message,
        messages: updated,
      );
      await haptic.error();
      await tts.speak(message);
    }
  }

  void clearHistory() {
    ref.read(ttsServiceProvider).stop();
    state = const VoiceAssistantState();
    ref.read(ttsServiceProvider).speak('Conversation cleared.');
  }

  void stopSpeaking() {
    ref.read(ttsServiceProvider).stop();
  }
}

final voiceAssistantControllerProvider =
    NotifierProvider<VoiceAssistantController, VoiceAssistantState>(() {
  return VoiceAssistantController();
});
