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
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color ?? context.colors.surface,
      gradient:
          gradient ??
          (color != null
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: context.colors.isDark
                      ? const [Color(0xFF15243C), Color(0xFF111D32)]
                      : const [Colors.white, Color(0xFFF8FAFF)],
                )),
      borderRadius: BorderRadius.circular(radius),
      // Section cards are borderless; explicit borders identify selections only.
      border: borderColor == null ? null : Border.all(color: borderColor!),
      boxShadow: context.colors.isDark
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: .12),
                offset: const Offset(0, 4),
                blurRadius: 16,
              ),
            ]
          : (hero ? AppShadows.card : AppShadows.subtle),
    ),
    child: Material(type: MaterialType.transparency, child: child),
  );
}
