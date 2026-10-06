import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.shell, super.key});
  final StatefulNavigationShell shell;
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.colors.canvas,
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 512),
        child: Scaffold(
          body: shell,
          bottomNavigationBar: AppBottomNavigation(
            selectedIndex: shell.currentIndex,
            onSelected: (index) => shell.goBranch(index),
          ),
        ),
      ),
    ),
  );
}

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  static const destinations = [
    'Home',
    'Transactions',
    'Add',
    'Analytics',
    'Budgets',
  ];
  static const icons = [
    Icons.home_outlined,
    Icons.receipt_long_outlined,
    Icons.add,
    Icons.analytics_outlined,
    Icons.account_balance_wallet_outlined,
  ];
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final height = math.max(
      64.0,
      64 + (MediaQuery.textScalerOf(context).scale(11) - 11) * 6,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: height,
          child: Row(
            children: List.generate(destinations.length, (index) {
              final active = selectedIndex == index;
              final color = active ? c.primary : c.mutedInk;
              return Expanded(
                child: Semantics(
                  selected: active,
                  button: true,
                  label: destinations[index],
                  child: Tooltip(
                    message: destinations[index],
                    child: InkWell(
                      key: ValueKey('nav-${destinations[index]}'),
                      onTap: () => onSelected(index),
                      child: ExcludeSemantics(
                        child: SizedBox.expand(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (index == 2)
                                Transform.translate(
                                  offset: const Offset(0, -6),
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: AppColors.surface,
                                      size: 26,
                                    ),
                                  ),
                                )
                              else
                                Icon(
                                  active && index == 0
                                      ? Icons.home
                                      : icons[index],
                                  size: 22,
                                  color: color,
                                ),
                              const SizedBox(height: 2),
                              Text(
                                destinations[index],
                                textAlign: TextAlign.center,
                                style: AppTypography.labelSmall.copyWith(
                                  color: color,
                                  letterSpacing: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
