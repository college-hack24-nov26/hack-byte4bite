import 'package:flutter/material.dart';
import 'package:visionmate/core/constants/semantic_labels.dart';

class AccessibleHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onRepeat;
  final VoidCallback? onStop;
  final List<Widget>? actions;

  const AccessibleHeader({
    super.key,
    required this.title,
    this.onBack,
    this.onRepeat,
    this.onStop,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: onBack != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: SemanticLabels.backButton,
              onPressed: onBack,
            )
          : null,
      actions: [
        if (onRepeat != null)
          IconButton(
            icon: const Icon(Icons.volume_up_rounded),
            tooltip: SemanticLabels.repeatSpeechButton,
            onPressed: onRepeat,
          ),
        if (onStop != null)
          IconButton(
            icon: const Icon(Icons.stop_circle_rounded),
            tooltip: SemanticLabels.stopSpeechButton,
            onPressed: onStop,
          ),
        ...?actions,
      ],
    );
  }
}

