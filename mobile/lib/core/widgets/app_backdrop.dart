import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_materials.dart';

/// Static ambient backdrop shared by shell and task routes.
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.canvas,
        gradient: solid ? null : AppMaterials.backdrop(c.isDark),
      ),
      child: content,
    );
  }
}
