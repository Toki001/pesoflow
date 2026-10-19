import 'package:flutter/material.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/compact_segments.dart';

class AnalyticsSegments<T> extends CompactSegments<T> {
  const AnalyticsSegments({
    required super.options,
    required super.selected,
    required super.onSelected,
    super.key,
  });
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
