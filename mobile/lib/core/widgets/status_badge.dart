import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge(
    this.label, {
    required this.foreground,
    required this.background,
    this.icon,
    this.iconSize = 14,
    this.pill = true,
    super.key,
  });
  final String label;
  final Color foreground;
  final Color background;
  final IconData? icon;
  final double iconSize;
  final bool pill;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(
        pill ? AppRadius.pill : AppRadius.micro,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: iconSize, color: foreground),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            label,
            style: AppTypography.labelSmall.copyWith(color: foreground),
          ),
        ),
      ],
    ),
  );
}
