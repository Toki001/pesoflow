import '../../transactions/domain/transaction.dart';
import 'demo_account.dart';

class AccountDetail {
  AccountDetail({
    required this.account,
    required List<TransactionRecord> activity,
  }) : activity = List.unmodifiable(activity);
  final DemoAccount account;
  final List<TransactionRecord> activity;
}
