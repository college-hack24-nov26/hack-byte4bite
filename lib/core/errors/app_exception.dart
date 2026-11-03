class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => message;
}

class PermissionException extends AppException {
  const PermissionException(super.message, [super.code]);
}

class CameraExceptionWrapper extends AppException {
  const CameraExceptionWrapper(super.message, [super.code]);
}

class AiServiceException extends AppException {
  const AiServiceException(super.message, [super.code]);
}

class OcrException extends AppException {
  const OcrException(super.message, [super.code]);
}

class LocationException extends AppException {
  const LocationException(super.message, [super.code]);
}

class AuthException extends AppException {
  const AuthException(super.message, [super.code]);
}

