import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionmate/core/errors/app_exception.dart';

abstract class CameraService {
  Future<void> initialize();
  Future<Uint8List> captureImageBytes();
  Future<void> toggleTorch(bool enable);
  CameraController? get controller;
  bool get isInitialized;
  bool get isTorchOn;
  Future<void> dispose();
}

class DeviceCameraService implements CameraService {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isTorchOn = false;

  @override
  CameraController? get controller => _controller;

  @override
  bool get isInitialized => _isInitialized && _controller != null && _controller!.value.isInitialized;

  @override
  bool get isTorchOn => _isTorchOn;

  @override
  Future<void> initialize() async {
    if (isInitialized) return;

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw const CameraServiceException('No camera found on this device.');
      }

      final backCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
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
      if (e is CameraServiceException) rethrow;
      throw CameraServiceException('Failed to initialize camera: ${e.toString()}');
    }
  }

  @override
  Future<Uint8List> captureImageBytes() async {
    if (!isInitialized || _controller == null) {
      await initialize();
    }

    try {
      final xFile = await _controller!.takePicture();
      return await xFile.readAsBytes();
    } catch (e) {
      throw CameraServiceException('Failed to capture frame: ${e.toString()}');
    }
  }

  @override
  Future<void> toggleTorch(bool enable) async {
    if (!isInitialized || _controller == null) return;
    try {
      await _controller!.setFlashMode(enable ? FlashMode.torch : FlashMode.off);
      _isTorchOn = enable;
    } catch (e) {
      throw CameraServiceException('Failed to toggle flashlight: ${e.toString()}');
    }
  }

  @override
  Future<void> dispose() async {
    _isInitialized = false;
    _isTorchOn = false;
    await _controller?.dispose();
    _controller = null;
  }
}

final cameraServiceProvider = Provider<CameraService>((ref) {
  final service = DeviceCameraService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

