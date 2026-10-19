import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_backdrop.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../core/widgets/navigation_panel.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.shell, super.key});
  final StatefulNavigationShell shell;
  @override
  Widget build(BuildContext context) => AppBackdrop(
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 512),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: shell,
          bottomNavigationBar: AppBottomNavigation(
            selectedIndex: shell.currentIndex >= 2
                ? shell.currentIndex + 1
                : shell.currentIndex,
            onSelected: (index) {
              if (index == 2) {
                context.push('/add');
              } else {
                shell.goBranch(index > 2 ? index - 1 : index);
              }
            },
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
  static const selectedIcons = [
    Icons.home,
    Icons.receipt_long,
    Icons.add,
    Icons.analytics,
    Icons.account_balance_wallet,
  ];
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final height = math.max(
      72.0,
      72 + (MediaQuery.textScalerOf(context).scale(11) - 11) * 6,
    );
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: NavigationPanel(
          child: SizedBox(
            height: height,
            child: Row(
              children: List.generate(destinations.length, (index) {
                final active = selectedIndex == index;
                return Expanded(
                  child: Semantics(
                    selected: active,
                    button: true,
                    label: destinations[index],
                    child: Tooltip(
                      message: destinations[index],
                      child: InkWell(
                        key: ValueKey('nav-${destinations[index]}'),
                        splashFactory: NoSplash.splashFactory,
                        overlayColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.focused)
                              ? c.primary.withValues(alpha: .10)
                              : Colors.transparent,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => onSelected(index),
                        child: ExcludeSemantics(
                          child: SizedBox.expand(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (index == 2)
                                  Container(
                                    width: 44,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFFDBEAFE),
                                          Color(0xFFBFDBFE),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: AppColors.primary,
                                      size: 26,
                                    ),
                                  )
                                else
                                  Container(
                                    width: 44,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: active ? AppColors.primary : null,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      active
                                          ? selectedIcons[index]
                                          : icons[index],
                                      size: 22,
                                      color: active ? Colors.white : c.icon,
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    destinations[index],
                                    maxLines: 1,
                                    softWrap: false,
                                    textAlign: TextAlign.center,
                                    style: AppTypography.labelSmall.copyWith(
                                      color: active ? c.primary : c.mutedInk,
                                      letterSpacing: 0,
                                    ),
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
      ),
    );
  }
}
