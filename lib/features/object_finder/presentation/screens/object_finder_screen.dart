import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionmate/core/constants/app_constants.dart';
import 'package:visionmate/core/theme/app_colors.dart';
import 'package:visionmate/services/camera/camera_service.dart';
import 'package:visionmate/shared/widgets/accessible_button.dart';
import 'package:visionmate/shared/widgets/accessible_header.dart';
import 'package:visionmate/shared/widgets/camera_hud_overlay.dart';
import 'package:visionmate/features/object_finder/presentation/controllers/object_finder_controller.dart';

class ObjectFinderScreen extends ConsumerStatefulWidget {
  const ObjectFinderScreen({super.key});

  @override
  ConsumerState<ObjectFinderScreen> createState() => _ObjectFinderScreenState();
}

class _ObjectFinderScreenState extends ConsumerState<ObjectFinderScreen> {
  final _textController = TextEditingController();

  static const _commonPresets = [
    'Door',
    'Chair',
    'Keys',
    'Water bottle',
    'Table',
    'Crosswalk',
  ];

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
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final finderState = ref.watch(objectFinderControllerProvider);
    final controller = ref.read(objectFinderControllerProvider.notifier);
    final cameraService = ref.watch(cameraServiceProvider);

    return Scaffold(
      appBar: AccessibleHeader(
        title: 'Find an Object',
        onRepeat: finderState.lastResult != null ? () => controller.repeatResult() : null,
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
                            Icons.search_rounded,
                            size: 52,
                            color: AppColors.amberFocus,
                          ),
                        ),
                      CameraHudOverlay(
                        statusBadge: finderState.isSearching ? 'SEARCHING' : 'OBJECT RADAR',
                        isScanning: finderState.isSearching,
                      ),
                      if (finderState.isSearching)
                        Container(
                          color: AppColors.obsidian.withValues(alpha: 0.65),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(
                                  strokeWidth: 3.5,
                                  color: AppColors.amberFocus,
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'Locating ${finderState.currentTarget}...',
                                  style: const TextStyle(
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
              const SizedBox(height: 12),
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _commonPresets.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final preset = _commonPresets[index];
                    final isSelected = finderState.currentTarget.toLowerCase() == preset.toLowerCase();
                    return ChoiceChip(
                      label: Text(preset),
                      selected: isSelected,
                      onSelected: (_) => controller.setTarget(preset),
                      selectedColor: AppColors.amberFocus,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.obsidian : AppColors.warmWhite,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      backgroundColor: AppColors.surfaceDark,
                      side: BorderSide(
                        color: isSelected ? AppColors.amberFocus : AppColors.surfaceBorder,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
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
                              Icons.my_location_rounded,
                              size: 18,
                              color: AppColors.amberFocus,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Target: ${finderState.currentTarget}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColors.amberFocus,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Semantics(
                          liveRegion: true,
                          label: finderState.statusText,
                          child: Text(
                            finderState.statusText,
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
                label: 'Search for "${finderState.currentTarget}"',
                icon: Icons.search_rounded,
                isLoading: finderState.isSearching,
                onPressed: () => controller.search(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
