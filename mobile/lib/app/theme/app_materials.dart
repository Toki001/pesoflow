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
      center: const Alignment(.8, -.8),
      radius: 1.2,
      colors: [
        const Color(0xFF38BDF8).withValues(alpha: dark ? .16 : .10),
        const Color(0xFF38BDF8).withValues(alpha: 0),
      ],
    ),
    RadialGradient(
      center: const Alignment(-.9, .8),
      radius: 1.1,
      colors: [
        const Color(0xFF2563EB).withValues(alpha: dark ? .18 : .08),
        const Color(0xFF2563EB).withValues(alpha: 0),
      ],
    ),
  ];

  /// Each ribbon uses these same stops, including its translucent highlight.
  static List<Color> waveColors(bool dark) => dark
      ? const [Color(0x242D699E), Color(0x121A4169), Color(0x244B92C5)]
      : const [Color(0x406FC8EC), Color(0x127BC5EB), Color(0x99FFFFFF)];

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
              const Color(0xFF385471).withValues(alpha: .38),
              const Color(0xFF203D59).withValues(alpha: .26),
              const Color(0xFF172943).withValues(alpha: .32),
            ]
          : [
              Colors.white.withValues(alpha: .62),
              const Color(0xFFF2F8FF).withValues(alpha: .38),
              const Color(0xFFE2F0FD).withValues(alpha: .48),
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
