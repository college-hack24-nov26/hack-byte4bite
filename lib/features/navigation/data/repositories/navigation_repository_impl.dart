import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/location_service.dart';
import '../../domain/entities/location_point.dart';
import '../../domain/repositories/navigation_repository.dart';
import '../datasources/location_datasource.dart';

class NavigationRepositoryImpl implements NavigationRepository {
  final LocationDataSource _dataSource;

  NavigationRepositoryImpl(this._dataSource);

  @override
  Future<LocationPoint> getCurrentLocation() =>
      _dataSource.getCurrentLocation();

  @override
  Stream<LocationPoint> streamLocation() => _dataSource.streamLocation();
}

final locationDataSourceProvider = Provider<LocationDataSource>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  return LocationDataSource(locationService);
});

final navigationRepositoryProvider = Provider<NavigationRepository>((ref) {
  final dataSource = ref.watch(locationDataSourceProvider);
  return NavigationRepositoryImpl(dataSource);
});

