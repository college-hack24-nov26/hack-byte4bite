import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/assistant/presentation/screens/assistant_screen.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/navigation/presentation/screens/navigation_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/text_recognition/presentation/screens/text_recognition_screen.dart';
import '../../features/vision/presentation/screens/vision_screen.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.vision,
        builder: (context, state) => const VisionScreen(),
      ),
      GoRoute(
        path: AppRoutes.ocr,
        builder: (context, state) => const TextRecognitionScreen(),
      ),
      GoRoute(
        path: AppRoutes.assistant,
        builder: (context, state) => const AssistantScreen(),
      ),
      GoRoute(
        path: AppRoutes.navigation,
        builder: (context, state) => const NavigationScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Navigation Error'),
      ),
      body: Center(
        child: Text(
          'Page not found: ${state.uri}',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    ),
  );
});

