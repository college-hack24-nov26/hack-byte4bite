import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionmate/services/camera/camera_service.dart';
import 'package:visionmate/services/haptics/haptic_service.dart';
import 'package:visionmate/services/location/location_service.dart';
import 'package:visionmate/services/speech/tts_service.dart';
import 'package:visionmate/features/emergency/domain/entities/emergency_contact.dart';
import 'package:visionmate/features/emergency/data/repositories/emergency_repository_impl.dart';

class EmergencyState {
  final bool isAlarmActive;
  final List<EmergencyContact> contacts;
  final String statusText;

  const EmergencyState({
    this.isAlarmActive = false,
    this.contacts = const [],
    this.statusText = 'Press SOS button for immediate distress beacon and location broadcast.',
  });

  EmergencyState copyWith({
    bool? isAlarmActive,
    List<EmergencyContact>? contacts,
    String? statusText,
  }) {
    return EmergencyState(
      isAlarmActive: isAlarmActive ?? this.isAlarmActive,
      contacts: contacts ?? this.contacts,
      statusText: statusText ?? this.statusText,
    );
  }
}

class EmergencyController extends Notifier<EmergencyState> {
  Timer? _alarmTimer;

  @override
  EmergencyState build() {
    ref.onDispose(() {
      _alarmTimer?.cancel();
    });
    Future.microtask(() => loadContacts());
    return const EmergencyState();
  }

  Future<void> loadContacts() async {
    final repo = ref.read(emergencyRepositoryProvider);
    final list = await repo.getContacts();
    state = state.copyWith(contacts: list);
  }

  Future<void> triggerSos() async {
    final tts = ref.read(ttsServiceProvider);
    final haptic = ref.read(hapticServiceProvider);
    final locationService = ref.read(locationServiceProvider);
    final camera = ref.read(cameraServiceProvider);

    await haptic.emergencyAlarm();

    String locationString = '';
    try {
      final loc = await locationService.getCurrentLocation();
      locationString = 'Coordinates: ${loc.formatCoordinates()}.';
    } catch (_) {
      locationString = 'Location coordinates unavailable.';
    }

    final alertMsg =
        'Emergency alert triggered! Need urgent assistance. $locationString';

    state = state.copyWith(
      isAlarmActive: true,
      statusText: alertMsg,
    );

    try {
      await camera.toggleTorch(true);
    } catch (_) {}

    await tts.speak(alertMsg);

    _alarmTimer?.cancel();
    _alarmTimer = Timer.periodic(const Duration(seconds: 8), (_) async {
      await haptic.emergencyAlarm();
      await tts.speak('Emergency distress beacon active. Need assistance.');
    });
  }

  Future<void> stopSos() async {
    _alarmTimer?.cancel();
    _alarmTimer = null;

    final tts = ref.read(ttsServiceProvider);
    final camera = ref.read(cameraServiceProvider);

    try {
      await camera.toggleTorch(false);
    } catch (_) {}

    await tts.stop();
    state = state.copyWith(
      isAlarmActive: false,
      statusText: 'Emergency alarm stopped.',
    );
    await tts.speak('Emergency alarm deactivated.');
  }

  Future<void> addContact(String name, String phone) async {
    final repo = ref.read(emergencyRepositoryProvider);
    final newContact = EmergencyContact(
      id: 'contact_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      phoneNumber: phone.trim(),
    );
    await repo.addContact(newContact);
    await loadContacts();
    ref.read(ttsServiceProvider).speak('Added contact ${newContact.name}.');
  }

  Future<void> removeContact(String id) async {
    final repo = ref.read(emergencyRepositoryProvider);
    await repo.removeContact(id);
    await loadContacts();
    ref.read(ttsServiceProvider).speak('Contact removed.');
  }
}

final emergencyControllerProvider =
    NotifierProvider<EmergencyController, EmergencyState>(() {
  return EmergencyController();
});
