import 'dart:typed_data';
import '../../../../core/services/gemini_service.dart';

class VisionRemoteDataSource {
  final GeminiService _geminiService;

  VisionRemoteDataSource(this._geminiService);

  Future<String> describeScene(Uint8List imageBytes) async {
    return await _geminiService.describeScene(imageBytes);
  }
}

