import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader(
    this.title, {
    this.action,
    this.onAction,
    this.caption,
    super.key,
  });
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final String? caption;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(title, style: AppTypography.headlineSmall)),
      if (action != null)
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: Text(action!),
        ),
      if (caption != null)
        Text(
          caption!,
          style: AppTypography.labelSmall.copyWith(
            color: context.colors.mutedInk,
          ),
        ),
    ],
  );
}
