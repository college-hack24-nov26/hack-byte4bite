import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionmate/services/ai/ai_service.dart';
import '../../domain/entities/scene_description.dart';
import '../../domain/repositories/scene_repository.dart';

class SceneRepositoryImpl implements SceneRepository {
  final AiService _aiService;

  SceneRepositoryImpl(this._aiService);

  @override
  Future<SceneDescription> analyzeSurroundings(Uint8List imageBytes) async {
    final descriptionText = await _aiService.describeScene(imageBytes);
    return SceneDescription.fromString(descriptionText);
  }

  @override
  Future<String> askQuestionAboutScene({
    required Uint8List imageBytes,
    required String question,
  }) async {
    return await _aiService.askVisualQuestion(
      imageBytes: imageBytes,
      question: question,
    );
  }
}

final sceneRepositoryProvider = Provider<SceneRepository>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  return SceneRepositoryImpl(aiService);
});

