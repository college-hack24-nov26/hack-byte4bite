class SceneDescription {
  final String text;
  final List<String> obstacles;
  final DateTime timestamp;

  const SceneDescription({
    required this.text,
    this.obstacles = const [],
    required this.timestamp,
  });

  factory SceneDescription.fromString(String text) {
    final lower = text.toLowerCase();
    final detectedObstacles = <String>[];

    final hazardKeywords = [
      'stairs',
      'steps',
      'curb',
      'doorway',
      'wall',
      'trip hazard',
      'pole',
      'vehicle',
      'car',
      'bicycle',
      'puddle',
      'hole',
    ];

    for (final hazard in hazardKeywords) {
      if (lower.contains(hazard)) {
        detectedObstacles.add(hazard);
      }
    }

    return SceneDescription(
      text: text,
      obstacles: detectedObstacles,
      timestamp: DateTime.now(),
    );
  }
}

