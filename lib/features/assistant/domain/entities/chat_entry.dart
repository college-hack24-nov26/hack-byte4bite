class ChatEntry {
  final String sender;
  final String text;
  final DateTime timestamp;

  const ChatEntry({
    required this.sender,
    required this.text,
    required this.timestamp,
  });

  bool get isUser => sender == 'user';
}

