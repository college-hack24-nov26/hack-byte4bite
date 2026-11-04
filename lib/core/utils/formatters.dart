class Formatters {
  static String formatDistance(double meters) {
    if (meters < 1.0) {
      return 'Less than a meter';
    }
    if (meters < 1000) {
      final rounded = meters.round();
      return '$rounded ${rounded == 1 ? "meter" : "meters"}';
    }
    final kilometers = meters / 1000.0;
    return '${kilometers.toStringAsFixed(1)} kilometers';
  }

  static String formatCoordinates(double latitude, double longitude) {
    final latDir = latitude >= 0 ? 'N' : 'S';
    final lngDir = longitude >= 0 ? 'E' : 'W';
    return '${latitude.abs().toStringAsFixed(4)}° $latDir, ${longitude.abs().toStringAsFixed(4)}° $lngDir';
  }

  static String formatCardinalDirection(double headingDegrees) {
    final normalized = (headingDegrees % 360 + 360) % 360;
    if (normalized >= 337.5 || normalized < 22.5) return 'North';
    if (normalized >= 22.5 && normalized < 67.5) return 'Northeast';
    if (normalized >= 67.5 && normalized < 112.5) return 'East';
    if (normalized >= 112.5 && normalized < 157.5) return 'Southeast';
    if (normalized >= 157.5 && normalized < 202.5) return 'South';
    if (normalized >= 202.5 && normalized < 247.5) return 'Southwest';
    if (normalized >= 247.5 && normalized < 292.5) return 'West';
    return 'Northwest';
  }
}

