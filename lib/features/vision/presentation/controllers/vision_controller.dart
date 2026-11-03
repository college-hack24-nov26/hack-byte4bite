import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/accessibility/haptic_service.dart';
import '../../../../core/services/camera_service.dart';
import '../../../../core/services/tts_service.dart';
import '../../domain/entities/scene_result.dart';
import '../../data/repositories/vision_repository_impl.dart';

class VisionState {
  final bool isInitializingCamera;
  final bool isAnalyzing;
  final SceneResult? lastResult;
  final String? errorMessage;
  final String statusMessage;

  const VisionState({
    this.isInitializingCamera = false,
    this.isAnalyzing = false,
    this.lastResult,
    this.errorMessage,
    this.statusMessage = 'Point camera at your surroundings and tap Describe Scene.',
  });

  VisionState copyWith({
    bool? isInitializingCamera,
    bool? isAnalyzing,
    SceneResult? lastResult,
    String? errorMessage,
    String? statusMessage,
  }) {
    return VisionState(
      isInitializingCamera: isInitializingCamera ?? this.isInitializingCamera,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      lastResult: lastResult ?? this.lastResult,
      errorMessage: errorMessage,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}

class VisionController extends Notifier<VisionState> {
  @override
  VisionState build() {
    Future.microtask(() => initCamera());
    return const VisionState();
  }

  Future<void> initCamera() async {
    final cameraService = ref.read(cameraServiceProvider);
    state = state.copyWith(isInitializingCamera: true, errorMessage: null);

    try {
      await cameraService.initialize();
      state = state.copyWith(
        isInitializingCamera: false,
        statusMessage: 'Camera active. Point towards your surroundings and tap Describe Scene.',
      );
    } catch (e) {
      state = state.copyWith(
        isInitializingCamera: false,
        errorMessage: e.toString(),
        statusMessage: 'Camera initialization failed: ${e.toString()}',
      );
    }
  }

  Future<void> captureAndAnalyze() async {
    if (state.isAnalyzing) return;

    final repository = ref.read(visionRepositoryProvider);
    final cameraService = ref.read(cameraServiceProvider);
    final tts = ref.read(ttsServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    state = state.copyWith(
      isAnalyzing: true,
      errorMessage: null,
      statusMessage: 'Capturing photo and analyzing with Gemini 2.5...',
    );

    await haptic.scanTrigger();
    await tts.speak('Capturing frame. Analyzing surroundings.');

    try {
      final imageBytes = await cameraService.captureImageBytes();
      await haptic.continuousTick();

      final result = await repository.analyzeScene(imageBytes);

      state = state.copyWith(
        isAnalyzing: false,
        lastResult: result,
        statusMessage: result.description,
      );

      await haptic.success();
      await tts.speak(result.description);
    } catch (e) {
      final errorMsg = e.toString();
      state = state.copyWith(
        isAnalyzing: false,
        errorMessage: errorMsg,
        statusMessage: 'Analysis failed: $errorMsg',
      );
      await haptic.error();
      await tts.speak('Analysis failed. $errorMsg');
    }
  }

  Future<void> repeatDescription() async {
    if (state.lastResult != null) {
      final haptic = ref.read(hapticServiceProvider);
      final tts = ref.read(ttsServiceProvider);
      await haptic.buttonPress();
      await tts.speak(state.lastResult!.description);
    }
  }

  Future<void> stopSpeaking() async {
    final haptic = ref.read(hapticServiceProvider);
    final tts = ref.read(ttsServiceProvider);
    await haptic.buttonPress();
    await tts.stop();
  }
}

final visionControllerProvider =
    NotifierProvider<VisionController, VisionState>(
  VisionController.new,
);
