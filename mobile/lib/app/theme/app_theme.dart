import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_materials.dart';
import 'app_radius.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);
  static ThemeData forAccessibility(
    Brightness brightness, {
    required bool reduceMotion,
  }) => _build(brightness, reduceMotion: reduceMotion);

  static Widget _buttonLayer(
    BuildContext context,
    Set<WidgetState> states,
    Widget? child,
  ) {
    if (states.contains(WidgetState.disabled)) return child ?? const SizedBox();
    final button = context.widget;
    final specified = button is ButtonStyleButton
        ? button.style?.backgroundColor?.resolve(states)
        : null;
    if (specified != null &&
        specified != AppColors.primary &&
        specified != AppColors.primarySoft) {
      return child ?? const SizedBox();
    }
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        gradient: AppMaterials.button(
          pale: specified == AppColors.primarySoft,
          pressed: states.contains(WidgetState.pressed),
        ),
      ),
      child: child,
    );
  }

  static ThemeData _build(Brightness brightness, {bool reduceMotion = false}) {
    final c = FinancePalette(brightness == Brightness.dark);
    var scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: brightness,
        ).copyWith(
          primary: c.primary,
          secondary: c.secondary,
          secondaryContainer: c.primary.withValues(alpha: .10),
          onSecondaryContainer: c.primary,
          surfaceTint: Colors.transparent,
          surface: c.surface,
          onSurface: c.ink,
          error: c.danger,
          outline: c.border,
        );
    if (c.isDark) {
      scheme = scheme.copyWith(
        onPrimary: c.canvas,
        primaryContainer: const Color(0xFF173B65),
        onPrimaryContainer: AppColors.primarySoft,
        onSecondary: c.canvas,
        surfaceDim: c.canvas,
        surfaceBright: const Color(0xFF2E4357),
        surfaceContainerLowest: c.canvas,
        surfaceContainerLow: c.surface,
        surfaceContainer: c.mutedSurface,
        surfaceContainerHigh: const Color(0xFF2E4357),
        surfaceContainerHighest: const Color(0xFF385069),
        onSurfaceVariant: c.secondaryInk,
        onError: c.canvas,
        errorContainer: const Color(0xFF51232D),
        onErrorContainer: c.danger,
        outlineVariant: c.border,
        inverseSurface: const Color(0xFFE2E8F0),
        onInverseSurface: AppColors.ink,
        inversePrimary: AppColors.primaryStrong,
      );
    }
    return ThemeData(
      useMaterial3: true,
      pageTransitionsTheme: reduceMotion
          ? PageTransitionsTheme(
              builders: {
                for (final platform in TargetPlatform.values)
                  platform: const _StaticPageTransitionsBuilder(),
              },
            )
          : const PageTransitionsTheme(),
      brightness: brightness,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: c.canvas,
      colorScheme: scheme,
      textTheme: TextTheme(
        displayLarge: AppTypography.display,
        headlineLarge: AppTypography.headlineLarge,
        headlineMedium: AppTypography.headlineMedium,
        headlineSmall: AppTypography.headlineSmall,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelMedium,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ).apply(bodyColor: c.ink, displayColor: c.ink),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.isDark
            ? const Color(0xFF071423).withValues(alpha: .72)
            : Colors.white.withValues(alpha: .20),
        hintStyle: TextStyle(color: c.mutedInk),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: c.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: c.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: c.danger, width: 1.5),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.hero),
          ),
        ),
      ),
      chipTheme: const ChipThemeData(shape: StadiumBorder()),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      expansionTileTheme: const ExpansionTileThemeData(
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.primary,
      ),
      iconTheme: const IconThemeData(color: AppColors.primary, size: 20),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          backgroundColor: c.isDark
              ? c.canvas.withValues(alpha: .65)
              : c.primary.withValues(alpha: .06),
          shape: const CircleBorder(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: c.primary,
          textStyle: AppTypography.labelMedium,
          shape: const StadiumBorder(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: c.surface.withValues(alpha: .60),
          foregroundColor: c.secondaryInk,
          side: BorderSide(color: c.border),
          minimumSize: const Size(48, 48),
          textStyle: AppTypography.labelMedium,
          shape: const StadiumBorder(),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          backgroundBuilder: _buttonLayer,
          minimumSize: const Size(48, 48),
          textStyle: AppTypography.labelMedium,
          shape: const StadiumBorder(),
        ),
      ),
    );
  }
}

/// Retain navigation and semantics without spatial motion when requested.
class _StaticPageTransitionsBuilder extends PageTransitionsBuilder {
  const _StaticPageTransitionsBuilder();
  @override
  Duration get transitionDuration => Duration.zero;
  @override
  Duration get reverseTransitionDuration => Duration.zero;
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => child;
}
