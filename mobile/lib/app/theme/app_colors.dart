import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF2563EB);
  static const primaryStrong = Color(0xFF1D4ED8);
  static const primarySoft = Color(0xFFDBEAFE);
  static const secondary = Color(0xFF0F766E);
  static const secondarySoft = Color(0xFFCCFBF1);
  static const accent = Color(0xFF7C3AED);
  static const accentSoft = Color(0xFFEDE9FE);
  static const positive = Color(0xFF16A34A);
  static const positiveSoft = Color(0xFFDCFCE7);
  static const warning = Color(0xFFD97706);
  static const warningSoft = Color(0xFFFEF3C7);
  static const danger = Color(0xFFDC2626);
  static const dangerSoft = Color(0xFFFEE2E2);
  static const ink = Color(0xFF0F172A);
  static const inkSecondary = Color(0xFF475569);
  static const inkMuted = Color(0xFF64748B);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSubtle = Color(0xFFF8FAFC);
  static const surfaceMuted = Color(0xFFF1F5F9);
  static const border = Color(0xFFE2E8F0);
  static const borderStrong = Color(0xFFCBD5E1);
  static const darkSurface = Color(0xFF0B1220);
  static const darkSurfaceSubtle = Color(0xFF111827);
  static const darkSurfaceMuted = Color(0xFF1E293B);
  static const darkInk = Color(0xFFF8FAFC);
  static const darkInkSecondary = Color(0xFFCBD5E1);
  static const darkInkMuted = Color(0xFF94A3B8);
  static const darkBorder = Color(0xFF334155);

  // Material-derived roles visible in the approved Home export.
  static const stitchPrimary = Color(0xFF004AC6);
  static const stitchInk = Color(0xFF131B2E);
  static const stitchSecondary = Color(0xFF006A63);
  static const stitchAccent = Color(0xFF6A1EDB);
  static const stitchAccentBorder = Color(0xFFEADDFF);
  static const stitchInsight = Color(0xFFF4F1FE);
  static const darkPrimary = Color(0xFFB4C5FF);
  static const darkPositive = Color(0xFF86EFAC);
  static const darkWarning = Color(0xFFFBBF24);
  static const darkDanger = Color(0xFFFCA5A5);
  static const darkSecondary = Color(0xFF80D5CB);
  static const darkAccent = Color(0xFFD2BBFF);
}

/// Semantic roles keep components independent of the active brightness.
class FinancePalette {
  const FinancePalette(this.isDark);
  final bool isDark;
  Color get canvas => isDark ? AppColors.darkSurface : AppColors.surfaceSubtle;
  Color get surface => isDark ? AppColors.darkSurfaceSubtle : AppColors.surface;
  Color get mutedSurface =>
      isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted;
  Color get ink => isDark ? AppColors.darkInk : AppColors.stitchInk;
  Color get secondaryInk =>
      isDark ? AppColors.darkInkSecondary : AppColors.inkSecondary;
  Color get mutedInk => isDark ? AppColors.darkInkMuted : AppColors.inkMuted;
  Color get border => isDark ? AppColors.darkBorder : AppColors.border;
  Color get strongBorder =>
      isDark ? AppColors.darkBorder : AppColors.borderStrong;
  Color get primary => isDark ? AppColors.darkPrimary : AppColors.stitchPrimary;
  Color get positive => isDark ? AppColors.darkPositive : AppColors.positive;
  Color get warning => isDark ? AppColors.darkWarning : AppColors.warning;
  Color get danger => isDark ? AppColors.darkDanger : AppColors.danger;
  Color get secondary =>
      isDark ? AppColors.darkSecondary : AppColors.stitchSecondary;
  Color get accent => isDark ? AppColors.darkAccent : AppColors.stitchAccent;
  Color get insight => isDark
      ? AppColors.accent.withValues(alpha: .12)
      : AppColors.stitchInsight;
  Color get accentBorder => isDark
      ? AppColors.accent.withValues(alpha: .4)
      : AppColors.stitchAccentBorder;
  Color soft(Color foreground, Color light) =>
      isDark ? foreground.withValues(alpha: .12) : light;
}

extension FinanceThemeContext on BuildContext {
  FinancePalette get colors =>
      FinancePalette(Theme.of(this).brightness == Brightness.dark);
}
