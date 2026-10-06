import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';

class FinanceCard extends StatelessWidget {
  const FinanceCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.sm),
    this.hero = false,
    this.color,
    this.borderColor,
    super.key,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool hero;
  final Color? color;
  final Color? borderColor;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color ?? context.colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.homeCard),
      border: Border.all(
        color:
            borderColor ??
            (hero ? context.colors.strongBorder : context.colors.border),
      ),
      boxShadow: context.colors.isDark
          ? null
          : (hero ? AppShadows.card : AppShadows.subtle),
    ),
    child: child,
  );
}
