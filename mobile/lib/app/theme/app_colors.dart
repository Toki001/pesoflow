import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF2563EB);
  static const primaryStrong = Color(0xFF1D4ED8);
  static const primarySoft = Color(0xFFDBEAFE);
  static const secondary = Color(0xFF2563EB);
  static const secondarySoft = Color(0xFFEFF6FF);
  static const accent = Color(0xFF2563EB);
  static const accentSoft = Color(0xFFEFF6FF);
  static const positive = Color(0xFF16A34A);
  static const positiveText = Color(0xFF166534);
  static const warningText = Color(0xFF92400E);
  static const dangerText = Color(0xFF991B1B);
  static const darkIcon = Color(0xFF60A5FA);
  static const positiveSoft = Color(0xFFDCFCE7);
  static const warning = Color(0xFFD97706);
  static const warningSoft = Color(0xFFFEF3C7);
  static const danger = Color(0xFFDC2626);
  static const dangerSoft = Color(0xFFFEE2E2);
  static const ink = Color(0xFF111827);
  static const inkSecondary = Color(0xFF596779);
  static const inkMuted = Color(0xFF596779);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSubtle = Color(0xFFF5F7FC);
  static const surfaceMuted = Color(0xFFF3F4F6);
  static const border = Color(0xFFE5E7EB);
  static const borderStrong = Color(0xFFCBD5E1);
  static const darkSurface = Color(0xFF0A1020);
  static const darkSurfaceSubtle = Color(0xFF111D32);
  static const darkSurfaceMuted = Color(0xFF1A2A44);
  static const darkInk = Color(0xFFF7F8FA);
  static const darkInkSecondary = Color(0xFFCBD5E1);
  static const darkInkMuted = Color(0xFFBBC6D5);
  static const darkBorder = Color(0xFF334155);

  // Compatibility aliases for shared widgets; v7 uses one interaction blue.
  static const stitchPrimary = Color(0xFF2563EB);
  static const stitchInk = Color(0xFF111827);
  static const stitchSecondary = Color(0xFF2563EB);
  static const stitchAccent = Color(0xFF2563EB);
  static const stitchAccentBorder = Color(0xFFDBEAFE);
  static const stitchInsight = Color(0xFFEFF6FF);
  static const darkPrimary = Color(0xFF93C5FD);
  static const darkPositive = Color(0xFF86EFAC);
  static const darkWarning = Color(0xFFFBBF24);
  static const darkDanger = Color(0xFFFCA5A5);
  static const darkSecondary = Color(0xFF93C5FD);
  static const darkAccent = Color(0xFF93C5FD);
}

/// Semantic roles keep components independent of the active brightness.
class FinancePalette {
  const FinancePalette(this.isDark);
  final bool isDark;
  Color get canvas => isDark ? const Color(0xFF0A1016) : Colors.white;
  Color get surface => isDark ? AppColors.darkSurfaceSubtle : AppColors.surface;
  Color get mutedSurface =>
      isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted;
  Color get ink => isDark ? AppColors.darkInk : AppColors.ink;
  Color get secondaryInk =>
      isDark ? AppColors.darkInkSecondary : AppColors.inkSecondary;
  Color get mutedInk => isDark ? AppColors.darkInkMuted : AppColors.inkMuted;
  Color get border => isDark ? AppColors.darkBorder : AppColors.border;
  Color get strongBorder =>
      isDark ? AppColors.darkBorder : AppColors.borderStrong;
  Color get primary => isDark ? AppColors.darkPrimary : const Color(0xFF1E40AF);
  Color get positive =>
      isDark ? AppColors.darkPositive : AppColors.positiveText;
  Color get warning => isDark ? AppColors.darkWarning : AppColors.warningText;
  Color get danger => isDark ? AppColors.darkDanger : AppColors.dangerText;
  Color get secondary => primary;
  Color get accent => primary;
  Color get insight => isDark
      ? AppColors.accent.withValues(alpha: .12)
      : AppColors.stitchInsight;
  Color get accentBorder => isDark
      ? AppColors.accent.withValues(alpha: .4)
      : AppColors.stitchAccentBorder;
  Color get icon => isDark ? const Color(0xFFB8C4D3) : const Color(0xFF64748B);
  // Neutral chrome follows the actual surface, including pale badges in Dark.
  Color iconOn(Color background) =>
      Color.alphaBlend(background, surface).computeLuminance() < .15
      ? const Color(0xFFB8C4D3)
      : const Color(0xFF64748B);

  Color progress(Color foreground) {
    if (isDark) return foreground;
    if (foreground == primary) return AppColors.primary;
    if (foreground == positive) return AppColors.positive;
    if (foreground == warning) return AppColors.warning;
    if (foreground == danger) return AppColors.danger;
    return foreground;
  }

  Color soft(Color foreground, Color light) =>
      isDark ? foreground.withValues(alpha: .10) : light;
}

extension FinanceThemeContext on BuildContext {
  FinancePalette get colors =>
      FinancePalette(Theme.of(this).brightness == Brightness.dark);
}
