import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/read_document.dart';
import '../../domain/repositories/reader_repository.dart';
import '../datasources/ocr_datasource.dart';

class ReaderRepositoryImpl implements ReaderRepository {
  final OcrDataSource _ocrDataSource;

  ReaderRepositoryImpl(this._ocrDataSource);

  @override
  Future<ReadDocument> recognizeTextFromBytes(Uint8List imageBytes) async {
    final lines = await _ocrDataSource.processImageBytes(imageBytes);
    final fullText = lines.join('\n');
    return ReadDocument(
      fullText: fullText,
      lines: lines,
      timestamp: DateTime.now(),
    );
  }
}

final readerRepositoryProvider = Provider<ReaderRepository>((ref) {
  final dataSource = ref.watch(ocrDataSourceProvider);
  return ReaderRepositoryImpl(dataSource);
});

