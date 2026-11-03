import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/camera_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/accessible_button.dart';
import '../controllers/vision_controller.dart';

class VisionScreen extends ConsumerWidget {
  const VisionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final visionState = ref.watch(visionControllerProvider);
    final controller = ref.read(visionControllerProvider.notifier);
    final cameraService = ref.watch(cameraServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Surroundings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded),
            tooltip: 'Repeat scene description',
            onPressed: visionState.lastResult == null
                ? null
                : () => controller.repeatDescription(),
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
                flex: 3,
                child: Container(
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
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (cameraService.isInitialized &&
                          cameraService.controller != null)
                        CameraPreview(cameraService.controller!)
                      else if (visionState.isInitializingCamera)
                        const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.highContrastFocus,
                          ),
                        )
                      else
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.camera_alt_outlined,
                                size: 56,
                                color: AppColors.highContrastFocus,
                              ),
                              const SizedBox(height: 16),
                              if (visionState.errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    visionState.errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppColors.error,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              AccessibleButton(
                                label: 'Retry Camera Access',
                                icon: Icons.refresh_rounded,
                                isSecondary: true,
                                onPressed: () => controller.initCamera(),
                              ),
                            ],
                          ),
                        ),
                      if (visionState.isAnalyzing)
                        Container(
                          color: AppColors.navyDark.withValues(alpha: 0.75),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  strokeWidth: 4,
                                  color: AppColors.highContrastFocus,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Analyzing with Gemini 2.5...',
                                  style: TextStyle(
                                    color: AppColors.warmWhite,
                                    fontSize: 18,
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
              const SizedBox(height: 16),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.navyBorder,
                      width: 2,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Semantics(
                      liveRegion: true,
                      label: visionState.statusMessage,
                      child: Text(
                        visionState.statusMessage,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.warmWhite,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AccessibleButton(
                label: visionState.isAnalyzing ? 'Analyzing...' : 'Describe Scene',
                icon: Icons.camera_rounded,
                isLoading: visionState.isAnalyzing,
                semanticHint: 'Double tap to capture photo and speak AI scene description',
                onPressed: visionState.isAnalyzing
                    ? null
                    : () => controller.captureAndAnalyze(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
