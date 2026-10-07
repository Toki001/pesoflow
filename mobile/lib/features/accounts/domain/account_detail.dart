import 'package:pesoflow/features/transactions/domain/transaction.dart';
import 'package:pesoflow/features/accounts/domain/account_view.dart';

class AccountDetail {
  AccountDetail({
    required this.account,
    required List<TransactionRecord> activity,
  }) : activity = List.unmodifiable(activity);
  final AccountView account;
  final List<TransactionRecord> activity;
}
