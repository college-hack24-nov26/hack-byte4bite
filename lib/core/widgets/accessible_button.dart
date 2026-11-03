import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';

class AccessibleButton extends StatelessWidget {
  final String label;
  final String? semanticHint;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isSecondary;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AccessibleButton({
    super.key,
    required this.label,
    this.semanticHint,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isSecondary = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      enabled: onPressed != null && !isLoading,
      label: label,
      hint: semanticHint,
      child: SizedBox(
        height: AppConstants.minTouchTargetSize,
        child: isSecondary
            ? OutlinedButton(
                onPressed: isLoading || onPressed == null
                    ? null
                    : () {
                        HapticFeedback.selectionClick();
                        onPressed!();
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: foregroundColor,
                ),
                child: _buildChild(theme),
              )
            : ElevatedButton(
                onPressed: isLoading || onPressed == null
                    ? null
                    : () {
                        HapticFeedback.selectionClick();
                        onPressed!();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: backgroundColor,
                  foregroundColor: foregroundColor,
                ),
                child: _buildChild(theme),
              ),
      ),
    );
  }

  Widget _buildChild(ThemeData theme) {
    if (isLoading) {
      return const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 3,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Text(
      label,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

