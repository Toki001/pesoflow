import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pesoflow/features/transactions/application/transactions_provider.dart';
import 'package:pesoflow/features/accounts/domain/account_activity.dart';
import 'package:pesoflow/features/accounts/domain/account_detail.dart';
import 'package:pesoflow/features/accounts/application/accounts_provider.dart';

final accountDetailProvider =
    Provider.family<AsyncValue<AccountDetail?>, String>((ref, id) {
      final accounts = ref.watch(accountsProvider);
      final ledger = ref.watch(ledgerProvider);
      return accounts.whenData((overview) {
        final matching = overview.accounts.where((a) => a.id == id);
        if (matching.isEmpty) return null;
        return AccountDetail(
          account: matching.single,
          activity: accountActivity(id, ledger),
        );
      });
    });
