import '../../transactions/data/transaction_fixture.dart';

import 'package:pesoflow/features/accounts/domain/account_view.dart';

import 'ledger_account_fixture.dart';

List<AccountView> accountFixture() => List.unmodifiable([
  AccountView(
    id: DemoLedgerAccounts.gcash.id,
    institution: 'GCash',
    name: 'GCash Personal',
    maskedIdentifier: '0917 •••• 892',
    kind: AccountKind.wallet,
    balance: 425000,
    balanceAsOf: demoClock.subtract(const Duration(minutes: 5)),
  ),
  AccountView(
    id: DemoLedgerAccounts.bdo.id,
    institution: 'BDO Unibank',
    name: 'BDO Online Checking',
    maskedIdentifier: 'Account •••• 4120',
    kind: AccountKind.bank,
    balance: 2840000,
    balanceAsOf: demoClock.subtract(const Duration(hours: 1)),
  ),
  AccountView(
    id: DemoLedgerAccounts.maya.id,
    institution: 'Maya',
    name: 'Maya Wallet',
    maskedIdentifier: '0918 •••• 331',
    kind: AccountKind.wallet,
    balance: 185000,
    balanceAsOf: demoClock.subtract(const Duration(minutes: 12)),
  ),
  AccountView(
    id: DemoLedgerAccounts.bpi.id,
    institution: 'BPI',
    name: 'BPI Savings',
    maskedIdentifier: 'Account •••• 8841',
    kind: AccountKind.bank,
    balance: 1220000,
    balanceAsOf: demoClock.subtract(const Duration(days: 2)),
    status: AccountConnectionStatus.needsReauthentication,
  ),
]);
