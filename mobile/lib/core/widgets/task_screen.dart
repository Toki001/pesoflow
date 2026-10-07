import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

/// Task-focused screens suppress bottom navigation, as approved in Stitch.
class TaskScreen extends StatelessWidget {
  const TaskScreen({
    required this.title,
    required this.child,
    this.actions = const [],
    this.onClose,
    this.centerTitle = false,
    this.footer,
    this.backIcon = Icons.close,
    this.backTooltip = 'Close',
    this.fallbackRoute = '/transactions',
    super.key,
  });
  final String title;
  final VoidCallback? onClose;
  final bool centerTitle;
  final Widget child;
  final List<Widget> actions;
  final Widget? footer;
  final IconData backIcon;
  final String backTooltip;
  final String fallbackRoute;
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.colors.canvas,
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 512),
        child: Scaffold(
          backgroundColor: context.colors.canvas,
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  color: context.colors.surface,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: backTooltip,
                        onPressed: () {
                          if (onClose != null) {
                            onClose!();
                          } else if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(fallbackRoute);
                          }
                        },
                        icon: Icon(backIcon),
                      ),
                      Expanded(
                        child: Text(
                          title,
                          textAlign: centerTitle
                              ? TextAlign.center
                              : TextAlign.start,
                          style: AppTypography.headlineSmall,
                        ),
                      ),
                      ...actions,
                    ],
                  ),
                ),
                Expanded(child: child),
                ?footer,
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
