import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/accessible_button.dart';
import '../controllers/navigation_controller.dart';

class NavigationScreen extends ConsumerWidget {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(navigationControllerProvider);
    final controller = ref.read(navigationControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation Guidance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded),
            tooltip: 'Repeat location announcement',
            onPressed: state.currentPoint == null
                ? null
                : () => controller.repeatLocation(),
          ),
          IconButton(
            icon: const Icon(Icons.stop_circle_rounded),
            tooltip: 'Stop speaking',
            onPressed: () => controller.stopSpeaking(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  decoration: BoxDecoration(
                    color: AppColors.navyMedium,
                    borderRadius: BorderRadius.circular(
                      AppConstants.defaultBorderRadius,
                    ),
                    border: Border.all(
                      color: AppColors.highContrastFocus,
                      width: 2.5,
                    ),
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            state.isTracking
                                ? Icons.explore_rounded
                                : Icons.my_location_rounded,
                            size: 64,
                            color: AppColors.highContrastFocus,
                          ),
                          const SizedBox(height: 24),
                          Semantics(
                            liveRegion: true,
                            label: state.statusText,
                            child: Text(
                              state.statusText,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: AppColors.warmWhite,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          if (state.currentPoint != null) ...[
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.cardDark,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.navyBorder,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    state.currentPoint!.formatCoordinates(),
                                    style: const TextStyle(
                                      color: AppColors.highContrastFocus,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Accuracy: ±${state.currentPoint!.accuracy.toStringAsFixed(1)}m | Altitude: ${state.currentPoint!.altitude.toStringAsFixed(0)}m',
                                    style: const TextStyle(
                                      color: AppColors.textLightSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AccessibleButton(
                label: state.isLoading ? 'Acquiring GPS...' : 'Update Location',
                icon: Icons.gps_fixed_rounded,
                isLoading: state.isLoading,
                semanticHint: 'Double tap to obtain current GPS fix and speak coordinates',
                onPressed: state.isLoading
                    ? null
                    : () => controller.updateCurrentLocation(),
              ),
              const SizedBox(height: 12),
              AccessibleButton(
                label: state.isTracking
                    ? 'Stop Live Tracking'
                    : 'Start Continuous Tracking',
                icon: state.isTracking
                    ? Icons.pause_circle_outline_rounded
                    : Icons.play_circle_outline_rounded,
                isSecondary: true,
                onPressed: () => controller.toggleContinuousTracking(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
