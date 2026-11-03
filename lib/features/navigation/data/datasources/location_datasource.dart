import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/location_service.dart';
import '../../domain/entities/location_point.dart';

class LocationDataSource {
  final LocationService _locationService;

  LocationDataSource(this._locationService);

  Future<LocationPoint> getCurrentLocation() async {
    final position = await _locationService.getCurrentPosition();
    if (position == null) {
      throw const LocationException(
        'Unable to obtain GPS fix. Please ensure location services are turned on and permissions are granted.',
      );
    }

    return LocationPoint(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      altitude: position.altitude,
      speed: position.speed,
      heading: position.heading,
      timestamp: position.timestamp,
    );
  }

  Stream<LocationPoint> streamLocation() {
    return _locationService.getPositionStream().map((pos) => LocationPoint(
          latitude: pos.latitude,
          longitude: pos.longitude,
          accuracy: pos.accuracy,
          altitude: pos.altitude,
          speed: pos.speed,
          heading: pos.heading,
          timestamp: pos.timestamp,
        ));
  }
}

