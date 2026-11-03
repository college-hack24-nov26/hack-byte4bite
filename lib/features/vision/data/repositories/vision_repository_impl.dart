import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/gemini_service.dart';
import '../../domain/entities/scene_result.dart';
import '../../domain/repositories/vision_repository.dart';
import '../datasources/vision_remote_datasource.dart';

class VisionRepositoryImpl implements VisionRepository {
  final VisionRemoteDataSource _remoteDataSource;

  VisionRepositoryImpl(this._remoteDataSource);

  @override
  Future<SceneResult> analyzeScene(Uint8List imageBytes) async {
    final description = await _remoteDataSource.describeScene(imageBytes);
    return SceneResult(
      description: description,
      timestamp: DateTime.now(),
    );
  }
}

final visionRemoteDataSourceProvider = Provider<VisionRemoteDataSource>((ref) {
  final geminiService = ref.watch(geminiServiceProvider);
  return VisionRemoteDataSource(geminiService);
});

final visionRepositoryProvider = Provider<VisionRepository>((ref) {
  final remoteDataSource = ref.watch(visionRemoteDataSourceProvider);
  return VisionRepositoryImpl(remoteDataSource);
});

