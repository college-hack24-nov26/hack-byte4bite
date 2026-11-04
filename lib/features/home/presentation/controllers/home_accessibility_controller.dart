import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccessibilityControlsState {
  final double textScale;
  final bool isSoundEnabled;
  final bool isHighContrast;

  const AccessibilityControlsState({
    this.textScale = 1.0,
    this.isSoundEnabled = true,
    this.isHighContrast = false,
  });

  AccessibilityControlsState copyWith({
    double? textScale,
    bool? isSoundEnabled,
    bool? isHighContrast,
  }) {
    return AccessibilityControlsState(
      textScale: textScale ?? this.textScale,
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      isHighContrast: isHighContrast ?? this.isHighContrast,
    );
  }
}

class AccessibilityControlsController
    extends Notifier<AccessibilityControlsState> {
  @override
  AccessibilityControlsState build() {
    return const AccessibilityControlsState();
  }

  void increaseTextSize() {
    final next = (state.textScale + 0.1).clamp(0.85, 1.4);
    state = state.copyWith(textScale: next);
  }

  void decreaseTextSize() {
    final next = (state.textScale - 0.1).clamp(0.85, 1.4);
    state = state.copyWith(textScale: next);
  }

  void toggleSound() {
    state = state.copyWith(isSoundEnabled: !state.isSoundEnabled);
  }

  void toggleHighContrast() {
    state = state.copyWith(isHighContrast: !state.isHighContrast);
  }
}

final accessibilityControlsProvider = NotifierProvider<
    AccessibilityControlsController, AccessibilityControlsState>(() {
  return AccessibilityControlsController();
});
