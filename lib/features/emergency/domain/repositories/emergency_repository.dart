import '../entities/emergency_contact.dart';

abstract class EmergencyRepository {
  Future<List<EmergencyContact>> getContacts();
  Future<void> addContact(EmergencyContact contact);
  Future<void> removeContact(String contactId);
}

