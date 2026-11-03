import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionmate/core/errors/error_handler.dart';
import 'package:visionmate/services/haptics/haptic_service.dart';
import 'package:visionmate/services/speech/tts_service.dart';
import 'package:visionmate/shared/models/geo_point_model.dart';
import '../../data/repositories/navigation_repository_impl.dart';

class NavigationState {
  final bool isTracking;
  final GeoPointModel? currentPoint;
  final String? errorMessage;
  final String statusText;

  const NavigationState({
    this.isTracking = false,
    this.currentPoint,
    this.errorMessage,
    this.statusText = 'Tap Get Current Location or Start Live Tracking to begin.',
  });

  NavigationState copyWith({
    bool? isTracking,
    GeoPointModel? currentPoint,
    String? errorMessage,
    String? statusText,
  }) {
    return NavigationState(
      isTracking: isTracking ?? this.isTracking,
      currentPoint: currentPoint ?? this.currentPoint,
      errorMessage: errorMessage,
      statusText: statusText ?? this.statusText,
    );
  }
}

class NavigationController extends Notifier<NavigationState> {
  StreamSubscription<GeoPointModel>? _sub;

  @override
  NavigationState build() {
    ref.onDispose(() {
      _sub?.cancel();
    });
    return const NavigationState();
  }

  Future<void> updateCurrentLocation() async {
    final repo = ref.read(navigationRepositoryProvider);
    final tts = ref.read(ttsServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    state = state.copyWith(
      errorMessage: null,
      statusText: 'Locating current GPS coordinates...',
    );

    await haptic.scanTick();

    try {
      final point = await repo.getCurrentLocation();
      final speechText =
          'Current heading ${point.formatHeading()}. Coordinates: ${point.formatCoordinates()}.';

      state = state.copyWith(
        currentPoint: point,
        statusText: speechText,
      );

      await haptic.success();
      await tts.speak(speechText);
    } catch (e) {
      final message = ErrorHandler.getUserMessage(e);
      state = state.copyWith(
        errorMessage: message,
        statusText: message,
      );
      await haptic.error();
      await tts.speak(message);
    }
  }

  void toggleLiveTracking() {
    if (state.isTracking) {
      _sub?.cancel();
      _sub = null;
      state = state.copyWith(isTracking: false);
      ref.read(ttsServiceProvider).speak('Live navigation tracking stopped.');
    } else {
      final repo = ref.read(navigationRepositoryProvider);
      final tts = ref.read(ttsServiceProvider);
      final haptic = ref.read(hapticServiceProvider);

      state = state.copyWith(isTracking: true);
      tts.speak('Live navigation tracking active.');
      haptic.success();

      _sub = repo.watchLocation().listen(
        (point) {
          state = state.copyWith(
            currentPoint: point,
            statusText:
                'Heading: ${point.formatHeading()}\n${point.formatCoordinates()}',
          );
        },
        onError: (err) {
          state = state.copyWith(
            isTracking: false,
            errorMessage: err.toString(),
          );
        },
      );
    }
  }

  void repeatLocation() {
    if (state.currentPoint != null) {
      final p = state.currentPoint!;
      ref.read(ttsServiceProvider).speak(
        'Heading ${p.formatHeading()}. Coordinates: ${p.formatCoordinates()}. Accuracy: ${p.accuracy.toStringAsFixed(1)} meters.',
      );
    }
  }

  void stopSpeaking() {
    ref.read(ttsServiceProvider).stop();
  }
}

final navigationControllerProvider =
    NotifierProvider<NavigationController, NavigationState>(() {
  return NavigationController();
});
