import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Shared blue materials; controls keep their native state and gesture handling.
abstract final class AppMaterials {
  static LinearGradient backdrop(bool dark) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: dark
        ? const [Color(0xFF101820), Color(0xFF0E141B), Color(0xFF0A1016)]
        : const [Color(0xFFC9DBF4), Color(0xFFEAF1FA), Color(0xFFC7DAF4)],
    stops: const [0, .55, 1],
  );

  static List<RadialGradient> backdropGlows(bool dark) => dark
      ? [
          RadialGradient(
            center: const Alignment(.9, -.9),
            radius: .85,
            colors: [
              const Color(0xFF205580).withValues(alpha: .35),
              Colors.transparent,
            ],
          ),
          RadialGradient(
            center: const Alignment(-1, .9),
            radius: .8,
            colors: [
              const Color(0xFF1D4E83).withValues(alpha: .28),
              Colors.transparent,
            ],
          ),
        ]
      : [
          RadialGradient(
            center: Alignment.topRight,
            radius: 1.4,
            colors: [
              AppColors.primary.withValues(alpha: .07),
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
              const Color(0xFF7B9ABD).withValues(alpha: .18),
              const Color(0xFF315478).withValues(alpha: .24),
              const Color(0xFF172943).withValues(alpha: .18),
            ]
          : [
              Colors.white.withValues(alpha: .48),
              Colors.white.withValues(alpha: .28),
              const Color(0xFFE8F1FF).withValues(alpha: .18),
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
