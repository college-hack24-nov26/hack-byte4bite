import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionmate/services/camera/camera_service.dart';
import 'package:visionmate/services/haptics/haptic_service.dart';
import 'package:visionmate/services/speech/stt_service.dart';
import 'package:visionmate/services/speech/tts_service.dart';
import 'package:visionmate/features/object_finder/domain/entities/found_object.dart';
import 'package:visionmate/features/object_finder/data/repositories/object_finder_repository_impl.dart';

class ObjectFinderState {
  final String currentTarget;
  final String spokenQuery;
  final bool isListening;
  final bool is360Scanning;
  final bool isAnalyzingFrame;
  final int scanCount;
  final FoundObject? lastResult;
  final String? errorMessage;
  final String statusText;

  const ObjectFinderState({
    this.currentTarget = '',
    this.spokenQuery = '',
    this.isListening = false,
    this.is360Scanning = false,
    this.isAnalyzingFrame = false,
    this.scanCount = 0,
    this.lastResult,
    this.errorMessage,
    this.statusText = 'Tap the microphone and say what you want to find (e.g. "Where is my smartphone?").',
  });

  ObjectFinderState copyWith({
    String? currentTarget,
    String? spokenQuery,
    bool? isListening,
    bool? is360Scanning,
    bool? isAnalyzingFrame,
    int? scanCount,
    FoundObject? lastResult,
    String? errorMessage,
    String? statusText,
  }) {
    return ObjectFinderState(
      currentTarget: currentTarget ?? this.currentTarget,
      spokenQuery: spokenQuery ?? this.spokenQuery,
      isListening: isListening ?? this.isListening,
      is360Scanning: is360Scanning ?? this.is360Scanning,
      isAnalyzingFrame: isAnalyzingFrame ?? this.isAnalyzingFrame,
      scanCount: scanCount ?? this.scanCount,
      lastResult: lastResult ?? this.lastResult,
      errorMessage: errorMessage,
      statusText: statusText ?? this.statusText,
    );
  }
}

class ObjectFinderController extends Notifier<ObjectFinderState> {
  bool _isScanningActive = false;

  @override
  ObjectFinderState build() {
    ref.onDispose(() {
      _isScanningActive = false;
    });
    return const ObjectFinderState();
  }

  String _extractTarget(String query) {
    var text = query.trim().toLowerCase();
    text = text.replaceAll(RegExp(r'[?.!,]'), '').trim();

    final prefixes = [
      'can you please find my',
      'can you please find the',
      'can you find my',
      'can you find the',
      'can you find',
      'please find my',
      'please find the',
      'please find',
      'where is my',
      'where are my',
      'where is the',
      'where are the',
      'where is',
      'where are',
      'find my',
      'find the',
      'find',
      'look for my',
      'look for the',
      'look for',
      'search for my',
      'search for the',
      'search for',
      'locate my',
      'locate the',
      'locate',
      'tell me where is my',
      'tell me where is the',
      'tell me where is',
      'i want to find my',
      'i want to find the',
      'i want to find',
      'i am looking for my',
      'i am looking for the',
      'i am looking for',
    ];

    for (final prefix in prefixes) {
      if (text.startsWith(prefix)) {
        text = text.substring(prefix.length).trim();
        break;
      }
    }

    if (text.isEmpty) {
      return query.trim();
    }
    return text;
  }

  void setTarget(String target) {
    final clean = target.trim();
    if (clean.isEmpty) return;
    state = state.copyWith(
      currentTarget: clean,
      statusText: 'Target set to "$clean". Turn 360° slowly and tap Start Scan.',
    );
  }

  Future<void> startVoicePrompt() async {
    _isScanningActive = false;
    final stt = ref.read(sttServiceProvider);
    final tts = ref.read(ttsServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    await tts.stop();
    await haptic.scanTick();

    state = state.copyWith(
      isListening: true,
      is360Scanning: false,
      spokenQuery: '',
      errorMessage: null,
      statusText: 'Listening... Say what you want to find (e.g. "Where is my smartphone?").',
    );

    await tts.speak('What object are you looking for?');

    await stt.startListening(
      onResult: (text) {
        state = state.copyWith(
          spokenQuery: text,
        );
      },
      onDone: () async {
        await stopListeningAndSearch();
      },
    );
  }

  Future<void> stopListeningAndSearch() async {
    final stt = ref.read(sttServiceProvider);
    await stt.stopListening();

    state = state.copyWith(isListening: false);

    final rawSpeech = state.spokenQuery.trim();
    if (rawSpeech.isEmpty) {
      state = state.copyWith(
        statusText: 'No speech detected. Tap Speak Target to try again.',
      );
      return;
    }

    final target = _extractTarget(rawSpeech);
    setTarget(target);
    await start360Scan();
  }

  Future<void> start360Scan() async {
    if (state.currentTarget.trim().isEmpty) {
      await startVoicePrompt();
      return;
    }

    if (_isScanningActive) return;
    _isScanningActive = true;

    final tts = ref.read(ttsServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    state = state.copyWith(
      is360Scanning: true,
      scanCount: 0,
      errorMessage: null,
      statusText: '360° Radar Active. Turn your phone slowly in a full circle searching for "${state.currentTarget}"...',
    );

    await tts.speak(
      'Searching for ${state.currentTarget}. Turn your phone around slowly 360 degrees.',
    );

    while (_isScanningActive && state.is360Scanning) {
      if (state.isAnalyzingFrame) {
        await Future.delayed(const Duration(milliseconds: 300));
        continue;
      }

      state = state.copyWith(isAnalyzingFrame: true);

      try {
        await haptic.scanTick();

        final camera = ref.read(cameraServiceProvider);
        if (!camera.isInitialized) {
          await camera.initialize();
        }

        final imageBytes = await camera.captureImageBytes();
        final repo = ref.read(objectFinderRepositoryProvider);
        final result = await repo.searchForObject(
          imageBytes: imageBytes,
          targetName: state.currentTarget,
        );

        final newCount = state.scanCount + 1;

        if (result.isDetected) {
          _isScanningActive = false;
          state = state.copyWith(
            is360Scanning: false,
            isAnalyzingFrame: false,
            scanCount: newCount,
            lastResult: result,
            statusText: result.directionalCues,
          );

          await haptic.success();
          await tts.speak(result.directionalCues);
          break;
        } else {
          state = state.copyWith(
            isAnalyzingFrame: false,
            scanCount: newCount,
            lastResult: result,
            statusText: 'Scanned angle $newCount: ${state.currentTarget} not in view. Keep turning 360° slowly...',
          );

          if (newCount % 4 == 0) {
            await tts.speak('Keep turning slowly. Still looking for ${state.currentTarget}.');
          }

          await Future.delayed(const Duration(milliseconds: 1800));
        }
      } catch (e) {
        state = state.copyWith(
          isAnalyzingFrame: false,
        );
        await Future.delayed(const Duration(milliseconds: 2000));
      }
    }
  }

  Future<void> stop360Scan() async {
    _isScanningActive = false;
    final tts = ref.read(ttsServiceProvider);
    state = state.copyWith(
      is360Scanning: false,
      isAnalyzingFrame: false,
      statusText: '360° radar scan paused. Tap Start 360° Scan to resume.',
    );
    await tts.speak('Scan paused.');
  }

  void repeatResult() {
    if (state.lastResult != null) {
      ref.read(ttsServiceProvider).speak(state.lastResult!.directionalCues);
    } else {
      ref.read(ttsServiceProvider).speak(state.statusText);
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
