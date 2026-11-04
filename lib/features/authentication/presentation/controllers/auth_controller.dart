import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionmate/core/errors/error_handler.dart';
import 'package:visionmate/services/speech/tts_service.dart';
import 'package:visionmate/shared/models/user_profile.dart';
import '../../data/repositories/auth_repository_impl.dart';

class AuthState {
  final bool isLoading;
  final UserProfile? user;
  final String? errorMessage;
  final bool isSignUp;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
    this.isSignUp = false,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isLoading,
    UserProfile? user,
    String? errorMessage,
    bool? isSignUp,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage,
      isSignUp: isSignUp ?? this.isSignUp,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    final repo = ref.read(authRepositoryProvider);
    return AuthState(user: repo.currentUser);
  }

  void toggleMode() {
    state = state.copyWith(isSignUp: !state.isSignUp, errorMessage: null);
  }

  Future<bool> authenticate({
    required String email,
    required String password,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    final tts = ref.read(ttsServiceProvider);

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final user = state.isSignUp
          ? await repo.registerWithEmailAndPassword(
              email: email,
              password: password,
            )
          : await repo.signInWithEmailAndPassword(
              email: email,
              password: password,
            );

      state = state.copyWith(isLoading: false, user: user);
      await tts.speak('Signed in successfully as ${user.displayName ?? "User"}.');
      return true;
    } catch (e) {
      final errorMsg = ErrorHandler.getUserMessage(e);
      state = state.copyWith(isLoading: false, errorMessage: errorMsg);
      await tts.speak(errorMsg);
      return false;
    }
  }

  Future<void> signOut() async {
    final repo = ref.read(authRepositoryProvider);
    final tts = ref.read(ttsServiceProvider);
    await repo.signOut();
    state = const AuthState();
    await tts.speak('Signed out.');
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});

