import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionmate/core/constants/app_constants.dart';
import 'package:visionmate/core/theme/app_colors.dart';
import 'package:visionmate/shared/widgets/accessible_button.dart';
import 'package:visionmate/shared/widgets/accessible_header.dart';
import 'package:visionmate/features/navigation/presentation/controllers/navigation_controller.dart';

class NavigationScreen extends ConsumerWidget {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(navigationControllerProvider);
    final controller = ref.read(navigationControllerProvider.notifier);

    return Scaffold(
      appBar: AccessibleHeader(
        title: 'Navigation Guidance',
        onRepeat: state.currentPoint != null ? () => controller.repeatLocation() : null,
        onStop: () => controller.stopSpeaking(),
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
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                    border: Border.all(color: AppColors.surfaceBorder, width: 1.2),
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surfaceElevated,
                              border: Border.all(
                                color: state.isTracking
                                    ? AppColors.amberFocus
                                    : AppColors.surfaceBorder,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              state.isTracking ? Icons.explore_rounded : Icons.near_me_rounded,
                              size: 50,
                              color: state.isTracking ? AppColors.amberFocus : AppColors.warmWhite,
                            ),
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
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.surfaceBorder),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    state.currentPoint!.formatCoordinates(),
                                    style: const TextStyle(
                                      color: AppColors.amberFocus,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Facing: ${state.currentPoint!.formatHeading()}',
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
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
                label: 'Get Current Location',
                icon: Icons.gps_fixed_rounded,
                onPressed: () => controller.updateCurrentLocation(),
              ),
              const SizedBox(height: 12),
              AccessibleButton(
                label: state.isTracking ? 'Stop Live Tracking' : 'Start Live Tracking',
                icon: state.isTracking ? Icons.stop_rounded : Icons.play_arrow_rounded,
                isSecondary: true,
                onPressed: () => controller.toggleLiveTracking(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
