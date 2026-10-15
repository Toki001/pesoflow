import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/features/accounts/domain/account_view.dart';

import 'fixtures/features/accounts/data/account_fixture.dart';

void main() {
  test(
    'integer account total excludes archived balances and preserves masking',
    () {
      final overview = AccountsOverview(accountFixture());
      expect(overview.availableBalance, 3450000);
      expect(overview.accounts.last.balance, 1220000);
      expect(overview.institutionCount, 4);
      expect(overview.accounts.last.archived, true);
      expect(
        overview.accounts.every((a) => a.maskedIdentifier.contains('••••')),
        true,
      );
      expect(() => overview.accounts.clear(), throwsUnsupportedError);
      expect(
        () =>
            AccountsOverview([accountFixture().first, accountFixture().first]),
        throwsArgumentError,
      );
    },
  );
}
