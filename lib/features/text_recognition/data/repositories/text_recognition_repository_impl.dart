import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/ocr_service.dart';
import '../../domain/entities/text_recognition_result.dart';
import '../../domain/repositories/text_recognition_repository.dart';
import '../datasources/ocr_datasource.dart';

class TextRecognitionRepositoryImpl implements TextRecognitionRepository {
  final OcrDataSource _dataSource;

  TextRecognitionRepositoryImpl(this._dataSource);

  @override
  Future<TextRecognitionResult> recognizeTextFromPath(String imagePath) async {
    final text = await _dataSource.recognizeText(imagePath);
    return TextRecognitionResult(
      text: text,
      timestamp: DateTime.now(),
    );
  }
}

final ocrDataSourceProvider = Provider<OcrDataSource>((ref) {
  final ocrService = ref.watch(ocrServiceProvider);
  return OcrDataSource(ocrService);
});

final textRecognitionRepositoryProvider =
    Provider<TextRecognitionRepository>((ref) {
  final dataSource = ref.watch(ocrDataSourceProvider);
  return TextRecognitionRepositoryImpl(dataSource);
});

