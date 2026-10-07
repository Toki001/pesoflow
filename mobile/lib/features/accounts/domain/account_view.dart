enum AccountKind { bank, wallet, cash }

enum AccountConnectionStatus { active, needsReauthentication }

/// Display projection of a persisted account and its calculated balance.
class AccountView {
  const AccountView({
    required this.id,
    required this.institution,
    required this.name,
    required this.maskedIdentifier,
    required this.kind,
    required this.balance,
    required this.balanceAsOf,
    this.status = AccountConnectionStatus.active,
    this.manual = false,
    this.archived = false,
  });
  final bool manual, archived;
  final String id;
  final String institution;
  final String name;
  // Display only masked identifiers; no raw account numbers are stored.
  final String maskedIdentifier;
  final AccountKind kind;
  final int balance;
  final DateTime balanceAsOf;
  final AccountConnectionStatus status;
  bool get needsReauthentication =>
      status == AccountConnectionStatus.needsReauthentication;
  bool get hasAvailableBalance => !needsReauthentication;
}

class AccountsOverview {
  AccountsOverview(
    List<AccountView> accounts, {
    this.refreshing = false,
    this.refreshError = false,
    this.checked = false,
  }) : accounts = List.unmodifiable(accounts) {
    if (accounts.map((a) => a.id).toSet().length != accounts.length) {
      throw ArgumentError('Duplicate account.');
    }
  }
  final List<AccountView> accounts;
  final bool refreshing;
  final bool refreshError;
  final bool checked;
  int get availableBalance => accounts
      .where((a) => a.hasAvailableBalance && !a.archived)
      .fold(0, (sum, a) => sum + a.balance);
  int get lastKnownBalance => accounts
      .where((a) => !a.hasAvailableBalance && !a.archived)
      .fold(0, (sum, a) => sum + a.balance);
  int get institutionCount => accounts.map((a) => a.institution).toSet().length;
  AccountsOverview copyWith({
    List<AccountView>? accounts,
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
