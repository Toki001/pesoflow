import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../accounts/application/accounts_provider.dart';
import '../domain/demo_access_result.dart';

final demoAccessProvider = NotifierProvider.autoDispose
    .family<DemoAccessController, bool, String>(DemoAccessController.new);

/// Acknowledgment lasts only while this profile's review screen is open.
class DemoAccessController extends Notifier<bool> {
  DemoAccessController(this.id);
  final String id;

  @override
  bool build() => false;

  void acknowledge(bool value) => state = value;

  DemoAccessResult confirm() {
    if (!state) return DemoAccessResult.acknowledgmentRequired;
    final accounts = ref.read(accountsProvider);
    final overview = accounts.value;
    final profiles = ref
        .read(demoAccountCatalogProvider)
        .where((a) => a.id == id);
    if (accounts.isLoading ||
        accounts.hasError ||
        overview == null ||
        overview.refreshing ||
        profiles.length != 1) {
      return DemoAccessResult.unavailable;
    }
    if (overview.accounts.any((a) => a.id == id)) {
      return DemoAccessResult.alreadyListed;
    }
    return ref.read(accountsProvider.notifier).addSample(id)
        ? DemoAccessResult.added
        : DemoAccessResult.unavailable;
  }
}
