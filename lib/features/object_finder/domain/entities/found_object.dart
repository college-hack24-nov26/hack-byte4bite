class FoundObject {
  final String targetName;
  final bool isDetected;
  final String directionalCues;
  final DateTime timestamp;

  const FoundObject({
    required this.targetName,
    required this.isDetected,
    required this.directionalCues,
    required this.timestamp,
  });

  factory FoundObject.fromAiResponse({
    required String targetName,
    required String responseText,
  }) {
    final lower = responseText.toLowerCase();
    final notDetected = lower.contains('not visible') ||
        lower.contains('not detected') ||
        lower.contains('cannot see') ||
        lower.contains('no $targetName');

    return FoundObject(
      targetName: targetName,
      isDetected: !notDetected,
      directionalCues: responseText,
      timestamp: DateTime.now(),
    );
  }
}

