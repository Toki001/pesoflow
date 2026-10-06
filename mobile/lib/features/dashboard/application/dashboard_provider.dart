import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dashboard_fixture.dart';
import '../domain/dashboard.dart';
import '../domain/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => const FixtureDashboardRepository(),
);
final dashboardProvider = FutureProvider<Dashboard?>(
  (ref) => ref.watch(dashboardRepositoryProvider).load(),
  retry: (_, _) => null,
);
