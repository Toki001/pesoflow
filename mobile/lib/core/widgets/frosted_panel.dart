import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// A single clipped glass layer for floating chrome, not for ledger rows.
class FrostedPanel extends StatelessWidget {
  const FrostedPanel({required this.child, this.radius = 26, super.key});
  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final solid = MediaQuery.highContrastOf(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF12368E)
                .withValues(alpha: c.isDark ? .16 : .10),
            offset: const Offset(0, 8),
            blurRadius: 28,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          enabled: !solid,
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  c.surface.withValues(alpha: solid ? 1 : .52),
                  (c.isDark ? const Color(0xFF172B49) : const Color(0xFFF0F6FF))
                      .withValues(alpha: solid ? 1 : .40),
                ],
              ),
            ),
            child: Material(type: MaterialType.transparency, child: child),
          ),
        ),
      ),
    );
  }
}
