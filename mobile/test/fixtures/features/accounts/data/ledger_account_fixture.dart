import 'package:pesoflow/features/accounts/domain/ledger_account.dart';

/// Distinct products retain distinct identities even at the same institution.
abstract final class DemoLedgerAccounts {
  static const gcash = LedgerAccount(id: 'gcash', label: 'GCash');
  static const maya = LedgerAccount(id: 'maya', label: 'Maya');
  static const bdo = LedgerAccount(id: 'bdo', label: 'BDO Checking');
  static const bpi = LedgerAccount(id: 'bpi', label: 'BPI Savings');
  static const bdoDebit = LedgerAccount(id: 'bdo-debit', label: 'BDO Debit');
  static const bdoSavings = LedgerAccount(
    id: 'bdo-savings',
    label: 'BDO Savings',
  );
  static const bdoCredit = LedgerAccount(
    id: 'bdo-credit',
    label: 'BDO Credit Card',
  );
  static const cash = LedgerAccount(id: 'cash', label: 'Cash');
  static const all = [
    gcash,
    maya,
    bdo,
    bpi,
    bdoDebit,
    bdoSavings,
    bdoCredit,
    cash,
  ];
  static LedgerAccount? byId(String id) {
    for (final account in all) {
      if (account.id == id) return account;
    }
    return null;
  }
}
