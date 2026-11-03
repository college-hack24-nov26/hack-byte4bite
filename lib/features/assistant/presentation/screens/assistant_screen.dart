import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/accessible_button.dart';
import '../controllers/assistant_controller.dart';

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _sendTypedMessage() {
    final query = _textController.text.trim();
    if (query.isNotEmpty) {
      ref.read(assistantControllerProvider.notifier).sendMessage(query);
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(assistantControllerProvider);
    final controller = ref.read(assistantControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.stop_circle_rounded),
            tooltip: 'Stop speaking',
            onPressed: () => controller.stopSpeaking(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Clear conversation history',
            onPressed: () => controller.clearConversation(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              Expanded(
                child: state.messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.record_voice_over_rounded,
                              size: 64,
                              color: AppColors.highContrastFocus,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Speak Query or type a question to converse with Gemini 2.5.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: AppColors.textLightSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        reverse: false,
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final item = state.messages[index];
                          final isUser = item.isUser;
                          return Semantics(
                            label: '${isUser ? "You asked" : "Assistant answered"}: ${item.text}',
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? AppColors.navyLight
                                    : AppColors.cardDark,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isUser
                                      ? AppColors.highContrastFocus
                                      : AppColors.navyBorder,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isUser ? 'You' : 'VisionMate Assistant',
                                    style: TextStyle(
                                      color: isUser
                                          ? AppColors.highContrastFocus
                                          : AppColors.accessibleCyan,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.text,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: AppColors.warmWhite,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              if (state.speechTranscript.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Recognized: "${state.speechTranscript}"',
                    style: const TextStyle(
                      color: AppColors.highContrastFocus,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              if (state.errorMessage != null)
                Semantics(
                  label: 'Error: ${state.errorMessage}',
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(50),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            color: AppColors.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.errorMessage!,
                            style: const TextStyle(
                              color: AppColors.warmWhite,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Type your question...',
                        filled: true,
                        fillColor: AppColors.navyMedium,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.navyBorder),
                        ),
                      ),
                      onSubmitted: (_) => _sendTypedMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.highContrastFocus,
                      foregroundColor: AppColors.navyDark,
                      minimumSize: const Size(56, 56),
                    ),
                    icon: const Icon(Icons.send_rounded),
                    tooltip: 'Send question',
                    onPressed: state.isThinking ? null : _sendTypedMessage,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: AccessibleButton(
                      label: state.isListening
                          ? 'Listening... Tap to Send'
                          : (state.isThinking ? 'Thinking...' : 'Speak Query'),
                      icon: state.isListening
                          ? Icons.mic_off_rounded
                          : Icons.mic_rounded,
                      isLoading: state.isThinking,
                      backgroundColor: state.isListening
                          ? AppColors.error
                          : AppColors.warmWhite,
                      foregroundColor: state.isListening
                          ? AppColors.warmWhite
                          : AppColors.navyDark,
                      onPressed: state.isThinking
                          ? null
                          : () => controller.toggleListening(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: AccessibleButton(
                      label: 'Photo Query',
                      icon: Icons.camera_alt_rounded,
                      isSecondary: true,
                      onPressed: state.isThinking
                          ? null
                          : () => controller.askWithCameraSnapshot(
                                'What object or scene is this and what should I know about it?',
                              ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
