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
    Widget content = child;
    if (!solid) {
      for (final glow in AppMaterials.backdropGlows(c.isDark).reversed) {
        content = DecoratedBox(
          decoration: BoxDecoration(gradient: glow),
          child: content,
        );
      }
    }
    return BackdropGroup(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.canvas,
          gradient: solid ? null : AppMaterials.backdrop(c.isDark),
        ),
        child: content,
      ),
    );
  }
}
