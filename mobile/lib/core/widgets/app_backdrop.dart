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
    if (!solid && c.isDark) {
      content = CustomPaint(painter: const _DarkWavePainter(), child: content);
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

/// Static organic shapes leave the financial content and controls stationary.
class _DarkWavePainter extends CustomPainter {
  const _DarkWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final colors = AppMaterials.waveColors(true);
    // Fixed unequal sweeps look organic without changing on rebuild or restart.
    for (final (start, end, bend, thickness) in const [
      (-.08, .10, .32, .20),
      (.28, .18, -.22, .19),
      (.47, .69, .28, .23),
      (.91, .82, -.36, .21),
    ]) {
      final left = h * start;
      final right = h * end;
      final amplitude = w * bend;
      final depth = h * thickness;
      final crest = Path()
        ..moveTo(-w * .1, left)
        ..cubicTo(
          w * .20,
          left + amplitude,
          w * .58,
          right - amplitude,
          w * 1.1,
          right,
        );
      final ribbon = Path.from(crest)
        ..lineTo(w * 1.1, right + depth)
        ..cubicTo(
          w * .72,
          right + depth + amplitude * .5,
          w * .32,
          left + depth - amplitude * .7,
          -w * .1,
          left + depth,
        )
        ..close();
      canvas.drawPath(
        ribbon,
        Paint()
          ..shader =
              LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [colors[0], colors[1]],
              ).createShader(
                Rect.fromLTWH(
                  0,
                  left < right ? left : right,
                  w,
                  depth + (right - left).abs(),
                ),
              ),
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
  bool shouldRepaint(_DarkWavePainter oldDelegate) => false;
}
