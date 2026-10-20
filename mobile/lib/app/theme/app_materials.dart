import 'package:flutter/material.dart';

/// Ambient canvas and blue controls retain native state and gesture handling.
abstract final class AppMaterials {
  static LinearGradient backdrop(bool dark) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: dark
        ? const [Color(0xFF101724), Color(0xFF151E2D), Color(0xFF101925)]
        : const [Color(0xFFE9EDF2), Color(0xFFE8EDF2), Color(0xFFE5EAF0)],
    stops: const [0, .55, 1],
  );

  // Both appearances share the approved A geometry; only luminance changes.
  static List<RadialGradient> backdropGlows(bool dark) => [
    RadialGradient(
      center: const Alignment(-.85, -.05),
      radius: .95,
      colors: dark
          ? const [Color(0x387E6AC7), Color(0x197E6AC7), Color(0x007E6AC7)]
          : const [Color(0xC7C5BAF5), Color(0x59C5BAF5), Color(0x00C5BAF5)],
      stops: const [0, .4, 1],
    ),
    RadialGradient(
      center: const Alignment(.15, -.60),
      radius: 1.05,
      colors: dark
          ? const [Color(0x3D4A9DBD), Color(0x1A4A9DBD), Color(0x004A9DBD)]
          : const [Color(0xC7ABE4F6), Color(0x59ABE4F6), Color(0x00ABE4F6)],
      stops: const [0, .4, 1],
    ),
    RadialGradient(
      center: const Alignment(.80, .40),
      radius: 1,
      colors: dark
          ? const [Color(0x3348A28A), Color(0x1748A28A), Color(0x0048A28A)]
          : const [Color(0xC7A9E4CB), Color(0x59A9E4CB), Color(0x00A9E4CB)],
      stops: const [0, .4, 1],
    ),
  ];

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
