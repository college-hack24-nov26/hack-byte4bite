import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/accessibility/haptic_service.dart';
import '../../../../core/services/camera_service.dart';
import '../../../../core/services/speech_service.dart';
import '../../../../core/services/tts_service.dart';
import '../../domain/entities/chat_entry.dart';
import '../../data/repositories/assistant_repository_impl.dart';

class AssistantState {
  final List<ChatEntry> messages;
  final bool isListening;
  final bool isThinking;
  final String? errorMessage;
  final String speechTranscript;

  const AssistantState({
    this.messages = const [],
    this.isListening = false,
    this.isThinking = false,
    this.errorMessage,
    this.speechTranscript = '',
  });

  AssistantState copyWith({
    List<ChatEntry>? messages,
    bool? isListening,
    bool? isThinking,
    String? errorMessage,
    String? speechTranscript,
  }) {
    return AssistantState(
      messages: messages ?? this.messages,
      isListening: isListening ?? this.isListening,
      isThinking: isThinking ?? this.isThinking,
      errorMessage: errorMessage,
      speechTranscript: speechTranscript ?? this.speechTranscript,
    );
  }
}

class AssistantController extends Notifier<AssistantState> {
  @override
  AssistantState build() {
    return const AssistantState();
  }

  Future<void> toggleListening() async {
    final speech = ref.read(speechServiceProvider);
    final tts = ref.read(ttsServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    if (state.isListening) {
      await speech.stopListening();
      state = state.copyWith(isListening: false);
      await haptic.buttonPress();
      if (state.speechTranscript.trim().isNotEmpty) {
        await sendMessage(state.speechTranscript);
      }
      return;
    }

    await tts.stop();
    await haptic.scanTrigger();
    state = state.copyWith(
      isListening: true,
      errorMessage: null,
      speechTranscript: '',
    );
    await tts.speak('Listening.');

    await speech.startListening(
      onResult: (words) {
        state = state.copyWith(speechTranscript: words);
      },
    );
  }

  Future<void> sendMessage(String text) async {
    final query = text.trim();
    if (query.isEmpty || state.isThinking) return;

    final speech = ref.read(speechServiceProvider);
    final repository = ref.read(assistantRepositoryProvider);
    final tts = ref.read(ttsServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    if (state.isListening) {
      await speech.stopListening();
    }

    final previousHistory = List<ChatEntry>.from(state.messages);

    final userMessage = ChatEntry(
      sender: 'user',
      text: query,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isListening: false,
      isThinking: true,
      speechTranscript: '',
      errorMessage: null,
    );

    await haptic.continuousTick();

    try {
      final answer = await repository.askQuestion(
        question: query,
        history: previousHistory,
      );

      final assistantMessage = ChatEntry(
        sender: 'assistant',
        text: answer,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, assistantMessage],
        isThinking: false,
      );

      await haptic.success();
      await tts.speak(answer);
    } catch (e) {
      final errorMsg = e.toString();
      state = state.copyWith(
        isThinking: false,
        errorMessage: errorMsg,
      );
      await haptic.error();
      await tts.speak('Assistant query error. $errorMsg');
    }
  }

  Future<void> askWithCameraSnapshot(String question) async {
    final camera = ref.read(cameraServiceProvider);
    final repository = ref.read(assistantRepositoryProvider);
    final tts = ref.read(ttsServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    state = state.copyWith(isThinking: true, errorMessage: null);
    await haptic.scanTrigger();
    await tts.speak('Taking snapshot to analyze question.');

    try {
      final imageBytes = await camera.captureImageBytes();
      final userMessage = ChatEntry(
        sender: 'user',
        text: 'Photo query: $question',
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, userMessage],
      );

      final answer = await repository.askVisualQuestion(
        imageBytes: imageBytes,
        question: question,
      );

      final assistantMessage = ChatEntry(
        sender: 'assistant',
        text: answer,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, assistantMessage],
        isThinking: false,
      );

      await haptic.success();
      await tts.speak(answer);
    } catch (e) {
      final errorMsg = e.toString();
      state = state.copyWith(
        isThinking: false,
        errorMessage: errorMsg,
      );
      await haptic.error();
      await tts.speak('Visual question failed. $errorMsg');
    }
  }

  Future<void> stopSpeaking() async {
    final tts = ref.read(ttsServiceProvider);
    final haptic = ref.read(hapticServiceProvider);
    await haptic.buttonPress();
    await tts.stop();
  }

  void clearConversation() {
    final tts = ref.read(ttsServiceProvider);
    final haptic = ref.read(hapticServiceProvider);
    haptic.buttonPress();
    state = const AssistantState();
    tts.speak('Conversation cleared.');
  }
}

final assistantControllerProvider =
    NotifierProvider<AssistantController, AssistantState>(
  AssistantController.new,
);
