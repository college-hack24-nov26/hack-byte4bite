import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

abstract class PermissionService {
  Future<bool> requestCameraPermission();
  Future<bool> requestMicrophonePermission();
  Future<bool> requestLocationPermission();
  Future<bool> hasCameraPermission();
  Future<bool> hasMicrophonePermission();
  Future<bool> hasLocationPermission();
  Future<bool> openDeviceSettings();
}

class PermissionServiceImpl implements PermissionService {
  const PermissionServiceImpl();

  @override
  Future<bool> requestCameraPermission() async {
    final status = await ph.Permission.camera.request();
    return status.isGranted;
  }

  @override
  Future<bool> requestMicrophonePermission() async {
    final status = await ph.Permission.microphone.request();
    return status.isGranted;
  }

  @override
  Future<bool> requestLocationPermission() async {
    final status = await ph.Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  @override
  Future<bool> hasCameraPermission() async {
    final status = await ph.Permission.camera.status;
    return status.isGranted;
  }

  @override
  Future<bool> hasMicrophonePermission() async {
    final status = await ph.Permission.microphone.status;
    return status.isGranted;
  }

  @override
  Future<bool> hasLocationPermission() async {
    final status = await ph.Permission.locationWhenInUse.status;
    return status.isGranted;
  }

  @override
  Future<bool> openDeviceSettings() async {
    return await ph.openAppSettings();
  }
}

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return const PermissionServiceImpl();
});
