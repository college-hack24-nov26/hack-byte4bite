import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

abstract class SttService {
  Future<bool> initialize();
  Future<void> startListening({
    required void Function(String text) onResult,
    void Function()? onDone,
  });
  Future<void> stopListening();
  bool get isListening;
  bool get isAvailable;
}

class DeviceSttService implements SttService {
  final SpeechToText _speechToText;
  bool _isAvailable = false;

  DeviceSttService([SpeechToText? stt]) : _speechToText = stt ?? SpeechToText();

  @override
  bool get isListening => _speechToText.isListening;

  @override
  bool get isAvailable => _isAvailable;

  @override
  Future<bool> initialize() async {
    if (_isAvailable) return true;
    try {
      _isAvailable = await _speechToText.initialize();
      return _isAvailable;
    } catch (_) {
      _isAvailable = false;
      return false;
    }
  }

  @override
  Future<void> startListening({
    required void Function(String text) onResult,
    void Function()? onDone,
  }) async {
    if (!_isAvailable) {
      final ok = await initialize();
      if (!ok) return;
    }

    try {
      await _speechToText.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
          if (result.finalResult && onDone != null) {
            onDone();
          }
        },
        listenOptions: SpeechListenOptions(
          cancelOnError: true,
          partialResults: true,
        ),
      );
    } catch (_) {}
  }

  @override
  Future<void> stopListening() async {
    try {
      await _speechToText.stop();
    } catch (_) {}
  }
}

final sttServiceProvider = Provider<SttService>((ref) {
  return DeviceSttService();
});

