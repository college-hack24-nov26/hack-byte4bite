import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionmate/core/constants/app_constants.dart';
import 'package:visionmate/core/theme/app_colors.dart';
import 'package:visionmate/shared/widgets/accessible_button.dart';
import 'package:visionmate/shared/widgets/accessible_header.dart';
import 'package:visionmate/features/voice_assistant/presentation/controllers/voice_assistant_controller.dart';

class VoiceAssistantScreen extends ConsumerStatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  ConsumerState<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends ConsumerState<VoiceAssistantScreen> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _sendTyped() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      ref.read(voiceAssistantControllerProvider.notifier).sendMessage(text);
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(voiceAssistantControllerProvider);
    final controller = ref.read(voiceAssistantControllerProvider.notifier);

    return Scaffold(
      appBar: AccessibleHeader(
        title: 'Voice Assistant',
        onStop: () => controller.stopSpeaking(),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear conversation',
            onPressed: () => controller.clearHistory(),
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
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.amberFocus.withValues(alpha: 0.35),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.graphic_eq_rounded,
                                size: 44,
                                color: AppColors.amberFocus,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'How can I help you?',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: AppColors.warmWhite,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the microphone or type below for assistance.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final msg = state.messages[index];
                          final isUser = msg.isUser;
                          return Semantics(
                            label: '${isUser ? "You" : "Guide"}: ${msg.text}',
                            child: Align(
                              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.82,
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: isUser ? AppColors.surfaceElevated : AppColors.surfaceDark,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isUser
                                        ? AppColors.amberFocus.withValues(alpha: 0.5)
                                        : AppColors.surfaceBorder,
                                    width: 1.2,
                                  ),
                                ),
                                child: Text(
                                  msg.text,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: AppColors.warmWhite,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              if (state.isThinking)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: AppColors.amberFocus,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Thinking...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.amberFocus,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              AccessibleButton(
                label: state.isListening
                    ? 'Listening... Tap to send'
                    : 'Tap to Speak',
                icon: state.isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                backgroundColor: state.isListening ? AppColors.crimson : AppColors.amberFocus,
                foregroundColor: AppColors.obsidian,
                onPressed: () {
                  if (state.isListening) {
                    controller.stopListening();
                  } else {
                    controller.startListening();
                  }
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(color: AppColors.warmWhite),
                      decoration: const InputDecoration(
                        hintText: 'Or type your question...',
                        prefixIcon: Icon(Icons.keyboard_outlined, size: 20),
                      ),
                      onSubmitted: (_) => _sendTyped(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceElevated,
                      foregroundColor: AppColors.amberFocus,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: AppColors.surfaceBorder),
                      ),
                      minimumSize: const Size(54, 54),
                    ),
                    icon: const Icon(Icons.arrow_upward_rounded),
                    tooltip: 'Send question',
                    onPressed: _sendTyped,
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
