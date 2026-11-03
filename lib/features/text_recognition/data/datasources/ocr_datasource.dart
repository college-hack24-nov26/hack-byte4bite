import '../../../../core/services/ocr_service.dart';

class OcrDataSource {
  final OcrService _ocrService;

  OcrDataSource(this._ocrService);

  Future<String> recognizeText(String imagePath) async {
    return await _ocrService.recognizeTextFromPath(imagePath);
  }
}

