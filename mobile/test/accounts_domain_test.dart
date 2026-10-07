import 'package:flutter_test/flutter_test.dart';
import 'package:pesoflow/features/accounts/domain/account_view.dart';

import 'fixtures/features/accounts/data/account_fixture.dart';

void main() {
  test(
    'integer sample total excludes stale BPI, preserves masked provenance',
    () {
      final overview = AccountsOverview(accountFixture());
      expect(overview.availableBalance, 3450000);
      expect(overview.lastKnownBalance, 1220000);
      expect(overview.institutionCount, 4);
      expect(overview.accounts.last.needsReauthentication, true);
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
