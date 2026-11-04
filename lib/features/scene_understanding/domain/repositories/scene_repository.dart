import 'dart:typed_data';
import '../entities/scene_description.dart';

abstract class SceneRepository {
  Future<SceneDescription> analyzeSurroundings(Uint8List imageBytes);
  Future<String> askQuestionAboutScene({
    required Uint8List imageBytes,
    required String question,
  });
}

