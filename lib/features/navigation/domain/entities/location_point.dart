class LocationPoint {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double altitude;
  final double speed;
  final double heading;
  final DateTime timestamp;

  const LocationPoint({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.altitude,
    required this.speed,
    required this.heading,
    required this.timestamp,
  });

  String formatCoordinates() {
    return 'Latitude: ${latitude.toStringAsFixed(5)}, Longitude: ${longitude.toStringAsFixed(5)}';
  }

  String formatSpokenSummary() {
    final latDir = latitude >= 0 ? 'North' : 'South';
    final lonDir = longitude >= 0 ? 'East' : 'West';
    return 'Your coordinates are ${latitude.abs().toStringAsFixed(4)} degrees $latDir, and ${longitude.abs().toStringAsFixed(4)} degrees $lonDir, accurate to within ${accuracy.toStringAsFixed(0)} meters.';
  }
}

