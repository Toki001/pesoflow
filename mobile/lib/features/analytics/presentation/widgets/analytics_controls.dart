import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';

/// The approved Analytics segmented controls, with native 48px targets.
class AnalyticsSegments<T> extends StatelessWidget {
  const AnalyticsSegments({
    required this.options,
    required this.selected,
    required this.onSelected,
    super.key,
  });
  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onSelected;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: c.mutedSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final entry in options.entries)
            Flexible(
              child: Semantics(
                selected: selected == entry.key,
                button: true,
                child: InkWell(
                  onTap: () => onSelected(entry.key),
                  borderRadius: BorderRadius.circular(AppRadius.micro),
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: 48,
                      minWidth: 44,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 8,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected == entry.key ? c.surface : null,
                      borderRadius: BorderRadius.circular(AppRadius.micro),
                    ),
                    child: Text(
                      entry.value,
                      style: AppTypography.labelSmall.copyWith(
                        color: selected == entry.key ? c.primary : c.mutedInk,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AnalyticsHeading extends StatelessWidget {
  const AnalyticsHeading(this.title, {this.trailing, super.key});
  final String title;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) {
      final stacked =
          bounds.maxWidth < 300 ||
          MediaQuery.textScalerOf(context).scale(14) > 19;
      return stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.headlineSmall),
                if (trailing != null) ...[const SizedBox(height: 8), trailing!],
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Text(title, style: AppTypography.headlineSmall),
                ),
                ?trailing,
              ],
            );
    },
  );
}
