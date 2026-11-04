import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionmate/services/ai/ai_service.dart';
import '../../domain/entities/found_object.dart';
import '../../domain/repositories/object_finder_repository.dart';

class ObjectFinderRepositoryImpl implements ObjectFinderRepository {
  final AiService _aiService;

  ObjectFinderRepositoryImpl(this._aiService);

  @override
  Future<FoundObject> searchForObject({
    required Uint8List imageBytes,
    required String targetName,
  }) async {
    final responseText = await _aiService.locateObject(
      imageBytes: imageBytes,
      targetObject: targetName,
    );
    return FoundObject.fromAiResponse(
      targetName: targetName,
      responseText: responseText,
    );
  }
}

final objectFinderRepositoryProvider = Provider<ObjectFinderRepository>((ref) {
  final ai = ref.watch(aiServiceProvider);
  return ObjectFinderRepositoryImpl(ai);
});

