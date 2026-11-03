import 'dart:typed_data';
import '../entities/scene_result.dart';

abstract class VisionRepository {
  Future<SceneResult> analyzeScene(Uint8List imageBytes);
}

