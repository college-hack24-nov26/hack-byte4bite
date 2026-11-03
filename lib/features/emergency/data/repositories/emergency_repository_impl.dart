import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionmate/core/constants/app_constants.dart';
import 'package:visionmate/core/utils/secure_storage_helper.dart';
import '../../domain/entities/emergency_contact.dart';
import '../../domain/repositories/emergency_repository.dart';

class EmergencyRepositoryImpl implements EmergencyRepository {
  final SecureStorageHelper _storage;

  EmergencyRepositoryImpl(this._storage);

  @override
  Future<List<EmergencyContact>> getContacts() async {
    final raw = await _storage.read(AppConstants.secureStorageEmergencyContactKey);
    if (raw == null || raw.trim().isEmpty) {
      return [
        const EmergencyContact(
          id: 'default_emergency_service',
          name: 'Emergency Services (911 / 112)',
          phoneNumber: '112',
          relationship: 'Emergency Authority',
        ),
      ];
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => EmergencyContact.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addContact(EmergencyContact contact) async {
    final list = await getContacts();
    list.add(contact);
    final raw = jsonEncode(list.map((c) => c.toJson()).toList());
    await _storage.write(AppConstants.secureStorageEmergencyContactKey, raw);
  }

  @override
  Future<void> removeContact(String contactId) async {
    final list = await getContacts();
    list.removeWhere((c) => c.id == contactId);
    final raw = jsonEncode(list.map((c) => c.toJson()).toList());
    await _storage.write(AppConstants.secureStorageEmergencyContactKey, raw);
  }
}

final emergencyRepositoryProvider = Provider<EmergencyRepository>((ref) {
  final storage = ref.watch(secureStorageHelperProvider);
  return EmergencyRepositoryImpl(storage);
});

