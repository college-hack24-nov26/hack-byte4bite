import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';

class AccessibleCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final String? semanticHint;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;

  const AccessibleCard({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.semanticHint,
    this.backgroundColor,
    this.borderColor,
    this.padding = const EdgeInsets.all(AppConstants.defaultPadding),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = backgroundColor ?? theme.cardTheme.color;
    final resolvedBorderColor =
        borderColor ?? theme.colorScheme.outline;

    final content = Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius:
            BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(
          color: resolvedBorderColor,
          width: 2,
        ),
      ),
      padding: padding,
      child: child,
    );

    if (onTap == null) {
      return Semantics(
        label: semanticLabel,
        child: content,
      );
    }

    return Semantics(
      button: true,
      label: semanticLabel,
      hint: semanticHint,
      child: Material(
        color: Colors.transparent,
        borderRadius:
            BorderRadius.circular(AppConstants.defaultBorderRadius),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap!();
          },
          borderRadius:
              BorderRadius.circular(AppConstants.defaultBorderRadius),
          child: content,
        ),
      ),
    );
  }
}

