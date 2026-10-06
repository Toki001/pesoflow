import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/features/accounts/application/accounts_provider.dart';
import 'package:pesoflow/features/accounts/data/account_fixture.dart';
import 'package:pesoflow/features/accounts/domain/demo_account.dart';
import 'package:pesoflow/features/transactions/application/transactions_provider.dart';

class AccountsTestRepository implements DemoAccountsRepository {
  AccountsTestRepository({this.loadData, this.refreshData});
  final Future<List<DemoAccount>> Function()? loadData;
  final Future<void> Function()? refreshData;
  @override
  Future<List<DemoAccount>> load() async =>
      loadData == null ? accountFixture() : await loadData!();
  @override
  Future<void> refresh() async {
    if (refreshData != null) await refreshData!();
  }
}

void main() {
  test(
    'integer sample total excludes stale BPI, preserves masked provenance',
    () {
      final overview = AccountsOverview(accountFixture());
      expect(overview.availableBalance, 3450000);
      expect(overview.lastKnownBalance, 1220000);
      expect(overview.institutionCount, 4);
      expect(overview.accounts.last.needsReauthentication, true);
      expect(
        overview.accounts.every((a) => a.maskedIdentifier.contains('••••')),
        true,
      );
      expect(() => overview.accounts.clear(), throwsUnsupportedError);
      expect(
        () =>
            AccountsOverview([accountFixture().first, accountFixture().first]),
        throwsArgumentError,
      );
    },
  );
  test(
    'disconnect and add only change account list; duplicate additions fail',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(accountsProvider.future);
      final ledger = container.read(demoLedgerProvider);
      final controller = container.read(accountsProvider.notifier);
      controller.disconnect('gcash');
      expect(container.read(accountsProvider).value!.availableBalance, 3025000);
      expect(container.read(accountsProvider).value!.institutionCount, 3);
      expect(controller.addSample('gcash'), true);
      expect(controller.addSample('gcash'), false);
      expect(controller.addSample('unverified-provider'), false);
      expect(container.read(accountsProvider).value!.availableBalance, 3450000);
      expect(container.read(demoLedgerProvider), same(ledger));
    },
  );
  test(
    'refresh retains timestamps and balances and prevents concurrent calls',
    () async {
      final gate = Completer<void>();
      var calls = 0;
      final repository = AccountsTestRepository(
        refreshData: () {
          calls++;
          return gate.future;
        },
      );
      final container = ProviderContainer(
        overrides: [accountsRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      final original = await container.read(accountsProvider.future);
      final controller = container.read(accountsProvider.notifier);
      final pending = controller.refreshDemo();
      await controller.refreshDemo();
      expect(calls, 1);
      expect(container.read(accountsProvider).value!.refreshing, true);
      controller.disconnect('bdo');
      gate.complete();
      await pending;
      final after = container.read(accountsProvider).value!;
      expect(after.availableBalance, 610000);
      expect(after.checked, true);
      expect(
        after.accounts.first.balanceAsOf,
        original.accounts.first.balanceAsOf,
      );
      expect(after.accounts.last.needsReauthentication, true);
    },
  );
  test(
    'refresh errors keep cached accounts and retry clears safe error state',
    () async {
      var calls = 0;
      final container = ProviderContainer(
        overrides: [
          accountsRepositoryProvider.overrideWithValue(
            AccountsTestRepository(
              refreshData: () async {
                if (calls++ == 0) throw Exception('secret failure');
              },
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(accountsProvider.future);
      final controller = container.read(accountsProvider.notifier);
      await controller.refreshDemo();
      expect(container.read(accountsProvider).value!.refreshError, true);
      expect(container.read(accountsProvider).value!.availableBalance, 3450000);
      await controller.refreshDemo();
      expect(container.read(accountsProvider).value!.refreshError, false);
      expect(container.read(accountsProvider).value!.checked, true);
    },
  );
  test(
    'last stale profile remains excluded after removal and sample restoration',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(accountsProvider.future);
      final controller = container.read(accountsProvider.notifier);
      for (final a in accountFixture()) {
        controller.disconnect(a.id);
      }
      expect(container.read(accountsProvider).value!.availableBalance, 0);
      expect(container.read(accountsProvider).value!.accounts, isEmpty);
      expect(controller.addSample('bpi'), true);
      expect(container.read(accountsProvider).value!.availableBalance, 0);
      expect(container.read(accountsProvider).value!.lastKnownBalance, 1220000);
    },
  );
}
