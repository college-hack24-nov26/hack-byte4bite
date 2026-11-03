import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visionmate/features/authentication/presentation/screens/auth_screen.dart';
import 'package:visionmate/features/emergency/presentation/screens/emergency_screen.dart';
import 'package:visionmate/features/home/presentation/screens/home_screen.dart';
import 'package:visionmate/features/navigation/presentation/screens/navigation_screen.dart';
import 'package:visionmate/features/object_finder/presentation/screens/object_finder_screen.dart';
import 'package:visionmate/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:visionmate/features/scene_understanding/presentation/screens/scene_understanding_screen.dart';
import 'package:visionmate/features/settings/presentation/screens/settings_screen.dart';
import 'package:visionmate/features/smart_reader/presentation/screens/smart_reader_screen.dart';
import 'package:visionmate/features/voice_assistant/presentation/screens/voice_assistant_screen.dart';
import 'package:visionmate/shared/widgets/state_views.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.sceneUnderstanding,
        builder: (context, state) => const SceneUnderstandingScreen(),
      ),
      GoRoute(
        path: AppRoutes.smartReader,
        builder: (context, state) => const SmartReaderScreen(),
      ),
      GoRoute(
        path: AppRoutes.objectFinder,
        builder: (context, state) => const ObjectFinderScreen(),
      ),
      GoRoute(
        path: AppRoutes.voiceAssistant,
        builder: (context, state) => const VoiceAssistantScreen(),
      ),
      GoRoute(
        path: AppRoutes.navigation,
        builder: (context, state) => const NavigationScreen(),
      ),
      GoRoute(
        path: AppRoutes.emergency,
        builder: (context, state) => const EmergencyScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: AccessibleErrorView(
        message: 'The requested screen could not be located.',
        retryLabel: 'Go to Home',
        onRetry: () => context.go(AppRoutes.home),
      ),
    ),
  );
});

