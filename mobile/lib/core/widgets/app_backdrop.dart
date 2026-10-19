import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_materials.dart';

/// One shared backdrop input for the non-overlapping glass cards on a route.
class AppBackdrop extends StatelessWidget {
  const AppBackdrop({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final solid = MediaQuery.highContrastOf(context);
    return BackdropGroup(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.canvas,
          gradient: solid ? null : AppMaterials.backdrop(c.isDark),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: solid
                ? null
                : RadialGradient(
                    center: Alignment.topRight,
                    radius: 1.4,
                    colors: [
                      AppColors.primary.withValues(alpha: c.isDark ? .12 : .07),
                      Colors.transparent,
                    ],
                  ),
          ),
          child: child,
        ),
      ),
    );
  }
}
