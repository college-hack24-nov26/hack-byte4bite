class ReadDocument {
  final String fullText;
  final List<String> lines;
  final DateTime timestamp;

  const ReadDocument({
    required this.fullText,
    required this.lines,
    required this.timestamp,
  });

  bool get isEmpty => fullText.trim().isEmpty;
}

