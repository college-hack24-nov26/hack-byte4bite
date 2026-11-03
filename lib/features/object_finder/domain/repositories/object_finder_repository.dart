import 'dart:typed_data';
import '../entities/found_object.dart';

abstract class ObjectFinderRepository {
  Future<FoundObject> searchForObject({
    required Uint8List imageBytes,
    required String targetName,
  });
}

