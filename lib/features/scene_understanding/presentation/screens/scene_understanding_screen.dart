import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionmate/core/constants/app_constants.dart';
import 'package:visionmate/core/constants/semantic_labels.dart';
import 'package:visionmate/core/theme/app_colors.dart';
import 'package:visionmate/services/camera/camera_service.dart';
import 'package:visionmate/shared/widgets/accessible_button.dart';
import 'package:visionmate/shared/widgets/accessible_header.dart';
import 'package:visionmate/shared/widgets/camera_hud_overlay.dart';
import 'package:visionmate/features/scene_understanding/presentation/controllers/scene_controller.dart';

class SceneUnderstandingScreen extends ConsumerWidget {
  const SceneUnderstandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sceneState = ref.watch(sceneControllerProvider);
    final controller = ref.read(sceneControllerProvider.notifier);
    final cameraService = ref.watch(cameraServiceProvider);

    return Scaffold(
      appBar: AccessibleHeader(
        title: 'Explore Surroundings',
        onRepeat: sceneState.lastDescription != null ? () => controller.repeatDescription() : null,
        onStop: () => controller.stopSpeaking(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                    border: Border.all(
                      color: AppColors.surfaceBorder,
                      width: 1.2,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (cameraService.isInitialized && cameraService.controller != null)
                        CameraPreview(cameraService.controller!)
                      else if (sceneState.isInitializingCamera)
                        const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.amberFocus,
                          ),
                        )
                      else
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.camera_alt_outlined,
                                size: 52,
                                color: AppColors.amberFocus,
                              ),
                              const SizedBox(height: 14),
                              AccessibleButton(
                                label: 'Start Camera',
                                icon: Icons.refresh_rounded,
                                isSecondary: true,
                                onPressed: () => controller.initCamera(),
                              ),
                            ],
                          ),
                        ),
                      CameraHudOverlay(
                        statusBadge: sceneState.isAnalyzing ? 'ANALYZING' : 'VIEWFINDER',
                        isScanning: sceneState.isAnalyzing,
                      ),
                      if (sceneState.isAnalyzing)
                        Container(
                          color: AppColors.obsidian.withValues(alpha: 0.65),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  strokeWidth: 3.5,
                                  color: AppColors.amberFocus,
                                ),
                                SizedBox(height: 14),
                                Text(
                                  'Scanning surroundings...',
                                  style: TextStyle(
                                    color: AppColors.warmWhite,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.visibility_outlined,
                              size: 18,
                              color: AppColors.amberFocus,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Scene Description',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColors.amberFocus,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Semantics(
                          liveRegion: true,
                          label: sceneState.statusText,
                          child: Text(
                            sceneState.statusText,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.45,
                              color: AppColors.warmWhite,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              AccessibleButton(
                label: 'Describe Scene Ahead',
                semanticHint: SemanticLabels.captureButton,
                icon: Icons.camera_rounded,
                isLoading: sceneState.isAnalyzing,
                onPressed: () => controller.captureAndAnalyze(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
