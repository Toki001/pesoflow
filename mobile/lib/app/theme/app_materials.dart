import 'package:flutter/material.dart';

/// Shared blue materials; controls keep their native state and gesture handling.
abstract final class AppMaterials {
  static LinearGradient backdrop(bool dark) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: dark
        ? const [Color(0xFF0A1830), Color(0xFF10233D), Color(0xFF09162B)]
        : const [Color(0xFFEAF2FF), Color(0xFFF5F9FF), Color(0xFFE1EDFF)],
    stops: const [0, .55, 1],
  );

  static List<RadialGradient> backdropGlows(bool dark) => [
    RadialGradient(
      center: const Alignment(.8, -.8),
      radius: 1.2,
      colors: [
        const Color(0xFF3B82F6).withValues(alpha: dark ? .18 : .015),
        const Color(0xFF3B82F6).withValues(alpha: 0),
      ],
    ),
    RadialGradient(
      center: const Alignment(-.9, .8),
      radius: 1.1,
      colors: [
        const Color(0xFF2563EB).withValues(alpha: dark ? .20 : .015),
        const Color(0xFF2563EB).withValues(alpha: 0),
      ],
    ),
  ];

  /// Each ribbon uses these same stops, including its translucent highlight.
  static List<Color> waveColors(bool dark) => dark
      ? const [Color(0x242563EB), Color(0x121A3D75), Color(0x304F8EE8)]
      : const [Color(0x0D3B82F6), Color(0x0960A5FA), Color(0xCCFFFFFF)];

  static LinearGradient button({required bool pale, required bool pressed}) =>
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: pale
            ? const [Color(0xFFE5EFFF), Color(0xFFBFDBFE)]
            : pressed
            ? const [Color(0xFF173DA7), Color(0xFF1D4ED8)]
            : const [Color(0xFF1D4ED8), Color(0xFF2563EB)],
      );
}
