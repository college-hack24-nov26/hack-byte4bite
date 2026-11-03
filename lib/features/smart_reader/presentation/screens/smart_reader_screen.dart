import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionmate/core/constants/app_constants.dart';
import 'package:visionmate/core/theme/app_colors.dart';
import 'package:visionmate/services/camera/camera_service.dart';
import 'package:visionmate/shared/widgets/accessible_button.dart';
import 'package:visionmate/shared/widgets/accessible_header.dart';
import 'package:visionmate/shared/widgets/camera_hud_overlay.dart';
import 'package:visionmate/features/smart_reader/presentation/controllers/reader_controller.dart';

class SmartReaderScreen extends ConsumerStatefulWidget {
  const SmartReaderScreen({super.key});

  @override
  ConsumerState<SmartReaderScreen> createState() => _SmartReaderScreenState();
}

class _SmartReaderScreenState extends ConsumerState<SmartReaderScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final camera = ref.read(cameraServiceProvider);
      if (!camera.isInitialized) {
        try {
          await camera.initialize();
        } catch (_) {}
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final readerState = ref.watch(readerControllerProvider);
    final controller = ref.read(readerControllerProvider.notifier);
    final cameraService = ref.watch(cameraServiceProvider);

    return Scaffold(
      appBar: AccessibleHeader(
        title: 'Smart Text Reader',
        onRepeat: readerState.document != null ? () => controller.repeatText() : null,
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
                    border: Border.all(color: AppColors.surfaceBorder, width: 1.2),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (cameraService.isInitialized && cameraService.controller != null)
                        CameraPreview(cameraService.controller!)
                      else
                        const Center(
                          child: Icon(
                            Icons.document_scanner_rounded,
                            size: 52,
                            color: AppColors.amberFocus,
                          ),
                        ),
                      CameraHudOverlay(
                        statusBadge: readerState.isScanning ? 'READING' : 'TEXT OCR',
                        isScanning: readerState.isScanning,
                      ),
                      if (readerState.isScanning)
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
                                  'Reading text...',
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
                              Icons.text_fields_rounded,
                              size: 18,
                              color: AppColors.amberFocus,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Recognized Content',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColors.amberFocus,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Semantics(
                          liveRegion: true,
                          label: readerState.statusText,
                          child: Text(
                            readerState.statusText,
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
                label: 'Read Text Ahead',
                icon: Icons.document_scanner_rounded,
                isLoading: readerState.isScanning,
                onPressed: () => controller.scanAndRead(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
