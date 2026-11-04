import 'app_exception.dart';

class ErrorHandler {
  static String getUserMessage(Object error) {
    if (error is AppException) {
      return error.message;
    }

    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') ||
        errorString.contains('socket') ||
        errorString.contains('connection refused') ||
        errorString.contains('failed host lookup')) {
      return 'Network connection unavailable. Please check your internet connection.';
    }

    if (errorString.contains('permission_denied') ||
        errorString.contains('permission denied')) {
      return 'Permission was denied. Please allow access in device settings.';
    }

    if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    if (errorString.contains('camera')) {
      return 'Camera access is currently unavailable.';
    }

    if (errorString.contains('location')) {
      return 'Location services are disabled or unavailable.';
    }

    return 'Something went wrong. Please try again.';
  }
}
