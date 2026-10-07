import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pesoflow/core/time/clock.dart';
import 'package:pesoflow/features/workspace/application/finance_controller.dart';
import 'package:pesoflow/features/receipts/application/receipts_provider.dart';

import '../fixtures/finance_workspace_fixture.dart';
import '../fixtures/features/receipts/data/receipt_fixture.dart';
import '../fixtures/features/subscriptions/data/subscription_fixture.dart';
import 'finance_fakes.dart';

ProviderContainer fixtureContainer({bool receipt = true}) {
  final repo = FakeFinanceRepository(
    financeFixture().copyWith(subscriptions: subscriptionFixture()),
  );
  return ProviderContainer(
    overrides: [
      initialWorkspaceProvider.overrideWithValue(repo.workspace),
      financeRepositoryProvider.overrideWithValue(repo),
      clockProvider.overrideWithValue(() => DateTime(2024, 10, 24, 12, 35)),
      receiptLoaderProvider.overrideWithValue(
        () async => receipt ? receiptFixture() : null,
      ),
    ],
  );
}
