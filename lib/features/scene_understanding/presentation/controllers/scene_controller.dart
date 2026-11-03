import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionmate/core/errors/error_handler.dart';
import 'package:visionmate/services/camera/camera_service.dart';
import 'package:visionmate/services/haptics/haptic_service.dart';
import 'package:visionmate/services/speech/tts_service.dart';
import 'package:visionmate/features/scene_understanding/domain/entities/scene_description.dart';
import 'package:visionmate/features/scene_understanding/data/repositories/scene_repository_impl.dart';

class SceneState {
  final bool isInitializingCamera;
  final bool isAnalyzing;
  final SceneDescription? lastDescription;
  final String? errorMessage;
  final String statusText;

  const SceneState({
    this.isInitializingCamera = false,
    this.isAnalyzing = false,
    this.lastDescription,
    this.errorMessage,
    this.statusText = 'Point camera at your surroundings and tap Describe Scene Ahead.',
  });

  SceneState copyWith({
    bool? isInitializingCamera,
    bool? isAnalyzing,
    SceneDescription? lastDescription,
    String? errorMessage,
    String? statusText,
  }) {
    return SceneState(
      isInitializingCamera: isInitializingCamera ?? this.isInitializingCamera,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      lastDescription: lastDescription ?? this.lastDescription,
      errorMessage: errorMessage,
      statusText: statusText ?? this.statusText,
    );
  }
}

class SceneController extends Notifier<SceneState> {
  @override
  SceneState build() {
    Future.microtask(() => initCamera());
    return const SceneState();
  }

  Future<void> initCamera() async {
    final cameraService = ref.read(cameraServiceProvider);
    state = state.copyWith(isInitializingCamera: true, errorMessage: null);

    try {
      await cameraService.initialize();
      state = state.copyWith(
        isInitializingCamera: false,
        statusText: 'Camera active. Point ahead and tap Describe Scene Ahead.',
      );
    } catch (e) {
      final message = ErrorHandler.getUserMessage(e);
      state = state.copyWith(
        isInitializingCamera: false,
        errorMessage: message,
        statusText: message,
      );
    }
  }

  Future<void> captureAndAnalyze() async {
    if (state.isAnalyzing) return;

    final repository = ref.read(sceneRepositoryProvider);
    final cameraService = ref.read(cameraServiceProvider);
    final tts = ref.read(ttsServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    state = state.copyWith(
      isAnalyzing: true,
      errorMessage: null,
      statusText: 'Analyzing surroundings...',
    );

    await haptic.scanTick();
    await tts.speak('Capturing frame. Analyzing surroundings.');

    try {
      final imageBytes = await cameraService.captureImageBytes();
      final result = await repository.analyzeSurroundings(imageBytes);

      state = state.copyWith(
        isAnalyzing: false,
        lastDescription: result,
        statusText: result.text,
      );

      if (result.obstacles.isNotEmpty) {
        await haptic.warning();
      } else {
        await haptic.success();
      }

      await tts.speak(result.text);
    } catch (e) {
      final errorMsg = ErrorHandler.getUserMessage(e);
      state = state.copyWith(
        isAnalyzing: false,
        errorMessage: errorMsg,
        statusText: errorMsg,
      );
      await haptic.error();
      await tts.speak(errorMsg);
    }
  }

  void repeatDescription() {
    if (state.lastDescription != null) {
      ref.read(ttsServiceProvider).speak(state.lastDescription!.text);
    }
  }

  void stopSpeaking() {
    ref.read(ttsServiceProvider).stop();
  }
}

final sceneControllerProvider =
    NotifierProvider<SceneController, SceneState>(() {
  return SceneController();
});
