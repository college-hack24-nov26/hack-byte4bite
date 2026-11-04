import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionmate/core/permissions/permission_service.dart';
import 'package:visionmate/services/speech/tts_service.dart';

class OnboardingState {
  final int currentStep;
  final bool hasCameraPermission;
  final bool hasMicPermission;
  final bool hasLocationPermission;
  final bool isCompleted;

  const OnboardingState({
    this.currentStep = 0,
    this.hasCameraPermission = false,
    this.hasMicPermission = false,
    this.hasLocationPermission = false,
    this.isCompleted = false,
  });

  OnboardingState copyWith({
    int? currentStep,
    bool? hasCameraPermission,
    bool? hasMicPermission,
    bool? hasLocationPermission,
    bool? isCompleted,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      hasCameraPermission: hasCameraPermission ?? this.hasCameraPermission,
      hasMicPermission: hasMicPermission ?? this.hasMicPermission,
      hasLocationPermission: hasLocationPermission ?? this.hasLocationPermission,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    return const OnboardingState();
  }

  void nextStep() {
    final next = state.currentStep + 1;
    state = state.copyWith(currentStep: next);
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  Future<void> requestPermissions() async {
    final permissionService = ref.read(permissionServiceProvider);
    final tts = ref.read(ttsServiceProvider);

    final cameraOk = await permissionService.requestCameraPermission();
    final micOk = await permissionService.requestMicrophonePermission();
    final locOk = await permissionService.requestLocationPermission();

    state = state.copyWith(
      hasCameraPermission: cameraOk,
      hasMicPermission: micOk,
      hasLocationPermission: locOk,
      isCompleted: true,
    );

    await tts.speak('Permissions configured. Welcome to VisionMate.');
  }

  void complete() {
    state = state.copyWith(isCompleted: true);
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingState>(() {
  return OnboardingController();
});

