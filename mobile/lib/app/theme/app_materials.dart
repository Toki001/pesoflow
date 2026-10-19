import 'package:flutter/material.dart';

/// Shared blue materials; controls keep their native state and gesture handling.
abstract final class AppMaterials {
  static LinearGradient backdrop(bool dark) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: dark
        ? const [Color(0xFF101820), Color(0xFF0E141B), Color(0xFF0A1016)]
        : const [Color(0xFFF7FAFF), Colors.white, Color(0xFFF2F7FF)],
    stops: const [0, .55, 1],
  );

  static List<RadialGradient> backdropGlows(bool dark) => [
    RadialGradient(
      center: const Alignment(.9, -.9),
      radius: .85,
      colors: [
        const Color(0xFF2563EB).withValues(alpha: dark ? .30 : .15),
        Colors.transparent,
      ],
    ),
    RadialGradient(
      center: const Alignment(-1, .9),
      radius: .8,
      colors: [
        const Color(0xFF2563EB).withValues(alpha: dark ? .24 : .12),
        Colors.transparent,
      ],
    ),
  ];

  static LinearGradient card(bool dark, {required bool solid}) {
    if (solid) {
      final color = dark ? const Color(0xFF111D32) : Colors.white;
      return LinearGradient(colors: [color, color]);
    }
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: const [0, .32, 1],
      colors: dark
          ? [
              const Color(0xFF5B7C9B).withValues(alpha: .12),
              const Color(0xFF203D59).withValues(alpha: .08),
              const Color(0xFF172943).withValues(alpha: .10),
            ]
          : [
              const Color(0xFFBAD4F5).withValues(alpha: .12),
              const Color(0xFFD2E5FF).withValues(alpha: .06),
              const Color(0xFFB7D3F5).withValues(alpha: .10),
            ],
    );
  }

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
