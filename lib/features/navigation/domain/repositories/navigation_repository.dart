import '../entities/location_point.dart';

abstract class NavigationRepository {
  Future<LocationPoint> getCurrentLocation();
  Stream<LocationPoint> streamLocation();
}

