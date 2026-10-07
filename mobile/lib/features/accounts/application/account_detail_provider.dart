import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transactions/application/transactions_provider.dart';
import '../domain/account_activity.dart';
import '../domain/account_detail.dart';
import 'accounts_provider.dart';

final accountDetailProvider =
    Provider.family<AsyncValue<AccountDetail?>, String>((ref, id) {
      final accounts = ref.watch(accountsProvider);
      final ledger = ref.watch(demoLedgerProvider);
      return accounts.whenData((overview) {
        final matching = overview.accounts.where((a) => a.id == id);
        if (matching.isEmpty) return null;
        return AccountDetail(
          account: matching.single,
          activity: accountActivity(id, ledger),
        );
      });
    });
