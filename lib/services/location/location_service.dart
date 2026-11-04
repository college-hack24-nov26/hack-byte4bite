import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:visionmate/core/errors/app_exception.dart';
import 'package:visionmate/shared/models/geo_point_model.dart';

abstract class LocationService {
  Future<GeoPointModel> getCurrentLocation();
  Stream<GeoPointModel> get locationStream;
  double calculateDistance(double startLat, double startLng, double endLat, double endLng);
  double calculateBearing(double startLat, double startLng, double endLat, double endLng);
}

class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<GeoPointModel> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceException('Location services are disabled on this device.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationServiceException('Location permission was denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationServiceException(
        'Location permissions are permanently denied. Please enable them in app settings.',
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return GeoPointModel(
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: position.altitude,
        heading: position.heading,
        accuracy: position.accuracy,
        timestamp: position.timestamp,
      );
    } catch (e) {
      throw LocationServiceException('Failed to get current location: ${e.toString()}');
    }
  }

  @override
  Stream<GeoPointModel> get locationStream {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 3,
      ),
    ).map(
      (position) => GeoPointModel(
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: position.altitude,
        heading: position.heading,
        accuracy: position.accuracy,
        timestamp: position.timestamp,
      ),
    );
  }

  @override
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  @override
  double calculateBearing(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.bearingBetween(startLat, startLng, endLat, endLng);
  }
}

final locationServiceProvider = Provider<LocationService>((ref) {
  return const GeolocatorLocationService();
});

