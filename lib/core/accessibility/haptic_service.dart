import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HapticService {
  Future<void> buttonPress() async {
    await HapticFeedback.selectionClick();
  }

  Future<void> tabSwitch() async {
    await HapticFeedback.selectionClick();
  }

  Future<void> success() async {
    await HapticFeedback.mediumImpact();
  }

  Future<void> warning() async {
    await HapticFeedback.heavyImpact();
  }

  Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  Future<void> scanTrigger() async {
    await HapticFeedback.mediumImpact();
  }

  Future<void> continuousTick() async {
    await HapticFeedback.lightImpact();
  }
}

final hapticServiceProvider = Provider<HapticService>((ref) {
  return HapticService();
});

