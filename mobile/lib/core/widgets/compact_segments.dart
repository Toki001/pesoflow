import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

/// Slim visible pills inside full-height, non-overlapping touch targets.
class CompactSegments<T> extends StatelessWidget {
  const CompactSegments({
    required this.options,
    required this.selected,
    required this.onSelected,
    this.itemKey,
    super.key,
  });
  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final Key Function(T)? itemKey;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.mutedSurface.withValues(alpha: .48),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final entry in options.entries)
            Flexible(
              child: Semantics(
                button: true,
                selected: selected == entry.key,
                child: InkWell(
                  key: itemKey?.call(entry.key),
                  borderRadius: BorderRadius.circular(24),
                  splashFactory: NoSplash.splashFactory,
                  onTap: () => onSelected(entry.key),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: 48,
                      minWidth: 48,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: selected == entry.key
                              ? c.surface
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: selected == entry.key
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: .07),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Center(
                            heightFactor: 1,
                            child: Text(
                              entry.value,
                              style: AppTypography.labelSmall.copyWith(
                                color: selected == entry.key
                                    ? c.primary
                                    : c.mutedInk,
                              ),
                            ),
                          ),
                        ),
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
