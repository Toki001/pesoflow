import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dashboard_fixture.dart';
import '../domain/dashboard.dart';
import '../domain/dashboard_repository.dart';
import '../domain/demo_dashboard_projection.dart';
import '../../transactions/application/transactions_provider.dart';
import '../../transactions/data/transaction_fixture.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => const FixtureDashboardRepository(),
);
final dashboardProvider = FutureProvider<Dashboard?>((ref) async {
  final ledger = ref.watch(demoLedgerProvider);
  final base = await ref.watch(dashboardRepositoryProvider).load();
  return base == null
      ? null
      : projectDemoLedger(base, ledger, transactionFixture());
}, retry: (_, _) => null);
