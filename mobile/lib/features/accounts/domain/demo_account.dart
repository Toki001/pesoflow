enum DemoAccountKind { bank, wallet }

enum DemoConnectionStatus { active, needsReauthentication }

/// Sample provider-reported balance, independent of the manual transaction ledger.
class DemoAccount {
  const DemoAccount({
    required this.id,
    required this.institution,
    required this.name,
    required this.maskedIdentifier,
    required this.kind,
    required this.balance,
    required this.balanceAsOf,
    this.status = DemoConnectionStatus.active,
  });
  final String id;
  final String institution;
  final String name;
  // Fixtures contain masked identifiers only; no raw account numbers are stored.
  final String maskedIdentifier;
  final DemoAccountKind kind;
  final int balance;
  final DateTime balanceAsOf;
  final DemoConnectionStatus status;
  bool get needsReauthentication =>
      status == DemoConnectionStatus.needsReauthentication;
  bool get hasAvailableBalance => !needsReauthentication;
}

class AccountsOverview {
  AccountsOverview(
    List<DemoAccount> accounts, {
    this.refreshing = false,
    this.refreshError = false,
    this.checked = false,
  }) : accounts = List.unmodifiable(accounts) {
    if (accounts.map((a) => a.id).toSet().length != accounts.length) {
      throw ArgumentError('Duplicate sample account.');
    }
  }
  final List<DemoAccount> accounts;
  final bool refreshing;
  final bool refreshError;
  final bool checked;
  int get availableBalance => accounts
      .where((a) => a.hasAvailableBalance)
      .fold(0, (sum, a) => sum + a.balance);
  int get lastKnownBalance => accounts
      .where((a) => !a.hasAvailableBalance)
      .fold(0, (sum, a) => sum + a.balance);
  int get institutionCount => accounts.map((a) => a.institution).toSet().length;
  AccountsOverview copyWith({
    List<DemoAccount>? accounts,
    bool? refreshing,
    bool? refreshError,
    bool? checked,
  }) => AccountsOverview(
    accounts ?? this.accounts,
    refreshing: refreshing ?? this.refreshing,
    refreshError: refreshError ?? this.refreshError,
    checked: checked ?? this.checked,
  );
}

abstract interface class DemoAccountsRepository {
  Future<List<DemoAccount>> load();

  /// Local fixture check only; never advances reported balance timestamps.
  Future<void> refresh();
}
