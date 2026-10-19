import 'package:flutter/material.dart';

/// Shared blue materials; controls keep their native state and gesture handling.
abstract final class AppMaterials {
  static LinearGradient backdrop(bool dark) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: dark
        ? const [Color(0xFF071423), Color(0xFF102845), Color(0xFF080F1C)]
        : const [Color(0xFFE6EEFF), Color(0xFFF3F7FF), Color(0xFFE9F2FF)],
    stops: const [0, .55, 1],
  );

  static LinearGradient card(bool dark, {required bool solid}) =>
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dark
            ? [
                const Color(0xFF1A2D48).withValues(alpha: solid ? 1 : .82),
                const Color(0xFF111D32).withValues(alpha: solid ? 1 : .72),
              ]
            : [
                Colors.white.withValues(alpha: solid ? 1 : .88),
                const Color(0xFFF8FBFF).withValues(alpha: solid ? 1 : .70),
              ],
      );

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
