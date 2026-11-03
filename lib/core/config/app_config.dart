class AppConfig {
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  static const String geminiModel = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-2.5-flash',
  );

  static const String backendBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'https://visionmate-api.local',
  );

  static const bool enableHaptics = bool.fromEnvironment(
    'ENABLE_HAPTICS',
    defaultValue: true,
  );

  static const double defaultTtsSpeechRate = 0.5;
  static const double defaultTtsPitch = 1.0;
  static const double defaultTtsVolume = 1.0;
}
