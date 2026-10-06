import 'package:freezed_annotation/freezed_annotation.dart';

import '../../transactions/domain/transaction.dart';
export '../../transactions/domain/transaction.dart';

part 'dashboard.freezed.dart';
part 'dashboard.g.dart';

@freezed
abstract class Dashboard with _$Dashboard {
  const factory Dashboard({
    required String name,
    required DateTime asOf,
    required int balance,
    required int monthChange,
    required String monthChangePercent,
    required int inflow,
    required int outflow,
    required int savings,
    required String savingsRate,
    required int transactionCount,
    required int accountCount,
    required int budgetLimit,
    required int daysLeft,
    required int projectedExtraSavings,
    required List<BudgetSnapshot> budgets,
    required List<TransactionRecord> transactions,
    required List<UpcomingBill> bills,
  }) = _Dashboard;
  factory Dashboard.fromJson(Map<String, dynamic> json) =>
      _$DashboardFromJson(json);
}

@freezed
abstract class BudgetSnapshot with _$BudgetSnapshot {
  const BudgetSnapshot._();
  const factory BudgetSnapshot({
    required String name,
    required int spent,
    required int limit,
    required String status,
  }) = _BudgetSnapshot;
  factory BudgetSnapshot.fromJson(Map<String, dynamic> json) =>
      _$BudgetSnapshotFromJson(json);
  int get remaining => limit - spent;
  double get used => limit <= 0 ? 0 : spent / limit;
  bool get approaching => limit > 0 && spent * 100 >= limit * 80;
  bool get exceeded => limit > 0 && spent >= limit;
}

@freezed
abstract class UpcomingBill with _$UpcomingBill {
  const factory UpcomingBill({
    required String name,
    required int amount,
    required int daysUntilDue,
    @Default(false) bool estimated,
  }) = _UpcomingBill;
  factory UpcomingBill.fromJson(Map<String, dynamic> json) =>
      _$UpcomingBillFromJson(json);
}
