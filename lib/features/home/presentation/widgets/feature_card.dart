import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

class FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final String semanticAction;

  const FeatureCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    required this.semanticAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: '$title. $description. Tap to open $semanticAction.',
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          border: Border.all(
            color: isDark ? AppColors.navyBorder : AppColors.warmWhiteSecondary,
            width: 2.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            onTap: () {
              HapticFeedback.heavyImpact();
              onTap();
            },
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Row(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.navyLight : AppColors.navyDark,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.highContrastFocus,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: 36,
                      color: AppColors.warmWhite,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          description,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 24,
                    color: isDark
                        ? AppColors.textLightSecondary
                        : AppColors.textDarkSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

