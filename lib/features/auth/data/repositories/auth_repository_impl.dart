import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Stream<AppUser?> get authStateChanges => _remoteDataSource.authStateChanges;

  @override
  Future<AppUser?> getCurrentUser() => _remoteDataSource.getCurrentUser();

  @override
  Future<AppUser> signInWithEmail(String email, String password) =>
      _remoteDataSource.signInWithEmail(email, password);

  @override
  Future<AppUser> signUpWithEmail(String email, String password) =>
      _remoteDataSource.signUpWithEmail(email, password);

  @override
  Future<AppUser> signInAnonymously() => _remoteDataSource.signInAnonymously();

  @override
  Future<void> signOut() => _remoteDataSource.signOut();

  @override
  Future<void> saveUserPreferences({
    required double speechRate,
    required bool hapticsEnabled,
  }) =>
      _remoteDataSource.saveUserPreferences(
        speechRate: speechRate,
        hapticsEnabled: hapticsEnabled,
      );
}

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource);
});

