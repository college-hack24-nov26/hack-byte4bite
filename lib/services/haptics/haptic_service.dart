import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class HapticService {
  Future<void> selection();
  Future<void> success();
  Future<void> warning();
  Future<void> error();
  Future<void> scanTick();
  Future<void> emergencyAlarm();
}

class SystemHapticService implements HapticService {
  const SystemHapticService();

  @override
  Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  @override
  Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  @override
  Future<void> warning() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.heavyImpact();
  }

  @override
  Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  @override
  Future<void> scanTick() async {
    await HapticFeedback.selectionClick();
  }

  @override
  Future<void> emergencyAlarm() async {
    for (int i = 0; i < 3; i++) {
      await HapticFeedback.vibrate();
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }
}

final hapticServiceProvider = Provider<HapticService>((ref) {
  return const SystemHapticService();
});

