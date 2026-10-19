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
    if (!solid) {
      content = CustomPaint(painter: _WavePainter(c.isDark), child: content);
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

/// Static, bounded ribbons give glass a visible backdrop without moving the ledger.
class _WavePainter extends CustomPainter {
  const _WavePainter(this.dark);
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final colors = AppMaterials.waveColors(dark);
    final w = size.width;
    final h = size.height;
    final amplitude = w * .18;
    for (final y in [-.03, .24, .51, .78]) {
      final base = h * y;
      final depth = h * .16;
      final crest = Path()
        ..moveTo(-w * .1, base)
        ..cubicTo(
          w * .22,
          base + amplitude,
          w * .5,
          base - amplitude,
          w * .76,
          base,
        )
        ..quadraticBezierTo(
          w * .95,
          base + amplitude * .45,
          w * 1.1,
          base - amplitude * .3,
        );
      final ribbon = Path.from(crest)
        ..lineTo(w * 1.1, base + depth - amplitude * .3)
        ..quadraticBezierTo(
          w * .95,
          base + depth + amplitude * .45,
          w * .76,
          base + depth,
        )
        ..cubicTo(
          w * .5,
          base + depth - amplitude,
          w * .22,
          base + depth + amplitude,
          -w * .1,
          base + depth,
        )
        ..close();
      canvas.drawPath(
        ribbon,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors[0], colors[1]],
          ).createShader(Rect.fromLTWH(0, h * y, w, depth)),
      );
      canvas.drawPath(
        crest,
        Paint()
          ..color = colors[2]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => dark != oldDelegate.dark;
}
