import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/dashboard/presentation/home_screen.dart';
import '../features/budgets/presentation/budgets_screen.dart';
import '../features/analytics/presentation/analytics_screen.dart';
import '../features/accounts/presentation/accounts_screen.dart';
import '../features/transactions/presentation/transactions_screen.dart';
import '../features/transactions/presentation/transaction_detail_screen.dart';
import '../features/expense/presentation/add_expense_screen.dart';
import '../features/subscriptions/presentation/subscriptions_screen.dart';
import 'shell/app_shell.dart';
import 'theme/app_spacing.dart';
import 'theme/app_typography.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = createRouter();
  ref.onDispose(router.dispose);
  return router;
});

GoRouter createRouter({String initialLocation = '/home'}) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    GoRoute(path: '/', redirect: (_, _) => '/home'),
    GoRoute(
      path: '/subscriptions',
      redirect: (_, _) => '/budgets/subscriptions',
    ),
    GoRoute(path: '/add', builder: (_, _) => const AddExpenseScreen()),
    GoRoute(path: '/accounts', builder: (_, _) => const AccountsScreen()),
    GoRoute(
      path: '/transactions/:id',
      builder: (_, state) =>
          TransactionDetailScreen(id: state.pathParameters['id']!),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
          ],
        ),
        for (final path in ['/transactions', '/analytics', '/budgets'])
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: path,
                routes: [
                  if (path == '/budgets')
                    GoRoute(
                      path: 'subscriptions',
                      builder: (_, _) => const SubscriptionsScreen(),
                    ),
                ],
                builder: (_, _) => path == '/transactions'
                    ? const TransactionsScreen()
                    : path == '/budgets'
                    ? const BudgetsScreen()
                    : const AnalyticsScreen(),
              ),
            ],
          ),
      ],
    ),
  ],
  errorBuilder: (_, _) =>
      const Scaffold(body: FoundationDestination(title: 'Page not found')),
);

/// Navigation boundary; other approved screens are not implemented yet.
class FoundationDestination extends StatelessWidget {
  const FoundationDestination({required this.title, super.key});
  final String title;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: AppTypography.headlineMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'This screen is not available in the demo yet.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () => context.go('/home'),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
