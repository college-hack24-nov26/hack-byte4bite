class EmergencyContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String relationship;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.relationship = 'Contact',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'relationship': relationship,
    };
  }

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      relationship: json['relationship'] as String? ?? 'Contact',
    );
  }
}

