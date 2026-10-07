import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pesoflow/core/time/clock.dart';
import 'package:pesoflow/features/workspace/application/finance_controller.dart';
import 'package:pesoflow/features/dashboard/domain/dashboard.dart';
import 'package:pesoflow/features/dashboard/domain/financial_dashboard.dart';

final dashboardProvider = FutureProvider<Dashboard?>(
  (ref) async => financialDashboard(
    ref.watch(workspaceProvider),
    ref.watch(clockProvider)(),
  ),
  retry: (_, _) => null,
);
