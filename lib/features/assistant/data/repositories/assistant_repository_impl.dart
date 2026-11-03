import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/gemini_service.dart';
import '../../domain/entities/chat_entry.dart';
import '../../domain/repositories/assistant_repository.dart';
import '../datasources/assistant_remote_datasource.dart';

class AssistantRepositoryImpl implements AssistantRepository {
  final AssistantRemoteDataSource _dataSource;

  AssistantRepositoryImpl(this._dataSource);

  @override
  Future<String> askQuestion({
    required String question,
    List<ChatEntry> history = const [],
  }) async {
    final mappedHistory = history
        .map((entry) => {
              'sender': entry.sender,
              'text': entry.text,
            })
        .toList();

    return await _dataSource.askQuestion(
      question: question,
      history: mappedHistory,
    );
  }

  @override
  Future<String> askVisualQuestion({
    required Uint8List imageBytes,
    required String question,
  }) async {
    return await _dataSource.askVisualQuestion(
      imageBytes: imageBytes,
      question: question,
    );
  }
}

final assistantRemoteDataSourceProvider =
    Provider<AssistantRemoteDataSource>((ref) {
  final geminiService = ref.watch(geminiServiceProvider);
  return AssistantRemoteDataSource(geminiService);
});

final assistantRepositoryProvider = Provider<AssistantRepository>((ref) {
  final dataSource = ref.watch(assistantRemoteDataSourceProvider);
  return AssistantRepositoryImpl(dataSource);
});

