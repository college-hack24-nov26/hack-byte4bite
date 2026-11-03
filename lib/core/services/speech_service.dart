import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;

  bool get isListening => _speechToText.isListening;
  bool get isAvailable => _isInitialized;

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    _isInitialized = await _speechToText.initialize(
      onError: (errorNotification) {},
      onStatus: (status) {},
    );
    return _isInitialized;
  }

  Future<void> startListening({
    required Function(String recognizedWords) onResult,
  }) async {
    if (!_isInitialized) {
      final ready = await initialize();
      if (!ready) return;
    }

    await _speechToText.listen(
      onResult: (result) {
        if (result.recognizedWords.isNotEmpty) {
          onResult(result.recognizedWords);
        }
      },
    );
  }

  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
  }

  Future<void> cancelListening() async {
    if (_speechToText.isListening) {
      await _speechToText.cancel();
    }
  }
}

final speechServiceProvider = Provider<SpeechService>((ref) {
  final service = SpeechService();
  ref.onDispose(() {
    service.cancelListening();
  });
  return service;
});

