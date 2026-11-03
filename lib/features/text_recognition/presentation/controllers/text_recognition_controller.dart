import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/accessibility/haptic_service.dart';
import '../../../../core/services/camera_service.dart';
import '../../../../core/services/tts_service.dart';
import '../../domain/entities/text_recognition_result.dart';
import '../../data/repositories/text_recognition_repository_impl.dart';

class TextRecognitionState {
  final bool isScanning;
  final TextRecognitionResult? result;
  final String? errorMessage;
  final String displayedText;

  const TextRecognitionState({
    this.isScanning = false,
    this.result,
    this.errorMessage,
    this.displayedText = 'No text scanned yet. Point camera at documents, signs, or menus and tap Scan Document.',
  });

  TextRecognitionState copyWith({
    bool? isScanning,
    TextRecognitionResult? result,
    String? errorMessage,
    String? displayedText,
  }) {
    return TextRecognitionState(
      isScanning: isScanning ?? this.isScanning,
      result: result ?? this.result,
      errorMessage: errorMessage,
      displayedText: displayedText ?? this.displayedText,
    );
  }
}

class TextRecognitionController extends Notifier<TextRecognitionState> {
  @override
  TextRecognitionState build() {
    return const TextRecognitionState();
  }

  Future<void> scanDocument() async {
    if (state.isScanning) return;

    final repository = ref.read(textRecognitionRepositoryProvider);
    final cameraService = ref.read(cameraServiceProvider);
    final tts = ref.read(ttsServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    state = state.copyWith(
      isScanning: true,
      errorMessage: null,
      displayedText: 'Capturing document frame and reading text with ML Kit...',
    );

    await haptic.scanTrigger();
    await tts.speak('Capturing document. Scanning text.');

    try {
      final picture = await cameraService.takePicture();
      final ocrResult = await repository.recognizeTextFromPath(picture.path);

      state = state.copyWith(
        isScanning: false,
        result: ocrResult,
        displayedText: ocrResult.text,
      );

      await haptic.success();
      await tts.speak(ocrResult.text);
    } catch (e) {
      final errorMsg = e.toString();
      state = state.copyWith(
        isScanning: false,
        errorMessage: errorMsg,
        displayedText: 'Text scan failed: $errorMsg',
      );
      await haptic.error();
      await tts.speak('Text recognition failed. $errorMsg');
    }
  }

  Future<void> repeatText() async {
    if (state.result != null) {
      final haptic = ref.read(hapticServiceProvider);
      final tts = ref.read(ttsServiceProvider);
      await haptic.buttonPress();
      await tts.speak(state.result!.text);
    }
  }

  Future<void> stopSpeaking() async {
    final haptic = ref.read(hapticServiceProvider);
    final tts = ref.read(ttsServiceProvider);
    await haptic.buttonPress();
    await tts.stop();
  }
}

final textRecognitionControllerProvider =
    NotifierProvider<TextRecognitionController, TextRecognitionState>(
  TextRecognitionController.new,
);
