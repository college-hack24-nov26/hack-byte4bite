import 'dart:typed_data';
import '../entities/read_document.dart';

abstract class ReaderRepository {
  Future<ReadDocument> recognizeTextFromBytes(Uint8List imageBytes);
}

