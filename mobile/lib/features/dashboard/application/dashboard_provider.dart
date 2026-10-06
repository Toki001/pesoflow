import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dashboard_fixture.dart';
import '../domain/dashboard.dart';
import '../domain/dashboard_repository.dart';
import '../domain/demo_dashboard_projection.dart';
import '../../transactions/application/transactions_provider.dart';
import '../../transactions/data/transaction_fixture.dart';
import '../../budgets/application/budgets_provider.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => const FixtureDashboardRepository(),
);
final dashboardProvider = FutureProvider<Dashboard?>((ref) async {
  final ledger = ref.watch(demoLedgerProvider);
  final plans = ref.watch(demoBudgetPlansProvider);
  final base = await ref.watch(dashboardRepositoryProvider).load();
  if (base == null) return null;
  final projected = projectDemoLedger(base, ledger, transactionFixture());
  final plan = plans['${base.asOf.year}-${base.asOf.month}'];
  if (plan == null) return projected;
  final overrides = {
    for (final a in plan.allowances)
      if (plan.editedCategories.contains(a.category)) a.name: a.limit,
  };
  return projected.copyWith(
    budgetLimit: plan.monthlyLimit,
    budgets: [
      for (final b in projected.budgets)
        if (overrides[b.name] case final limit?)
          b.copyWith(
            limit: limit,
            status: b.spent >= limit
                ? b.spent == limit
                      ? 'Limit reached'
                      : 'Above limit'
                : b.spent * 100 >= limit * 80
                ? 'Slow down slightly'
                : 'On track',
          )
        else
          b,
    ],
  );
}, retry: (_, _) => null);
