import 'package:visionmate/core/utils/formatters.dart';

class GeoPointModel {
  final double latitude;
  final double longitude;
  final double altitude;
  final double heading;
  final double accuracy;
  final DateTime timestamp;

  const GeoPointModel({
    required this.latitude,
    required this.longitude,
    this.altitude = 0.0,
    this.heading = 0.0,
    this.accuracy = 0.0,
    required this.timestamp,
  });

  String formatCoordinates() {
    return Formatters.formatCoordinates(latitude, longitude);
  }

  String formatHeading() {
    return Formatters.formatCardinalDirection(heading);
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'heading': heading,
      'accuracy': accuracy,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory GeoPointModel.fromJson(Map<String, dynamic> json) {
    return GeoPointModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble() ?? 0.0,
      heading: (json['heading'] as num?)?.toDouble() ?? 0.0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

