import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';

class BudgetProgressBar extends StatelessWidget {
  const BudgetProgressBar({
    required this.value,
    required this.color,
    required this.label,
    this.height = 6,
    super.key,
  });
  final double value;
  final Color color;
  final String label;
  final double height;
  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    value: '${(value * 100).round()} percent used',
    child: ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: SizedBox(
        height: height,
        child: ColoredBox(
          color: context.colors.mutedSurface,
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: value.clamp(0, 1),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: SizedBox(height: height),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
