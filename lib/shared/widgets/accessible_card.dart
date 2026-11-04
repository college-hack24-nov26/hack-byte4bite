import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:visionmate/core/constants/app_constants.dart';
import 'package:visionmate/core/theme/app_colors.dart';

class AccessibleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final String? semanticAction;
  final bool isHighlighted;

  const AccessibleCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    this.semanticAction,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: '$title. $description',
      hint: semanticAction != null ? 'Double tap to open $semanticAction' : 'Double tap to activate',
      child: Material(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          splashColor: AppColors.amberFocus.withValues(alpha: 0.12),
          highlightColor: AppColors.amberFocus.withValues(alpha: 0.06),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              border: Border.all(
                color: isHighlighted ? AppColors.amberFocus : AppColors.surfaceBorder,
                width: isHighlighted ? 2.0 : 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? AppColors.amberFocus.withValues(alpha: 0.15)
                        : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isHighlighted
                          ? AppColors.amberFocus.withValues(alpha: 0.4)
                          : AppColors.surfaceBorderSubtle,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 26,
                    color: isHighlighted ? AppColors.amberFocus : AppColors.warmWhite,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.warmWhite,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.textDisabled,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
