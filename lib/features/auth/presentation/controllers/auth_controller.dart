import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/accessibility/haptic_service.dart';
import '../../../../core/services/tts_service.dart';
import '../../domain/entities/app_user.dart';
import '../../data/repositories/auth_repository_impl.dart';

class AuthState {
  final AppUser? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    AppUser? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    final repository = ref.watch(authRepositoryProvider);
    repository.authStateChanges.listen((user) {
      state = state.copyWith(user: user, isLoading: false);
    });
    return const AuthState();
  }

  Future<bool> signInWithEmail(String email, String password) async {
    final repository = ref.read(authRepositoryProvider);
    final tts = ref.read(ttsServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    state = state.copyWith(isLoading: true, errorMessage: null);
    await haptic.buttonPress();
    await tts.speak('Signing in.');

    try {
      final user = await repository.signInWithEmail(email, password);
      state = state.copyWith(user: user, isLoading: false);
      await haptic.success();
      await tts.speak('Signed in successfully.');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      await haptic.error();
      await tts.speak('Sign in failed: ${e.toString()}');
      return false;
    }
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    final repository = ref.read(authRepositoryProvider);
    final tts = ref.read(ttsServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    state = state.copyWith(isLoading: true, errorMessage: null);
    await haptic.buttonPress();
    await tts.speak('Creating account.');

    try {
      final user = await repository.signUpWithEmail(email, password);
      state = state.copyWith(user: user, isLoading: false);
      await haptic.success();
      await tts.speak('Account created successfully.');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      await haptic.error();
      await tts.speak('Sign up failed: ${e.toString()}');
      return false;
    }
  }

  Future<bool> signInAnonymously() async {
    final repository = ref.read(authRepositoryProvider);
    final tts = ref.read(ttsServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    state = state.copyWith(isLoading: true, errorMessage: null);
    await haptic.buttonPress();
    await tts.speak('Continuing as guest.');

    try {
      final user = await repository.signInAnonymously();
      state = state.copyWith(user: user, isLoading: false);
      await haptic.success();
      await tts.speak('Guest session started.');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      await haptic.error();
      await tts.speak('Guest sign in failed: ${e.toString()}');
      return false;
    }
  }

  Future<void> signOut() async {
    final repository = ref.read(authRepositoryProvider);
    final tts = ref.read(ttsServiceProvider);
    final haptic = ref.read(hapticServiceProvider);

    await haptic.buttonPress();
    await repository.signOut();
    state = const AuthState();
    await tts.speak('Signed out.');
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
