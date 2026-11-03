import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:visionmate/core/constants/app_constants.dart';
import 'package:visionmate/core/theme/app_colors.dart';

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
                        HapticFeedback.lightImpact();
                        onPressed!();
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: foregroundColor ?? theme.colorScheme.onSurface,
                  side: BorderSide(
                    color: foregroundColor ?? AppColors.surfaceBorder,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _buildContent(theme),
              )
            : ElevatedButton(
                onPressed: isLoading || onPressed == null
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        onPressed!();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: backgroundColor ?? AppColors.amberFocus,
                  foregroundColor: foregroundColor ?? AppColors.obsidian,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _buildContent(theme),
              ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (isLoading) {
      return Semantics(
        label: 'Loading',
        child: const SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.obsidian),
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
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
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
