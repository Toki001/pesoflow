import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/account_fixture.dart';
import '../domain/demo_account.dart';

final demoAccountCatalogProvider = Provider<List<DemoAccount>>(
  (ref) => accountFixture(),
);
final accountsRepositoryProvider = Provider<DemoAccountsRepository>(
  (ref) => const FixtureAccountsRepository(),
);

class DemoAccounts extends AsyncNotifier<AccountsOverview> {
  @override
  Future<AccountsOverview> build() async =>
      AccountsOverview(await ref.watch(accountsRepositoryProvider).load());
  void disconnect(String id) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        accounts: current.accounts.where((a) => a.id != id).toList(),
      ),
    );
  }

  bool addSample(String id) {
    final current = state.value;
    if (current == null || current.accounts.any((a) => a.id == id)) {
      return false;
    }
    final matches = ref
        .read(demoAccountCatalogProvider)
        .where((a) => a.id == id);
    if (matches.isEmpty) {
      return false;
    }
    state = AsyncData(
      current.copyWith(accounts: [...current.accounts, matches.single]),
    );
    return true;
  }

  Future<void> refreshDemo() async {
    final current = state.value;
    if (current == null || current.refreshing) return;
    final repository = ref.read(accountsRepositoryProvider);
    state = AsyncData(
      current.copyWith(refreshing: true, refreshError: false, checked: false),
    );
    try {
      await repository.refresh();
      if (!ref.mounted) return;
      final latest = state.value;
      if (latest != null) {
        state = AsyncData(latest.copyWith(refreshing: false, checked: true));
      }
    } catch (_) {
      if (!ref.mounted) return;
      final latest = state.value;
      if (latest != null) {
        state = AsyncData(
          latest.copyWith(refreshing: false, refreshError: true),
        );
      }
    }
  }
}

final accountsProvider = AsyncNotifierProvider<DemoAccounts, AccountsOverview>(
  DemoAccounts.new,
  retry: (_, _) => null,
);
