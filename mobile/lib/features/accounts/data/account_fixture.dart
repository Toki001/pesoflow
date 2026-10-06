import '../../transactions/data/transaction_fixture.dart';
import '../domain/demo_account.dart';

List<DemoAccount> accountFixture() => List.unmodifiable([
  DemoAccount(
    id: 'gcash',
    institution: 'GCash',
    name: 'GCash Personal',
    maskedIdentifier: '0917 •••• 892',
    kind: DemoAccountKind.wallet,
    balance: 425000,
    balanceAsOf: demoClock.subtract(const Duration(minutes: 5)),
  ),
  DemoAccount(
    id: 'bdo',
    institution: 'BDO Unibank',
    name: 'BDO Online Checking',
    maskedIdentifier: 'Account •••• 4120',
    kind: DemoAccountKind.bank,
    balance: 2840000,
    balanceAsOf: demoClock.subtract(const Duration(hours: 1)),
  ),
  DemoAccount(
    id: 'maya',
    institution: 'Maya',
    name: 'Maya Wallet',
    maskedIdentifier: '0918 •••• 331',
    kind: DemoAccountKind.wallet,
    balance: 185000,
    balanceAsOf: demoClock.subtract(const Duration(minutes: 12)),
  ),
  DemoAccount(
    id: 'bpi',
    institution: 'BPI',
    name: 'BPI Savings',
    maskedIdentifier: 'Account •••• 8841',
    kind: DemoAccountKind.bank,
    balance: 1220000,
    balanceAsOf: demoClock.subtract(const Duration(days: 2)),
    status: DemoConnectionStatus.needsReauthentication,
  ),
]);

class FixtureAccountsRepository implements DemoAccountsRepository {
  const FixtureAccountsRepository();
  @override
  Future<List<DemoAccount>> load() async => accountFixture();
  @override
  Future<void> refresh() async {}
}
