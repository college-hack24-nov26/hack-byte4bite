import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionmate/core/constants/app_constants.dart';
import 'package:visionmate/core/theme/app_colors.dart';
import 'package:visionmate/services/camera/camera_service.dart';
import 'package:visionmate/shared/widgets/accessible_button.dart';
import 'package:visionmate/shared/widgets/accessible_header.dart';
import 'package:visionmate/features/object_finder/presentation/controllers/object_finder_controller.dart';

class ObjectFinderScreen extends ConsumerStatefulWidget {
  const ObjectFinderScreen({super.key});

  @override
  ConsumerState<ObjectFinderScreen> createState() => _ObjectFinderScreenState();
}

class _ObjectFinderScreenState extends ConsumerState<ObjectFinderScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _radarAnimController;
  final _manualInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _radarAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

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
    _radarAnimController.dispose();
    _manualInputController.dispose();
    super.dispose();
  }

  void _showManualInputDialog() {
    final controller = ref.read(objectFinderControllerProvider.notifier);
    final finderState = ref.read(objectFinderControllerProvider);
    _manualInputController.text = finderState.currentTarget;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            side: const BorderSide(color: AppColors.surfaceBorder),
          ),
          title: const Text(
            'Type Target Object',
            style: TextStyle(
              color: AppColors.warmWhite,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: TextField(
            controller: _manualInputController,
            autofocus: true,
            style: const TextStyle(color: AppColors.warmWhite),
            decoration: InputDecoration(
              hintText: 'e.g. Smartphone, Keys, Water bottle',
              hintStyle: TextStyle(color: AppColors.warmWhite.withValues(alpha: 0.5)),
              filled: true,
              fillColor: AppColors.obsidian,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.surfaceBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.amberFocus, width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel', style: TextStyle(color: AppColors.warmWhite)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.amberFocus,
                foregroundColor: AppColors.obsidian,
              ),
              onPressed: () {
                final text = _manualInputController.text.trim();
                if (text.isNotEmpty) {
                  controller.setTarget(text);
                }
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Set Target', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final finderState = ref.watch(objectFinderControllerProvider);
    final controller = ref.read(objectFinderControllerProvider.notifier);
    final cameraService = ref.watch(cameraServiceProvider);

    return Scaffold(
      appBar: AccessibleHeader(
        title: '360° Object Radar',
        onRepeat: () => controller.repeatResult(),
        onStop: () => controller.stopSpeaking(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                    border: Border.all(
                      color: finderState.lastResult?.isDetected == true
                          ? AppColors.emerald
                          : (finderState.is360Scanning ? AppColors.amberFocus : AppColors.surfaceBorder),
                      width: finderState.is360Scanning || finderState.lastResult?.isDetected == true ? 2.0 : 1.2,
                    ),
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
                            Icons.radar_rounded,
                            size: 56,
                            color: AppColors.amberFocus,
                          ),
                        ),
                      if (finderState.is360Scanning)
                        AnimatedBuilder(
                          animation: _radarAnimController,
                          builder: (context, _) {
                            return CustomPaint(
                              painter: _RadarSweepPainter(
                                sweepAngle: _radarAnimController.value * 2 * math.pi,
                              ),
                            );
                          },
                        ),
                      _ReticleOverlay(
                        isDetected: finderState.lastResult?.isDetected == true,
                        isScanning: finderState.is360Scanning,
                      ),
                      Positioned(
                        top: 14,
                        left: 14,
                        child: _RadarStatusBadge(
                          isScanning: finderState.is360Scanning,
                          isListening: finderState.isListening,
                          isDetected: finderState.lastResult?.isDetected == true,
                          scanCount: finderState.scanCount,
                        ),
                      ),
                      if (finderState.is360Scanning)
                        Positioned(
                          bottom: 14,
                          left: 14,
                          right: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.obsidian.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.amberFocus, width: 1.2),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.screen_rotation_rounded,
                                  size: 18,
                                  color: AppColors.amberFocus,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Turn phone 360° slowly • Searching for ${finderState.currentTarget.toUpperCase()}',
                                    style: const TextStyle(
                                      color: AppColors.warmWhite,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  border: Border.all(
                    color: finderState.isListening ? AppColors.amberFocus : AppColors.surfaceBorder,
                  ),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: finderState.isListening
                          ? () => controller.stopListeningAndSearch()
                          : () => controller.startVoicePrompt(),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: finderState.isListening
                              ? AppColors.amberFocus
                              : AppColors.obsidian,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.amberFocus,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          finderState.isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                          size: 26,
                          color: finderState.isListening ? AppColors.obsidian : AppColors.amberFocus,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                finderState.isListening ? 'LISTENING TO VOICE...' : 'TARGET OBJECT',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: finderState.isListening
                                      ? AppColors.amberFocus
                                      : AppColors.warmWhite.withValues(alpha: 0.6),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.edit_rounded, size: 16, color: AppColors.amberFocus),
                                tooltip: 'Type target object manually',
                                onPressed: _showManualInputDialog,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            finderState.isListening
                                ? (finderState.spokenQuery.isEmpty
                                    ? 'Speak now (e.g. "Where is my smartphone?")...'
                                    : '"${finderState.spokenQuery}"')
                                : (finderState.currentTarget.isEmpty
                                    ? 'Tap mic and ask: "Where is my smartphone?"'
                                    : finderState.currentTarget.toUpperCase()),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: finderState.currentTarget.isEmpty && !finderState.isListening
                                  ? AppColors.warmWhite.withValues(alpha: 0.7)
                                  : AppColors.warmWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                    border: Border.all(
                      color: finderState.lastResult?.isDetected == true
                          ? AppColors.emerald
                          : (finderState.is360Scanning ? AppColors.amberFocus : AppColors.surfaceBorder),
                      width: 1.2,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (finderState.lastResult?.isDetected == true) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.emerald.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.emerald),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _resolveDirectionIcon(finderState.lastResult?.relativePosition),
                                  size: 20,
                                  color: AppColors.emerald,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  finderState.lastResult?.relativePosition?.toUpperCase() ?? 'TARGET LOCATED',
                                  style: const TextStyle(
                                    color: AppColors.emerald,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                                if (finderState.lastResult?.distanceEstimate != null) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '• ${finderState.lastResult!.distanceEstimate}',
                                    style: const TextStyle(
                                      color: AppColors.warmWhite,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        Semantics(
                          liveRegion: true,
                          label: finderState.statusText,
                          child: Text(
                            finderState.statusText,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.45,
                              color: AppColors.warmWhite,
                              fontWeight: finderState.lastResult?.isDetected == true
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (finderState.is360Scanning) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Keep rotating in a smooth 360° circle. VisionMate will speak the instant ${finderState.currentTarget} is detected.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.warmWhite.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (finderState.is360Scanning)
                AccessibleButton(
                  label: 'Stop 360° Radar Scan',
                  icon: Icons.stop_circle_rounded,
                  backgroundColor: AppColors.crimson,
                  foregroundColor: AppColors.warmWhite,
                  onPressed: () => controller.stop360Scan(),
                )
              else if (finderState.currentTarget.isEmpty)
                AccessibleButton(
                  label: 'Speak Target Object',
                  icon: Icons.mic_rounded,
                  isLoading: finderState.isListening,
                  onPressed: () => controller.startVoicePrompt(),
                )
              else
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: AccessibleButton(
                        label: 'Start 360° Scan for "${finderState.currentTarget}"',
                        icon: Icons.radar_rounded,
                        onPressed: () => controller.start360Scan(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () => controller.startVoicePrompt(),
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: const Icon(
                          Icons.mic_rounded,
                          size: 24,
                          color: AppColors.amberFocus,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _resolveDirectionIcon(String? position) {
    if (position == null) return Icons.check_circle_rounded;
    final lower = position.toLowerCase();
    if (lower.contains('left')) return Icons.arrow_back_rounded;
    if (lower.contains('right')) return Icons.arrow_forward_rounded;
    return Icons.arrow_upward_rounded;
  }
}

class _RadarStatusBadge extends StatelessWidget {
  final bool isScanning;
  final bool isListening;
  final bool isDetected;
  final int scanCount;

  const _RadarStatusBadge({
    required this.isScanning,
    required this.isListening,
    required this.isDetected,
    required this.scanCount,
  });

  @override
  Widget build(BuildContext context) {
    String text = '360° RADAR READY';
    Color dotColor = AppColors.emerald;

    if (isListening) {
      text = 'LISTENING...';
      dotColor = AppColors.amberFocus;
    } else if (isDetected) {
      text = 'OBJECT LOCATED';
      dotColor = AppColors.emerald;
    } else if (isScanning) {
      text = 'SCANNING 360° (FRAME $scanCount)';
      dotColor = AppColors.amberFocus;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.obsidian.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dotColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.warmWhite,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReticleOverlay extends StatelessWidget {
  final bool isDetected;
  final bool isScanning;

  const _ReticleOverlay({
    required this.isDetected,
    required this.isScanning,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDetected
        ? AppColors.emerald
        : (isScanning ? AppColors.amberFocus : AppColors.warmWhite.withValues(alpha: 0.6));

    return IgnorePointer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomPaint(
          painter: _CornerReticlePainter(color: color),
        ),
      ),
    );
  }
}

class _CornerReticlePainter extends CustomPainter {
  final Color color;

  _CornerReticlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 24.0;

    canvas.drawLine(const Offset(0, 0), const Offset(cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLength), paint);

    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerLength, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLength), paint);

    canvas.drawLine(Offset(0, size.height), Offset(cornerLength, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerLength), paint);

    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerLength, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerLength), paint);
  }

  @override
  bool shouldRepaint(_CornerReticlePainter oldDelegate) => oldDelegate.color != color;
}

class _RadarSweepPainter extends CustomPainter {
  final double sweepAngle;

  _RadarSweepPainter({required this.sweepAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) * 0.45;

    final circlePaint = Paint()
      ..color = AppColors.amberFocus.withValues(alpha: 0.25)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, maxRadius * 0.35, circlePaint);
    canvas.drawCircle(center, maxRadius * 0.7, circlePaint);
    canvas.drawCircle(center, maxRadius, circlePaint);

    final crosshairPaint = Paint()
      ..color = AppColors.amberFocus.withValues(alpha: 0.2)
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(center.dx - maxRadius, center.dy), Offset(center.dx + maxRadius, center.dy), crosshairPaint);
    canvas.drawLine(Offset(center.dx, center.dy - maxRadius), Offset(center.dx, center.dy + maxRadius), crosshairPaint);

    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: [
          Colors.transparent,
          AppColors.amberFocus.withValues(alpha: 0.35),
        ],
        stops: const [0.85, 1.0],
        transform: GradientRotation(sweepAngle - (math.pi / 2)),
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, maxRadius, sweepPaint);

    final linePaint = Paint()
      ..color = AppColors.amberFocus
      ..strokeWidth = 2.0;

    final lineEnd = Offset(
      center.dx + maxRadius * math.cos(sweepAngle),
      center.dy + maxRadius * math.sin(sweepAngle),
    );
    canvas.drawLine(center, lineEnd, linePaint);
  }

  @override
  bool shouldRepaint(_RadarSweepPainter oldDelegate) => oldDelegate.sweepAngle != sweepAngle;
}
