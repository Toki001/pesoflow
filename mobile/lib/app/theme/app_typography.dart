import 'package:flutter/material.dart';

abstract final class AppTypography {
  static TextStyle _style(
    double size,
    double line,
    double weight, {
    double tracking = 0,
    bool numeric = false,
  }) => TextStyle(
    fontFamily: 'Inter',
    fontSize: size,
    height: line / size,
    fontVariations: [FontVariation('wght', weight)],
    letterSpacing: tracking,
    fontFeatures: numeric ? const [FontFeature.tabularFigures()] : null,
  );
  static final display = _style(34, 38, 700, tracking: -1.02);
  static final headlineLarge = _style(28, 32, 700, tracking: -.7);
  static final headlineMedium = _style(22, 26, 700, tracking: -.44);
  static final headlineSmall = _style(18, 22, 650, tracking: -.18);
  static final numericXL = _style(32, 32, 750, tracking: -1.12, numeric: true);
  static final numericLarge = _style(24, 24, 700, tracking: -.6, numeric: true);
  static final numericMedium = _style(
    18,
    18,
    700,
    tracking: -.36,
    numeric: true,
  );
  static final bodyLarge = _style(16, 24, 450);
  static final bodyMedium = _style(14, 20, 450);
  static final bodySmall = _style(12, 17, 450);
  static final labelMedium = _style(12, 14, 600, tracking: .12);
  static final labelSmall = _style(11, 13, 600, tracking: .22);
  static final merchant = _style(14, 17.5, 600);
}
