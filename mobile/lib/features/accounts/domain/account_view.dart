enum AccountKind { bank, wallet, cash }

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
  bool get hasAvailableBalance => !archived;
}

class AccountsOverview {
  AccountsOverview(List<AccountView> accounts)
    : accounts = List.unmodifiable(accounts) {
    if (accounts.map((a) => a.id).toSet().length != accounts.length) {
      throw ArgumentError('Duplicate account.');
    }
  }
  final List<AccountView> accounts;
  int get availableBalance =>
      accounts.where((a) => !a.archived).fold(0, (sum, a) => sum + a.balance);
  int get institutionCount => accounts.map((a) => a.institution).toSet().length;
}
