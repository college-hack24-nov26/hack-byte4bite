import 'package:flutter/material.dart';
import 'package:visionmate/core/theme/app_colors.dart';
import 'assistance_tool_card.dart';

class HomeFeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final String keyLabel;
  final IconData icon;
  final Color accentColor;
  final bool isDanger;
  final VoidCallback onTap;

  const HomeFeatureCard({
    super.key,
    required this.title,
    required this.description,
    this.keyLabel = 'KEY',
    required this.icon,
    this.accentColor = AppColors.amberFocus,
    this.isDanger = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AssistanceToolCard(
      title: title,
      description: description,
      keyLabel: keyLabel,
      icon: icon,
      accentColor: accentColor,
      isDanger: isDanger,
      onTap: onTap,
    );
  }
}
