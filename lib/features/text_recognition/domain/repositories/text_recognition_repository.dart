import '../entities/text_recognition_result.dart';

abstract class TextRecognitionRepository {
  Future<TextRecognitionResult> recognizeTextFromPath(String imagePath);
}

