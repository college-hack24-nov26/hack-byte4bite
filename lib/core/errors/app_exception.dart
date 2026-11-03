class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(
    this.message, {
    this.code,
    this.originalError,
  });

  @override
  String toString() => message;
}

class AuthException extends AppException {
  const AuthException(
    super.message, {
    super.code,
    super.originalError,
  });
}

class AiServiceException extends AppException {
  const AiServiceException(
    super.message, {
    super.code,
    super.originalError,
  });
}

class CameraServiceException extends AppException {
  const CameraServiceException(
    super.message, {
    super.code,
    super.originalError,
  });
}

class LocationServiceException extends AppException {
  const LocationServiceException(
    super.message, {
    super.code,
    super.originalError,
  });
}

class SpeechServiceException extends AppException {
  const SpeechServiceException(
    super.message, {
    super.code,
    super.originalError,
  });
}

class PermissionException extends AppException {
  final String permissionName;

  const PermissionException(
    super.message, {
    required this.permissionName,
    super.code,
    super.originalError,
  });
}

class StorageException extends AppException {
  const StorageException(
    super.message, {
    super.code,
    super.originalError,
  });
}

class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.code,
    super.originalError,
  });
}
