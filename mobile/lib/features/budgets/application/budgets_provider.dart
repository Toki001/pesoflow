import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transactions/application/transactions_provider.dart';
import '../../transactions/data/transaction_fixture.dart';
import '../../transactions/domain/transaction.dart';
import '../data/budget_fixture.dart';
import '../domain/budget_plan.dart';

class DemoBudgetPlans extends Notifier<Map<String, BudgetPlan>> {
  @override
  Map<String, BudgetPlan> build() {
    final fixture = budgetFixture();
    return Map.unmodifiable({fixture.key: fixture});
  }

  BudgetPlan baseFor(int year, int month) =>
      state['$year-$month'] ??
      BudgetPlan(
        year: year,
        month: month,
        monthlyLimit: 0,
        allowances: const [],
      );
  BudgetPlan viewFor(int year, int month) => projectBudgetLedger(
    baseFor(year, month),
    ref.read(demoLedgerProvider),
    transactionFixture(),
  );
  void setLimit(int year, int month, TransactionCategory? category, int limit) {
    final base = baseFor(year, month);
    // Validate against the base plan; ledger projection must never be persisted twice.
    var next = base.withLimit(category, limit);
    if (category != null &&
        !base.allowances.any((a) => a.category == category)) {
      final knownSpend = transactionFixture()
          .where(
            (t) =>
                t.category == category &&
                t.occurredAt.year == year &&
                t.occurredAt.month == month,
          )
          .fold<int>(0, (sum, t) => sum + t.budgetImpact);
      next = next.copyWith(
        allowances: [
          for (final a in next.allowances)
            if (a.category == category) a.copyWith(spent: knownSpend) else a,
        ],
      );
    }
    state = Map.unmodifiable({...state, next.key: next});
  }

  void reallocate(
    int year,
    int month,
    TransactionCategory from,
    TransactionCategory to,
    int amount,
  ) {
    final adjusted = viewFor(year, month).reallocate(from, to, amount);
    final limits = {for (final a in adjusted.allowances) a.category: a.limit};
    final base = baseFor(year, month);
    final next = base.copyWith(
      editedCategories: adjusted.editedCategories,
      allowances: [
        for (final a in base.allowances) a.copyWith(limit: limits[a.category]!),
      ],
    );
    state = Map.unmodifiable({...state, next.key: next});
  }
}

final demoBudgetPlansProvider =
    NotifierProvider<DemoBudgetPlans, Map<String, BudgetPlan>>(
      DemoBudgetPlans.new,
    );

class BudgetPeriodController extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime(2024, 10);
  void select(DateTime date) => state = DateTime(date.year, date.month);
}

final budgetPeriodProvider = NotifierProvider<BudgetPeriodController, DateTime>(
  BudgetPeriodController.new,
);

final budgetsProvider = FutureProvider<BudgetPlan>((ref) async {
  final date = ref.watch(budgetPeriodProvider);
  final plans = ref.watch(demoBudgetPlansProvider);
  final ledger = ref.watch(demoLedgerProvider);
  final base =
      plans['${date.year}-${date.month}'] ??
      BudgetPlan(
        year: date.year,
        month: date.month,
        monthlyLimit: 0,
        allowances: const [],
      );
  return projectBudgetLedger(base, ledger, transactionFixture());
}, retry: (_, _) => null);

class DismissedBudgetSuggestions extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};
  void dismiss(String key) => state = Set.unmodifiable({...state, key});
}

final dismissedBudgetSuggestionsProvider =
    NotifierProvider<DismissedBudgetSuggestions, Set<String>>(
      DismissedBudgetSuggestions.new,
    );

bool canSuggestReallocation(BudgetPlan plan) {
  final food = plan.allowances.where(
    (a) => a.category == TransactionCategory.food,
  );
  final leisure = plan.allowances.where(
    (a) => a.category == TransactionCategory.entertainment,
  );
  return food.isNotEmpty &&
      leisure.isNotEmpty &&
      food.single.projectedOverage > 0 &&
      leisure.single.remaining >= 50000 &&
      leisure.single.limit > 50000;
}
