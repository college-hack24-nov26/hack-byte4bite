import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

abstract class TtsService {
  Future<void> speak(String text);
  Future<void> stop();
  Future<void> setSpeechRate(double rate);
  Future<void> setPitch(double pitch);
  bool get isSpeaking;
}

class FlutterTtsService implements TtsService {
  final FlutterTts _tts;
  bool _isSpeaking = false;

  FlutterTtsService([FlutterTts? tts]) : _tts = tts ?? FlutterTts() {
    _initTts();
  }

  void _initTts() {
    _tts.setStartHandler(() {
      _isSpeaking = true;
    });

    _tts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    _tts.setCancelHandler(() {
      _isSpeaking = false;
    });

    _tts.setErrorHandler((_) {
      _isSpeaking = false;
    });

    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.5);
    _tts.setVolume(1.0);
    _tts.setPitch(1.0);
  }

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await _tts.stop();
      await _tts.speak(text.trim());
    } catch (_) {}
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
      _isSpeaking = false;
    } catch (_) {}
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    try {
      await _tts.setSpeechRate(rate.clamp(0.1, 1.0));
    } catch (_) {}
  }

  @override
  Future<void> setPitch(double pitch) async {
    try {
      await _tts.setPitch(pitch.clamp(0.5, 2.0));
    } catch (_) {}
  }
}

final ttsServiceProvider = Provider<TtsService>((ref) {
  return FlutterTtsService();
});

