import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/accessibility/haptic_service.dart';
import '../../../../core/services/tts_service.dart';
import '../../domain/entities/location_point.dart';
import '../../data/repositories/navigation_repository_impl.dart';

class NavigationState {
  final bool isLoading;
  final bool isTracking;
  final LocationPoint? currentPoint;
  final String? errorMessage;
  final String statusText;

  const NavigationState({
    this.isLoading = false,
    this.isTracking = false,
    this.currentPoint,
    this.errorMessage,
    this.statusText = 'Location not updated yet. Tap Update Location to acquire GPS coordinates.',
  });

  NavigationState copyWith({
    bool? isLoading,
    bool? isTracking,
    LocationPoint? currentPoint,
    String? errorMessage,
    String? statusText,
  }) {
    return NavigationState(
      isLoading: isLoading ?? this.isLoading,
      isTracking: isTracking ?? this.isTracking,
      currentPoint: currentPoint ?? this.currentPoint,
      errorMessage: errorMessage,
      statusText: statusText ?? this.statusText,
    );
  }
}

class NavigationController extends Notifier<NavigationState> {
  StreamSubscription<LocationPoint>? _trackingSubscription;

  @override
  NavigationState build() {
    ref.onDispose(() {
      _trackingSubscription?.cancel();
    });
    return const NavigationState();
  }

  Future<void> updateCurrentLocation() async {
    final repository = ref.read(navigationRepositoryProvider);
    final tts = ref.read(ttsServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    state = state.copyWith(isLoading: true, errorMessage: null);
    await haptic.buttonPress();
    await tts.speak('Acquiring GPS fix.');

    try {
      final point = await repository.getCurrentLocation();
      final summary = point.formatSpokenSummary();

      state = state.copyWith(
        isLoading: false,
        currentPoint: point,
        statusText: summary,
      );

      await haptic.success();
      await tts.speak(summary);
    } catch (e) {
      final errorMsg = e.toString();
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMsg,
        statusText: 'GPS acquisition error: $errorMsg',
      );
      await haptic.error();
      await tts.speak('GPS error: $errorMsg');
    }
  }

  void toggleContinuousTracking() {
    final repository = ref.read(navigationRepositoryProvider);
    final tts = ref.read(ttsServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    if (state.isTracking) {
      _trackingSubscription?.cancel();
      _trackingSubscription = null;
      state = state.copyWith(isTracking: false);
      haptic.buttonPress();
      tts.speak('Continuous tracking disabled.');
      return;
    }

    haptic.scanTrigger();
    tts.speak('Continuous tracking active. You will receive updates as you move.');
    state = state.copyWith(isTracking: true);

    _trackingSubscription = repository.streamLocation().listen(
      (point) {
        state = state.copyWith(
          currentPoint: point,
          statusText: point.formatSpokenSummary(),
        );
      },
      onError: (e) {
        state = state.copyWith(
          isTracking: false,
          errorMessage: e.toString(),
        );
      },
    );
  }

  Future<void> repeatLocation() async {
    if (state.currentPoint != null) {
      final haptic = ref.read(hapticServiceProvider);
      final tts = ref.read(ttsServiceProvider);
      await haptic.buttonPress();
      await tts.speak(state.currentPoint!.formatSpokenSummary());
    }
  }

  Future<void> stopSpeaking() async {
    final haptic = ref.read(hapticServiceProvider);
    final tts = ref.read(ttsServiceProvider);
    await haptic.buttonPress();
    await tts.stop();
  }
}

final navigationControllerProvider =
    NotifierProvider<NavigationController, NavigationState>(
  NavigationController.new,
);
