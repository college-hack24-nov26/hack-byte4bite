import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionmate/core/errors/error_handler.dart';
import 'package:visionmate/services/camera/camera_service.dart';
import 'package:visionmate/services/haptics/haptic_service.dart';
import 'package:visionmate/services/speech/tts_service.dart';
import 'package:visionmate/features/smart_reader/domain/entities/read_document.dart';
import 'package:visionmate/features/smart_reader/data/repositories/reader_repository_impl.dart';

class ReaderState {
  final bool isScanning;
  final ReadDocument? document;
  final String? errorMessage;
  final String statusText;

  const ReaderState({
    this.isScanning = false,
    this.document,
    this.errorMessage,
    this.statusText = 'Point camera at any sign, label, menu, or page and tap Read Text Ahead.',
  });

  ReaderState copyWith({
    bool? isScanning,
    ReadDocument? document,
    String? errorMessage,
    String? statusText,
  }) {
    return ReaderState(
      isScanning: isScanning ?? this.isScanning,
      document: document ?? this.document,
      errorMessage: errorMessage,
      statusText: statusText ?? this.statusText,
    );
  }
}

class ReaderController extends Notifier<ReaderState> {
  @override
  ReaderState build() {
    return const ReaderState();
  }

  Future<void> scanAndRead() async {
    if (state.isScanning) return;

    final repo = ref.read(readerRepositoryProvider);
    final camera = ref.read(cameraServiceProvider);
    final tts = ref.read(ttsServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    state = state.copyWith(
      isScanning: true,
      errorMessage: null,
      statusText: 'Reading text from image...',
    );

    await haptic.scanTick();
    await tts.speak('Scanning text.');

    try {
      final imageBytes = await camera.captureImageBytes();
      final doc = await repo.recognizeTextFromBytes(imageBytes);

      if (doc.isEmpty) {
        state = state.copyWith(
          isScanning: false,
          document: doc,
          statusText: 'No readable text was detected. Try moving closer or adjusting angle.',
        );
        await haptic.warning();
        await tts.speak('No readable text detected.');
      } else {
        state = state.copyWith(
          isScanning: false,
          document: doc,
          statusText: doc.fullText,
        );
        await haptic.success();
        await tts.speak(doc.fullText);
      }
    } catch (e) {
      final message = ErrorHandler.getUserMessage(e);
      state = state.copyWith(
        isScanning: false,
        errorMessage: message,
        statusText: message,
      );
      await haptic.error();
      await tts.speak(message);
    }
  }

  void repeatText() {
    if (state.document != null && !state.document!.isEmpty) {
      ref.read(ttsServiceProvider).speak(state.document!.fullText);
    }
  }

  void stopSpeaking() {
    ref.read(ttsServiceProvider).stop();
  }
}

final readerControllerProvider =
    NotifierProvider<ReaderController, ReaderState>(() {
  return ReaderController();
});
