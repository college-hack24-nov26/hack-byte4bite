import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/app_user.dart';

class AuthRemoteDataSource {
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<AppUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((fbUser) {
      if (fbUser == null) return null;
      return AppUser(
        id: fbUser.uid,
        email: fbUser.email,
        isAnonymous: fbUser.isAnonymous,
      );
    });
  }

  Future<AppUser?> getCurrentUser() async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(fbUser.uid).get();
      if (doc.exists && doc.data() != null) {
        return AppUser.fromMap(doc.data()!, fbUser.uid);
      }
    } catch (_) {}

    return AppUser(
      id: fbUser.uid,
      email: fbUser.email,
      isAnonymous: fbUser.isAnonymous,
    );
  }

  Future<AppUser> signInWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final fbUser = credential.user;
      if (fbUser == null) {
        throw const AuthException('User record not found after sign in.');
      }
      return AppUser(
        id: fbUser.uid,
        email: fbUser.email,
        isAnonymous: fbUser.isAnonymous,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Authentication failed.', e.code);
    } catch (e) {
      throw AuthException('Sign in error: ${e.toString()}');
    }
  }

  Future<AppUser> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final fbUser = credential.user;
      if (fbUser == null) {
        throw const AuthException('Failed to create user record.');
      }
      final user = AppUser(
        id: fbUser.uid,
        email: fbUser.email,
        isAnonymous: fbUser.isAnonymous,
      );
      await _firestore.collection('users').doc(fbUser.uid).set(
            user.toMap(),
            SetOptions(merge: true),
          );
      return user;
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Registration failed.', e.code);
    } catch (e) {
      throw AuthException('Sign up error: ${e.toString()}');
    }
  }

  Future<AppUser> signInAnonymously() async {
    try {
      final credential = await _firebaseAuth.signInAnonymously();
      final fbUser = credential.user;
      if (fbUser == null) {
        throw const AuthException('Anonymous session creation failed.');
      }
      final user = AppUser(
        id: fbUser.uid,
        email: null,
        isAnonymous: true,
      );
      try {
        await _firestore.collection('users').doc(fbUser.uid).set(
              user.toMap(),
              SetOptions(merge: true),
            );
      } catch (_) {}
      return user;
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Guest sign in failed.', e.code);
    } catch (e) {
      throw AuthException('Guest session error: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('Sign out failed: ${e.toString()}');
    }
  }

  Future<void> saveUserPreferences({
    required double speechRate,
    required bool hapticsEnabled,
  }) async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) return;

    try {
      await _firestore.collection('users').doc(fbUser.uid).set(
        {
          'speechRate': speechRate,
          'hapticsEnabled': hapticsEnabled,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {}
  }
}

