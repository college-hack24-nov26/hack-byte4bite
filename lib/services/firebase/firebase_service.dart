import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';

abstract class FirebaseService {
  Future<void> initialize();
  bool get isInitialized;
  FirebaseAuth get auth;
  FirebaseFirestore get firestore;
}

class FirebaseServiceImpl implements FirebaseService {
  bool _initialized = false;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _initialized = true;
    } catch (_) {
      _initialized = false;
    }
  }

  @override
  FirebaseAuth get auth => FirebaseAuth.instance;

  @override
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
}

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseServiceImpl();
});

