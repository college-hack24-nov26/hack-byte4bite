import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

abstract class OcrDataSource {
  Future<List<String>> processImageBytes(Uint8List bytes);
  void dispose();
}

class MlKitOcrDataSource implements OcrDataSource {
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<List<String>> processImageBytes(Uint8List bytes) async {
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/ocr_${DateTime.now().microsecondsSinceEpoch}.jpg');
    try {
      await tempFile.writeAsBytes(bytes);
      final inputImage = InputImage.fromFilePath(tempFile.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      final lines = <String>[];
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          final trimmed = line.text.trim();
          if (trimmed.isNotEmpty) {
            lines.add(trimmed);
          }
        }
      }
      return lines;
    } finally {
      if (await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _textRecognizer.close();
  }
}

final ocrDataSourceProvider = Provider<OcrDataSource>((ref) {
  final ds = MlKitOcrDataSource();
  ref.onDispose(() {
    ds.dispose();
  });
  return ds;
});

