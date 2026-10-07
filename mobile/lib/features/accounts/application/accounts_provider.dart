import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pesoflow/core/time/clock.dart';
import 'package:pesoflow/features/workspace/application/finance_controller.dart';
import 'package:pesoflow/features/accounts/domain/account_view.dart';
import 'package:pesoflow/features/accounts/domain/financial_account.dart';

class AccountsController extends AsyncNotifier<AccountsOverview> {
  @override
  Future<AccountsOverview> build() async {
    final w = ref.watch(workspaceProvider);
    final now = ref.watch(clockProvider)();
    return AccountsOverview([
      for (final a in w.accounts)
        AccountView(
          id: a.id,
          institution: a.institution,
          name: a.name,
          maskedIdentifier: a.maskedIdentifier,
          kind: a.type == AccountType.wallet
              ? AccountKind.wallet
              : a.type == AccountType.cash
              ? AccountKind.cash
              : AccountKind.bank,
          balance: accountBalance(
            a,
            w.ledger.where((t) => !t.occurredAt.isAfter(now)),
          ),
          balanceAsOf: a.reportedAt ?? now,
          manual: a.source == BalanceSource.manual,
          archived: a.archived,
        ),
    ]);
  }

  Future<void> disconnect(String id) async {
    final w = ref.read(workspaceProvider);
    final a = w.accounts.firstWhere((a) => a.id == id);
    final commands = ref.read(financeControllerProvider.notifier);
    if (w.ledger.any((t) => t.involvesAccount(id))) {
      await commands.saveAccount(a.copyWith(archived: !a.archived));
    } else {
      await commands.removeAccount(id);
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

final accountsProvider =
    AsyncNotifierProvider<AccountsController, AccountsOverview>(
      AccountsController.new,
      retry: (_, _) => null,
    );
