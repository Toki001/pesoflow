import 'package:flutter/material.dart';

/// Shared blue materials; controls keep their native state and gesture handling.
abstract final class AppMaterials {
  static LinearGradient backdrop(bool dark) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: dark
        ? const [Color(0xFF0B1422), Color(0xFF101A2B), Color(0xFF090F1B)]
        : const [Color(0xFFFAFCFF), Colors.white, Color(0xFFF6FAFF)],
    stops: const [0, .55, 1],
  );

  static List<RadialGradient> backdropGlows(bool dark) => [
    RadialGradient(
      center: const Alignment(.5, -1.1),
      radius: .68,
      stops: const [0, .44, .78, 1],
      colors: [
        (dark ? const Color(0xFF60A5FA) : const Color(0xFFE7F1FF)).withValues(
          alpha: dark ? .02 : .15,
        ),
        (dark ? const Color(0xFF172F54) : const Color(0xFFDBEAFE)).withValues(
          alpha: dark ? .55 : .50,
        ),
        (dark ? const Color(0xFF1E3C70) : const Color(0xFFBFD7FA)).withValues(
          alpha: dark ? .55 : .62,
        ),
        // Preserve the edge hue while fading to avoid a gray interpolation rim.
        (dark ? const Color(0xFF1E3C70) : const Color(0xFFBFD7FA)).withValues(
          alpha: 0,
        ),
      ],
    ),
    RadialGradient(
      center: const Alignment(-1.22, .08),
      radius: .64,
      stops: const [0, .50, .80, 1],
      colors: [
        (dark ? const Color(0xFF60A5FA) : const Color(0xFFDBEAFE)).withValues(
          alpha: dark ? .03 : .35,
        ),
        (dark ? const Color(0xFF172F54) : const Color(0xFFC7DDFB)).withValues(
          alpha: dark ? .55 : .50,
        ),
        (dark ? const Color(0xFF1E3C70) : const Color(0xFFBFD7FA)).withValues(
          alpha: dark ? .52 : .55,
        ),
        (dark ? const Color(0xFF1E3C70) : const Color(0xFFBFD7FA)).withValues(
          alpha: 0,
        ),
      ],
    ),
    RadialGradient(
      center: const Alignment(1.18, .72),
      radius: .84,
      stops: const [0, .50, .80, 1],
      colors: [
        (dark ? const Color(0xFF60A5FA) : const Color(0xFFE7F1FF)).withValues(
          alpha: dark ? .02 : .20,
        ),
        (dark ? const Color(0xFF172F54) : const Color(0xFFBFDBFE)).withValues(
          alpha: .55,
        ),
        (dark ? const Color(0xFF1E3C70) : const Color(0xFFBFD7FA)).withValues(
          alpha: dark ? .55 : .58,
        ),
        (dark ? const Color(0xFF1E3C70) : const Color(0xFFBFD7FA)).withValues(
          alpha: 0,
        ),
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
