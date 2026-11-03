import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionmate/core/errors/error_handler.dart';
import 'package:visionmate/services/camera/camera_service.dart';
import 'package:visionmate/services/haptics/haptic_service.dart';
import 'package:visionmate/services/speech/tts_service.dart';
import 'package:visionmate/features/object_finder/domain/entities/found_object.dart';
import 'package:visionmate/features/object_finder/data/repositories/object_finder_repository_impl.dart';

class ObjectFinderState {
  final String currentTarget;
  final bool isSearching;
  final FoundObject? lastResult;
  final String? errorMessage;
  final String statusText;

  const ObjectFinderState({
    this.currentTarget = 'Door',
    this.isSearching = false,
    this.lastResult,
    this.errorMessage,
    this.statusText = 'Select or enter an item to find, then tap Search for Object.',
  });

  ObjectFinderState copyWith({
    String? currentTarget,
    bool? isSearching,
    FoundObject? lastResult,
    String? errorMessage,
    String? statusText,
  }) {
    return ObjectFinderState(
      currentTarget: currentTarget ?? this.currentTarget,
      isSearching: isSearching ?? this.isSearching,
      lastResult: lastResult ?? this.lastResult,
      errorMessage: errorMessage,
      statusText: statusText ?? this.statusText,
    );
  }
}

class ObjectFinderController extends Notifier<ObjectFinderState> {
  @override
  ObjectFinderState build() {
    return const ObjectFinderState();
  }

  void setTarget(String target) {
    state = state.copyWith(
      currentTarget: target.trim(),
      statusText: 'Target set to "$target". Point camera and tap Search.',
    );
    ref.read(ttsServiceProvider).speak('Target set to $target.');
  }

  Future<void> search() async {
    if (state.isSearching) return;

    final repo = ref.read(objectFinderRepositoryProvider);
    final camera = ref.read(cameraServiceProvider);
    final tts = ref.read(ttsServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    state = state.copyWith(
      isSearching: true,
      errorMessage: null,
      statusText: 'Scanning scene for "${state.currentTarget}"...',
    );

    await haptic.scanTick();
    await tts.speak('Looking for ${state.currentTarget}.');

    try {
      final imageBytes = await camera.captureImageBytes();
      final result = await repo.searchForObject(
        imageBytes: imageBytes,
        targetName: state.currentTarget,
      );

      state = state.copyWith(
        isSearching: false,
        lastResult: result,
        statusText: result.directionalCues,
      );

      if (result.isDetected) {
        await haptic.success();
      } else {
        await haptic.warning();
      }

      await tts.speak(result.directionalCues);
    } catch (e) {
      final message = ErrorHandler.getUserMessage(e);
      state = state.copyWith(
        isSearching: false,
        errorMessage: message,
        statusText: message,
      );
      await haptic.error();
      await tts.speak(message);
    }
  }

  void repeatResult() {
    if (state.lastResult != null) {
      ref.read(ttsServiceProvider).speak(state.lastResult!.directionalCues);
    }
  }

  void stopSpeaking() {
    ref.read(ttsServiceProvider).stop();
  }
}

final objectFinderControllerProvider =
    NotifierProvider<ObjectFinderController, ObjectFinderState>(() {
  return ObjectFinderController();
});
