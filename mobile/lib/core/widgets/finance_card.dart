import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';

class FinanceCard extends StatelessWidget {
  const FinanceCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.hero = false,
    this.radius = AppRadius.homeCard,
    this.color,
    this.borderColor,
    this.gradient,
    super.key,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool hero;
  final double radius;
  final Color? color;
  final Color? borderColor;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: c.isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .10),
                  offset: const Offset(0, 4),
                  blurRadius: 20,
                ),
              ]
            : (hero ? AppShadows.card : AppShadows.subtle),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: gradient == null ? (color ?? c.surface) : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(radius),
            // Explicit borders identify selection, never section packaging.
            border: borderColor == null
                ? null
                : Border.all(color: borderColor!),
          ),
          child: Padding(
            padding: padding,
            child: Material(type: MaterialType.transparency, child: child),
          ),
        ),
      ),
    );
  }
}
