import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionmate/core/errors/app_exception.dart';
import 'package:visionmate/services/firebase/firebase_service.dart';
import 'package:visionmate/shared/models/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseService _firebaseService;
  UserProfile? _cachedUser;

  AuthRepositoryImpl(this._firebaseService);

  UserProfile _mapFirebaseUser(fb.User user) {
    return UserProfile(
      id: user.uid,
      email: user.email ?? 'guest@visionmate.local',
      displayName: user.displayName ?? 'VisionMate User',
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  @override
  Stream<UserProfile?> get authStateChanges {
    if (!_firebaseService.isInitialized) {
      return Stream.value(_cachedUser);
    }
    return _firebaseService.auth.authStateChanges().map((user) {
      if (user == null) {
        _cachedUser = null;
        return null;
      }
      _cachedUser = _mapFirebaseUser(user);
      return _cachedUser;
    });
  }

  @override
  UserProfile? get currentUser {
    if (_firebaseService.isInitialized) {
      final user = _firebaseService.auth.currentUser;
      return user != null ? _mapFirebaseUser(user) : _cachedUser;
    }
    return _cachedUser;
  }

  @override
  Future<UserProfile> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (_firebaseService.isInitialized) {
        final credential = await _firebaseService.auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );
        final user = credential.user;
        if (user == null) {
          throw const AuthException('Sign in failed: User not returned.');
        }
        _cachedUser = _mapFirebaseUser(user);
        return _cachedUser!;
      } else {
        _cachedUser = UserProfile(
          id: 'offline_user_${DateTime.now().millisecondsSinceEpoch}',
          email: email.trim(),
          displayName: email.split('@').first,
          createdAt: DateTime.now(),
        );
        return _cachedUser!;
      }
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Authentication failed', code: e.code);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserProfile> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (_firebaseService.isInitialized) {
        final credential =
            await _firebaseService.auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );
        final user = credential.user;
        if (user == null) {
          throw const AuthException('Registration failed: User not created.');
        }
        _cachedUser = _mapFirebaseUser(user);
        return _cachedUser!;
      } else {
        _cachedUser = UserProfile(
          id: 'offline_user_${DateTime.now().millisecondsSinceEpoch}',
          email: email.trim(),
          displayName: email.split('@').first,
          createdAt: DateTime.now(),
        );
        return _cachedUser!;
      }
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Registration failed', code: e.code);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      if (_firebaseService.isInitialized) {
        await _firebaseService.auth.signOut();
      }
      _cachedUser = null;
    } catch (e) {
      throw AuthException('Sign out failed: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      if (_firebaseService.isInitialized) {
        await _firebaseService.auth.sendPasswordResetEmail(email: email.trim());
      }
    } catch (e) {
      throw AuthException('Password reset failed: ${e.toString()}');
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return AuthRepositoryImpl(firebaseService);
});

