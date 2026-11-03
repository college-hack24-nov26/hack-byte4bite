class AppUser {
  final String id;
  final String? email;
  final bool isAnonymous;
  final double speechRate;
  final bool hapticsEnabled;

  const AppUser({
    required this.id,
    this.email,
    this.isAnonymous = false,
    this.speechRate = 0.5,
    this.hapticsEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'isAnonymous': isAnonymous,
      'speechRate': speechRate,
      'hapticsEnabled': hapticsEnabled,
      'lastActive': DateTime.now().toIso8601String(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      id: id,
      email: map['email'] as String?,
      isAnonymous: map['isAnonymous'] as bool? ?? false,
      speechRate: (map['speechRate'] as num?)?.toDouble() ?? 0.5,
      hapticsEnabled: map['hapticsEnabled'] as bool? ?? true,
    );
  }
}

