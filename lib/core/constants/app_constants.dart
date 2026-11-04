class AppConstants {
  static const String appName = 'VisionMate';
  static const String appVersion = '3.0.0';
  static const String appTagline = 'Smart Assistive Vision';

  static const double minTouchTargetSize = 56.0;
  static const double defaultBorderRadius = 20.0;
  static const double defaultPadding = 20.0;
  static const double cardElevation = 0.0;

  static const Duration splashDuration = Duration(milliseconds: 1800);
  static const Duration snackBarDuration = Duration(seconds: 4);
  static const Duration cameraCaptureTimeout = Duration(seconds: 15);
  static const Duration locationTimeout = Duration(seconds: 10);
  static const Duration networkTimeout = Duration(seconds: 25);

  static const String defaultGeminiModel = 'gemini-2.0-flash';
  static const String secureStorageApiKeyKey = 'visionmate_gemini_api_key';
  static const String secureStorageEmergencyContactKey = 'visionmate_emergency_contacts';
}
