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
    this.footer,
    super.key,
  });
  final String title;
  final Widget child;
  final List<Widget> actions;
  final Widget? footer;
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
                        tooltip: 'Close',
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/transactions');
                          }
                        },
                        icon: const Icon(Icons.close),
                      ),
                      Expanded(
                        child: Text(title, style: AppTypography.headlineSmall),
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
