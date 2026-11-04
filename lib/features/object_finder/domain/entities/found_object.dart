class FoundObject {
  final String targetName;
  final bool isDetected;
  final String directionalCues;
  final String? relativePosition;
  final String? distanceEstimate;
  final DateTime timestamp;

  const FoundObject({
    required this.targetName,
    required this.isDetected,
    required this.directionalCues,
    this.relativePosition,
    this.distanceEstimate,
    required this.timestamp,
  });

  factory FoundObject.fromAiResponse({
    required String targetName,
    required String responseText,
  }) {
    final clean = responseText.trim();
    final lower = clean.toLowerCase();
    final notDetected = lower.contains('not visible') ||
        lower.contains('not detected') ||
        lower.contains('cannot see') ||
        lower.contains('not in this') ||
        lower.contains('not_found') ||
        lower.contains('no $targetName') ||
        lower.contains('could not find');

    String? position;
    if (lower.contains('straight ahead') ||
        lower.contains('directly ahead') ||
        lower.contains('in front of you') ||
        lower.contains('center')) {
      position = 'Straight ahead';
    } else if (lower.contains('to your left') ||
        lower.contains('on the left') ||
        lower.contains('slightly left')) {
      position = 'To your left';
    } else if (lower.contains('to your right') ||
        lower.contains('on the right') ||
        lower.contains('slightly right')) {
      position = 'To your right';
    }

    String? distance;
    final distMatch = RegExp(
      r'(\d+(\.\d+)?)\s*(meters?|meter|m|steps?|feet|ft)',
      caseSensitive: false,
    ).firstMatch(clean);
    if (distMatch != null) {
      distance = distMatch.group(0);
    }

    final speechOutput = clean
        .replaceAll('FOUND:', '')
        .replaceAll('NOT_FOUND:', '')
        .trim();

    return FoundObject(
      targetName: targetName,
      isDetected: !notDetected,
      directionalCues: speechOutput,
      relativePosition: position,
      distanceEstimate: distance,
      timestamp: DateTime.now(),
    );
  }
}
