import '../../../core/serialization/values.dart';
import '../../transactions/domain/transaction.dart';

enum AccountType { cash, wallet, bank, savings, credit }

enum BalanceSource { manual, provider }

/// An owned ledger account. A provider balance is a separate dated observation.
class FinancialAccount {
  FinancialAccount({
    required this.id,
    required this.name,
    required this.type,
    required this.startingBalance,
    required this.currency,
    required this.createdAt,
    this.institution = '',
    this.maskedIdentifier = '',
    this.notes = '',
    this.archived = false,
    this.source = BalanceSource.manual,
    this.connectionId,
    this.reportedBalance,
    this.reportedAt,
  }) {
    if (id.trim().isEmpty ||
        name.trim().isEmpty ||
        name.length > 80 ||
        startingBalance.abs() > maxMoney ||
        !RegExp(r'^[A-Z]{3}$').hasMatch(currency) ||
        institution.length > 80 ||
        notes.length > 1000 ||
        (maskedIdentifier.isNotEmpty &&
            !RegExp(r'^[•*xX -]+[0-9]{0,4}$').hasMatch(maskedIdentifier)) ||
        (source == BalanceSource.provider &&
            (connectionId == null ||
                reportedBalance == null ||
                reportedAt == null)) ||
        (source == BalanceSource.manual &&
            (connectionId != null ||
                reportedBalance != null ||
                reportedAt != null)) ||
        (reportedBalance != null && reportedBalance!.abs() > maxMoney)) {
      throw ArgumentError(
        'Invalid account details. Use only a masked identifier.',
      );
    }
  }

  final String id, name, currency, institution, maskedIdentifier, notes;
  final AccountType type;
  final int startingBalance;
  final DateTime createdAt;
  final bool archived;
  final BalanceSource source;
  final String? connectionId;
  final int? reportedBalance;
  final DateTime? reportedAt;

  FinancialAccount copyWith({
    String? name,
    AccountType? type,
    int? startingBalance,
    String? institution,
    String? maskedIdentifier,
    String? notes,
    bool? archived,
  }) => FinancialAccount(
    id: id,
    name: name ?? this.name,
    type: type ?? this.type,
    startingBalance: startingBalance ?? this.startingBalance,
    currency: currency,
    createdAt: createdAt,
    institution: institution ?? this.institution,
    maskedIdentifier: maskedIdentifier ?? this.maskedIdentifier,
    notes: notes ?? this.notes,
    archived: archived ?? this.archived,
    source: source,
    connectionId: connectionId,
    reportedBalance: reportedBalance,
    reportedAt: reportedAt,
  );

  Json toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'startingBalance': startingBalance,
    'currency': currency,
    'createdAt': createdAt.toIso8601String(),
    'institution': institution,
    'maskedIdentifier': maskedIdentifier,
    'notes': notes,
    'archived': archived,
    'source': source.name,
    'connectionId': connectionId,
    'reportedBalance': reportedBalance,
    'reportedAt': reportedAt?.toIso8601String(),
  };

  factory FinancialAccount.fromJson(Json json) => FinancialAccount(
    id: jsonString(json, 'id'),
    name: jsonString(json, 'name', max: 80),
    type: AccountType.values.byName(json['type'] as String),
    startingBalance: jsonInt(
      json,
      'startingBalance',
      min: -maxMoney,
      max: maxMoney,
    ),
    currency: jsonString(json, 'currency', max: 3),
    createdAt: jsonDate(json, 'createdAt'),
    institution: jsonString(json, 'institution', empty: true, max: 80),
    maskedIdentifier: jsonString(json, 'maskedIdentifier', empty: true),
    notes: jsonString(json, 'notes', empty: true),
    archived: json['archived'] as bool,
    source: BalanceSource.values.byName(json['source'] as String),
    connectionId: json['connectionId'] as String?,
    reportedBalance: json['reportedBalance'] == null
        ? null
        : jsonInt(json, 'reportedBalance'),
    reportedAt: json['reportedAt'] == null
        ? null
        : jsonDate(json, 'reportedAt'),
  );
}

int accountBalance(
  FinancialAccount account,
  Iterable<TransactionRecord> ledger,
) {
  // Local entries cannot manufacture a provider-reported balance.
  if (account.source == BalanceSource.provider) return account.reportedBalance!;
  var balance = account.startingBalance;
  for (final record in ledger) {
    if (record.status != TransactionStatus.posted) continue;
    if (record.kind == TransactionKind.transfer) {
      if (record.accountId == account.id) balance -= record.amount;
      if (record.destinationAccountId == account.id) balance += record.amount;
    } else if (record.accountId == account.id) {
      balance += record.cashFlowImpact;
    }
  }
  return balance;
}
