import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Solid floating dock surface, shared by every main destination.
class NavigationPanel extends StatelessWidget {
  const NavigationPanel({required this.child, this.radius = 26, super.key});
  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF12368E)
              .withValues(alpha: context.colors.isDark ? .16 : .10),
          offset: const Offset(0, 8),
          blurRadius: 28,
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Material(type: MaterialType.transparency, child: child),
    ),
  );
}
