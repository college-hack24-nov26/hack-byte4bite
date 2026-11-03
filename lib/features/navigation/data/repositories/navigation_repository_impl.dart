import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionmate/services/location/location_service.dart';
import 'package:visionmate/shared/models/geo_point_model.dart';
import '../../domain/repositories/navigation_repository.dart';

class NavigationRepositoryImpl implements NavigationRepository {
  final LocationService _locationService;

  NavigationRepositoryImpl(this._locationService);

  @override
  Future<GeoPointModel> getCurrentLocation() async {
    return await _locationService.getCurrentLocation();
  }

  @override
  Stream<GeoPointModel> watchLocation() {
    return _locationService.locationStream;
  }

  @override
  double calculateDistanceTo(GeoPointModel from, GeoPointModel to) {
    return _locationService.calculateDistance(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }

  @override
  double calculateBearingTo(GeoPointModel from, GeoPointModel to) {
    return _locationService.calculateBearing(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }
}

final navigationRepositoryProvider = Provider<NavigationRepository>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  return NavigationRepositoryImpl(locationService);
});
