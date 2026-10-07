import 'transaction.dart';

String normalizeMerchant(String value) => value
    .trim()
    .toLowerCase()
    .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
    .trim();

String merchantRuleKey(TransactionKind kind, String merchant) =>
    '${kind.name}:${normalizeMerchant(merchant)}';

/// Deterministic suggestions, never a claim of AI or provider verification.
TransactionCategory categorize({
  required TransactionKind kind,
  required String merchant,
  Map<String, TransactionCategory> userRules = const {},
  TransactionCategory? providerCategory,
}) {
  if (kind == TransactionKind.transfer) return TransactionCategory.transfer;
  if (kind == TransactionKind.refund) return TransactionCategory.refund;
  bool compatible(TransactionCategory c) => kind == TransactionKind.income
      ? isIncomeCategory(c)
      : isExpenseCategory(c);
  final rule = userRules[merchantRuleKey(kind, merchant)];
  if (rule != null && compatible(rule)) return rule;
  final normalized = normalizeMerchant(merchant);
  if (providerCategory != null && compatible(providerCategory)) {
    return providerCategory;
  }
  final keywords = kind == TransactionKind.income ? _income : _expenses;
  for (final entry in keywords.entries) {
    if (entry.value.any((word) => ' $normalized '.contains(' $word '))) {
      return entry.key;
    }
  }
  return kind == TransactionKind.income
      ? TransactionCategory.otherIncome
      : TransactionCategory.other;
}

const _income = {
  TransactionCategory.salary: ['salary', 'payroll'],
  TransactionCategory.freelance: ['freelance', 'upwork', 'fiverr'],
  TransactionCategory.business: ['business', 'sales'],
  TransactionCategory.allowance: ['allowance'],
  TransactionCategory.interest: ['interest', 'dividend'],
};
const _expenses = {
  TransactionCategory.groceries: [
    'supermarket',
    'grocery',
    'groceries',
    '7 eleven',
    'puregold',
  ],
  TransactionCategory.food: [
    'restaurant',
    'jollibee',
    'mcdonalds',
    'dining',
    'food',
    'cafe',
    'coffee',
    'starbucks',
  ],
  TransactionCategory.transport: [
    'grab',
    'angkas',
    'move it',
    'taxi',
    'fuel',
    'petrol',
    'jeepney',
    'bus',
    'parking',
    'toll',
  ],
  TransactionCategory.bills: [
    'meralco',
    'electricity',
    'water',
    'internet',
    'globe',
    'pldt',
    'smart',
  ],
  TransactionCategory.housing: ['rent', 'mortgage', 'housing'],
  TransactionCategory.healthcare: [
    'hospital',
    'clinic',
    'pharmacy',
    'medicine',
    'dentist',
  ],
  TransactionCategory.education: ['tuition', 'school', 'university', 'course'],
  TransactionCategory.subscriptions: [
    'netflix',
    'spotify',
    'icloud',
    'subscription',
    'disney',
  ],
  TransactionCategory.shopping: ['shopee', 'lazada', 'clothing', 'mall'],
  TransactionCategory.travel: ['airline', 'hotel', 'flight', 'airbnb'],
  TransactionCategory.personalCare: ['salon', 'barber', 'spa'],
  TransactionCategory.fees: ['fee', 'fees', 'charge'],
  TransactionCategory.entertainment: ['cinema', 'movie', 'concert', 'game'],
};
