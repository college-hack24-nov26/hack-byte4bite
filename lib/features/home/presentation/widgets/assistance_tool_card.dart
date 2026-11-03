import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:visionmate/core/theme/app_colors.dart';

class AssistanceToolCard extends StatelessWidget {
  final String title;
  final String description;
  final String keyLabel;
  final IconData icon;
  final Color accentColor;
  final bool isDanger;
  final VoidCallback onTap;

  const AssistanceToolCard({
    super.key,
    required this.title,
    required this.description,
    required this.keyLabel,
    required this.icon,
    required this.accentColor,
    this.isDanger = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. $description. Keyboard shortcut $keyLabel.',
      hint: 'Double tap to open $title',
      child: Material(
        color: isDanger
            ? AppColors.crimsonAccent.withValues(alpha: 0.08)
            : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          splashColor: accentColor.withValues(alpha: 0.15),
          highlightColor: accentColor.withValues(alpha: 0.08),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDanger
                    ? AppColors.crimsonAccent.withValues(alpha: 0.6)
                    : AppColors.surfaceBorder,
                width: isDanger ? 1.8 : 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: accentColor.withValues(alpha: 0.35),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              keyLabel,
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: AppColors.warmWhite,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        description,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDanger ? AppColors.crimsonAccent : AppColors.textDisabled,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
