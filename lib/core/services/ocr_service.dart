import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../errors/app_exception.dart';

class OcrService {
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  Future<String> recognizeTextFromPath(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      final text = recognizedText.text.trim();
      if (text.isEmpty) {
        return 'No readable text was detected in the captured image.';
      }
      return text;
    } catch (e) {
      throw OcrException('Failed to recognize text: ${e.toString()}');
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}

final ocrServiceProvider = Provider<OcrService>((ref) {
  final service = OcrService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

