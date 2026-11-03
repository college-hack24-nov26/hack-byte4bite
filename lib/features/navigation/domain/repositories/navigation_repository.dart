import 'package:visionmate/shared/models/geo_point_model.dart';

abstract class NavigationRepository {
  Future<GeoPointModel> getCurrentLocation();
  Stream<GeoPointModel> watchLocation();
  double calculateDistanceTo(GeoPointModel from, GeoPointModel to);
  double calculateBearingTo(GeoPointModel from, GeoPointModel to);
}
