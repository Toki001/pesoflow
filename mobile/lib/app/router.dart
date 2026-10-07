import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/backups/presentation/backup_screen.dart';

import 'package:pesoflow/features/workspace/application/finance_controller.dart';
import 'package:pesoflow/features/dashboard/presentation/home_screen.dart';
import 'package:pesoflow/features/budgets/presentation/budgets_screen.dart';
import 'package:pesoflow/features/analytics/presentation/analytics_screen.dart';
import 'package:pesoflow/features/accounts/presentation/accounts_screen.dart';
import 'package:pesoflow/features/accounts/presentation/account_detail_screen.dart';
import 'package:pesoflow/features/transactions/presentation/transactions_screen.dart';
import 'package:pesoflow/features/transactions/presentation/transaction_detail_screen.dart';
import 'package:pesoflow/features/expense/presentation/add_expense_screen.dart';
import 'package:pesoflow/features/subscriptions/presentation/subscriptions_screen.dart';

import 'package:pesoflow/features/onboarding/presentation/onboarding_screen.dart';
import 'package:pesoflow/features/settings/presentation/settings_screen.dart';
import 'package:pesoflow/features/notifications/presentation/notifications_screen.dart';

import 'package:pesoflow/app/shell/app_shell.dart';
import 'package:pesoflow/app/theme/app_spacing.dart';
import 'package:pesoflow/app/theme/app_typography.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Read once at startup: completing the introduction must not recreate navigation.
  final completed = ref
      .read(initialWorkspaceProvider)
      .preferences
      .onboardingCompleted;
  final router = createRouter(
    initialLocation: completed ? '/home' : '/onboarding',
  );
  ref.onDispose(router.dispose);
  return router;
});

GoRouter createRouter({String initialLocation = '/onboarding'}) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    GoRoute(
      path: '/',
      redirect: (_, _) => initialLocation == '/home' ? '/home' : '/onboarding',
    ),
    GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
    GoRoute(
      path: '/subscriptions',
      redirect: (_, _) => '/budgets/subscriptions',
    ),
    GoRoute(path: '/add', builder: (_, _) => const AddExpenseScreen()),
    GoRoute(
      path: '/receipt',
      builder: (_, _) => const Scaffold(
        body: FoundationDestination(
          title: 'Receipt scanning is not available yet',
        ),
      ),
    ),
    GoRoute(path: '/accounts', builder: (_, _) => const AccountsScreen()),
    GoRoute(
      path: '/connections',
      builder: (_, state) => const Scaffold(
        body: FoundationDestination(title: 'Connections are not configured'),
      ),
    ),
    GoRoute(
      path: '/accounts/:id',
      builder: (_, state) =>
          AccountDetailScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
    GoRoute(
      path: '/settings/backup',
      builder: (_, _) => const BackupSettingsScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (_, _) => const NotificationsScreen(),
    ),
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

/// Fallback for unavailable routes.
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
              'This feature is not available yet. Manual tracking remains available.',
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
