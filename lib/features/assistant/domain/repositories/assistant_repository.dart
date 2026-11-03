import 'dart:typed_data';
import '../entities/chat_entry.dart';

abstract class AssistantRepository {
  Future<String> askQuestion({
    required String question,
    List<ChatEntry> history = const [],
  });

  Future<String> askVisualQuestion({
    required Uint8List imageBytes,
    required String question,
  });
}

