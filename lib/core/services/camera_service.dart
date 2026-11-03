import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../errors/app_exception.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized && _controller != null;

  Future<void> initialize() async {
    final status = await Permission.camera.request();
    if (status.isPermanentlyDenied) {
      throw const PermissionException(
        'Camera permission is permanently denied. Please grant camera access in Android system settings.',
      );
    }
    if (!status.isGranted) {
      throw const PermissionException('Camera permission is required.');
    }

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw const CameraExceptionWrapper('No cameras available on this device.');
      }

      final backCamera = _cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      if (e is AppException) rethrow;
      throw CameraExceptionWrapper('Failed to initialize camera: ${e.toString()}');
    }
  }

  Future<XFile> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      await initialize();
    }

    if (_controller!.value.isTakingPicture) {
      throw const CameraExceptionWrapper('Camera is busy capturing an image.');
    }

    try {
      return await _controller!.takePicture();
    } catch (e) {
      throw CameraExceptionWrapper('Failed to capture frame: ${e.toString()}');
    }
  }

  Future<Uint8List> captureImageBytes() async {
    final xFile = await takePicture();
    return await xFile.readAsBytes();
  }

  Future<void> dispose() async {
    _isInitialized = false;
    await _controller?.dispose();
    _controller = null;
  }
}

final cameraServiceProvider = Provider<CameraService>((ref) {
  final service = CameraService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

