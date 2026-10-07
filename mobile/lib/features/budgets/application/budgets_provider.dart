import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pesoflow/core/identity/new_id.dart';
import 'package:pesoflow/core/time/clock.dart';
import 'package:pesoflow/features/workspace/application/finance_controller.dart';
import 'package:pesoflow/features/analytics/domain/analytics_report.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';
import 'package:pesoflow/features/budgets/domain/budget_plan.dart';
import 'package:pesoflow/features/budgets/domain/spending_budget.dart';

class BudgetPlans extends Notifier<Map<String, BudgetPlan>> {
  @override
  Map<String, BudgetPlan> build() {
    final date = ref.watch(budgetPeriodProvider);
    ref.watch(workspaceProvider);
    final plan = viewFor(date.year, date.month);
    return {plan.key: plan};
  }

  BudgetPlan viewFor(int year, int month) {
    final w = ref.read(workspaceProvider);
    final now = ref.read(clockProvider)();
    final date = DateTime(year, month);
    final plans = w.budgets
        .where(
          (b) =>
              b.enabled &&
              b.period == AnalyticsPeriod.month &&
              !date.isBefore(DateTime(b.startDate.year, b.startDate.month)),
        )
        .toList();
    final overall = plans.where((b) => b.category == null);
    final progress = overall.isEmpty
        ? null
        : evaluateBudget(overall.first, w.ledger, now, selectedDate: date);
    return BudgetPlan(
      year: year,
      month: month,
      monthlyLimit: progress?.budget.limit ?? 0,
      spent: progress?.spent ?? 0,
      projectedAdditional: progress == null
          ? null
          : progress.projectedSpend - progress.spent,
      allowances: [
        for (final b in plans.where((b) => b.category != null))
          () {
            final p = evaluateBudget(b, w.ledger, now, selectedDate: date);
            return BudgetAllowance(
              category: b.category!,
              description: 'Monthly spending allowance',
              limit: b.limit,
              spent: p.spent,
              projectedAdditional: p.projectedSpend - p.spent,
            );
          }(),
      ],
    );
  }

  Future<void> setLimit(
    int year,
    int month,
    TransactionCategory? category,
    int limit,
  ) async {
    final existing = ref
        .read(workspaceProvider)
        .budgets
        .where(
          (b) => b.period == AnalyticsPeriod.month && b.category == category,
        );
    final b = existing.isEmpty
        ? SpendingBudget(
            id: newId(),
            name: category == null ? 'Monthly budget' : categoryLabel(category),
            limit: limit,
            period: AnalyticsPeriod.month,
            startDate: DateTime(year, month),
            category: category,
          )
        : existing.first.copyWith(limit: limit, enabled: true);
    await ref.read(financeControllerProvider.notifier).saveBudget(b);
  }

  Future<void> remove(TransactionCategory? category) async {
    final matches = ref
        .read(workspaceProvider)
        .budgets
        .where(
          (b) => b.period == AnalyticsPeriod.month && b.category == category,
        );
    if (matches.isNotEmpty) {
      await ref
          .read(financeControllerProvider.notifier)
          .deleteBudget(matches.first.id);
    }
  }

  Future<void> reallocate(
    int year,
    int month,
    TransactionCategory from,
    TransactionCategory to,
    int amount,
  ) async {
    final budgets = ref.read(workspaceProvider).budgets;
    String idFor(TransactionCategory c) => budgets
        .firstWhere((b) => b.category == c && b.period == AnalyticsPeriod.month)
        .id;
    await ref
        .read(financeControllerProvider.notifier)
        .reallocateBudgets(
          idFor(from),
          idFor(to),
          amount,
          DateTime(year, month),
        );
  }
}

final budgetPlansProvider =
    NotifierProvider<BudgetPlans, Map<String, BudgetPlan>>(BudgetPlans.new);

class BudgetPeriodController extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = ref.read(clockProvider)();
    return DateTime(now.year, now.month);
  }

  void select(DateTime date) => state = DateTime(date.year, date.month);
}

final budgetPeriodProvider = NotifierProvider<BudgetPeriodController, DateTime>(
  BudgetPeriodController.new,
);
final budgetsProvider = FutureProvider<BudgetPlan>((ref) async {
  final date = ref.watch(budgetPeriodProvider);
  ref.watch(budgetPlansProvider);
  return ref.read(budgetPlansProvider.notifier).viewFor(date.year, date.month);
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
  final from = plan.allowances
      .where((a) => a.category == TransactionCategory.entertainment)
      .firstOrNull;
  final to = plan.allowances
      .where((a) => a.category == TransactionCategory.food)
      .firstOrNull;
  return from != null &&
      to != null &&
      to.atRisk &&
      from.limit > 50000 &&
      from.limit - (from.projectedEndTotal ?? from.spent) >= 50000;
}
