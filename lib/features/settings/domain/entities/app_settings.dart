class AppSettings {
  final double speechRate;
  final double speechPitch;
  final bool highContrast;
  final bool hapticsEnabled;

  const AppSettings({
    this.speechRate = 0.5,
    this.speechPitch = 1.0,
    this.highContrast = true,
    this.hapticsEnabled = true,
  });

  AppSettings copyWith({
    double? speechRate,
    double? speechPitch,
    bool? highContrast,
    bool? hapticsEnabled,
  }) {
    return AppSettings(
      speechRate: speechRate ?? this.speechRate,
      speechPitch: speechPitch ?? this.speechPitch,
      highContrast: highContrast ?? this.highContrast,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }
}

