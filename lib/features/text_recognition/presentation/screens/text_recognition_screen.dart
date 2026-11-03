import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/camera_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/accessible_button.dart';
import '../controllers/text_recognition_controller.dart';

class TextRecognitionScreen extends ConsumerStatefulWidget {
  const TextRecognitionScreen({super.key});

  @override
  ConsumerState<TextRecognitionScreen> createState() =>
      _TextRecognitionScreenState();
}

class _TextRecognitionScreenState extends ConsumerState<TextRecognitionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final cameraService = ref.read(cameraServiceProvider);
      if (!cameraService.isInitialized) {
        try {
          await cameraService.initialize();
        } catch (_) {}
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ocrState = ref.watch(textRecognitionControllerProvider);
    final controller = ref.read(textRecognitionControllerProvider.notifier);
    final cameraService = ref.watch(cameraServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Read Text (OCR)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded),
            tooltip: 'Read recognized text again',
            onPressed: ocrState.result == null
                ? null
                : () => controller.repeatText(),
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
                flex: 2,
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
                      else
                        const Center(
                          child: Icon(
                            Icons.document_scanner_rounded,
                            size: 56,
                            color: AppColors.highContrastFocus,
                          ),
                        ),
                      if (ocrState.isScanning)
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
                                  'Reading document...',
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
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.navyBorder,
                      width: 2,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.text_fields_rounded,
                              color: AppColors.highContrastFocus,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Document Text',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColors.warmWhite,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Semantics(
                          liveRegion: true,
                          label: ocrState.displayedText,
                          child: SelectableText(
                            ocrState.displayedText,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppColors.textLightPrimary,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AccessibleButton(
                label: ocrState.isScanning ? 'Scanning...' : 'Scan Document',
                icon: Icons.scanner_rounded,
                isLoading: ocrState.isScanning,
                semanticHint: 'Double tap to capture text from paper, sign, or label and read aloud',
                onPressed: ocrState.isScanning
                    ? null
                    : () => controller.scanDocument(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
