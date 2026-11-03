import 'package:visionmate/shared/models/user_profile.dart';

abstract class AuthRepository {
  Stream<UserProfile?> get authStateChanges;
  UserProfile? get currentUser;
  Future<UserProfile> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<UserProfile> registerWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<void> signOut();
  Future<void> resetPassword(String email);
}

