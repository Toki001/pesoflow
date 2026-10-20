import 'package:flutter/material.dart';

/// Ambient canvas and blue controls retain native state and gesture handling.
abstract final class AppMaterials {
  static LinearGradient backdrop(bool dark) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: dark
        ? const [Color(0xFF0A1830), Color(0xFF10233D), Color(0xFF09162B)]
        : const [Color(0xFFE9EDF2), Color(0xFFE8EDF2), Color(0xFFE5EAF0)],
    stops: const [0, .55, 1],
  );

  static List<RadialGradient> backdropGlows(bool dark) => dark
      ? [
          RadialGradient(
            center: const Alignment(.8, -.8),
            radius: 1.2,
            colors: [
              const Color(0xFF3B82F6).withValues(alpha: .18),
              const Color(0xFF3B82F6).withValues(alpha: 0),
            ],
          ),
          RadialGradient(
            center: const Alignment(-.9, .8),
            radius: 1.1,
            colors: [
              const Color(0xFF2563EB).withValues(alpha: .20),
              const Color(0xFF2563EB).withValues(alpha: 0),
            ],
          ),
        ]
      : const [
          // A's lavender-left / blue-above / mint-right composition.
          RadialGradient(
            center: Alignment(-.85, -.05),
            radius: .95,
            colors: [Color(0xC7C5BAF5), Color(0x59C5BAF5), Color(0x00C5BAF5)],
            stops: [0, .4, 1],
          ),
          RadialGradient(
            center: Alignment(.15, -.60),
            radius: 1.05,
            colors: [Color(0xC7ABE4F6), Color(0x59ABE4F6), Color(0x00ABE4F6)],
            stops: [0, .4, 1],
          ),
          RadialGradient(
            center: Alignment(.80, .40),
            radius: 1,
            colors: [Color(0xC7A9E4CB), Color(0x59A9E4CB), Color(0x00A9E4CB)],
            stops: [0, .4, 1],
          ),
        ];

  /// Dark appearance retains its existing subtle ribbons.
  static List<Color> waveColors(bool dark) => dark
      ? const [Color(0x242563EB), Color(0x121A3D75), Color(0x304F8EE8)]
      : const [];

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
