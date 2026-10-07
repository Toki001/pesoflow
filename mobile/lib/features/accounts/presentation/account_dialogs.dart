import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../application/accounts_provider.dart';
import '../domain/demo_account.dart';

Future<bool> confirmDemoDisconnect(
  BuildContext context,
  DemoAccount account,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Disconnect ${account.institution}?'),
        content: const Text(
          'Remove this sample account from the session list? Your transactions, budgets and manual payment sources remain available. No real connection is revoked.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: context.colors.danger),
            child: const Text('Disconnect demo'),
          ),
        ],
      ),
    ) ??
    false;

Future<bool> showDemoReconnect(
  BuildContext context,
  DemoAccount account,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reconnect ${account.institution}'),
        content: const Text(
          'This is a sample expired connection. Real reconnection is not available yet. The last-known balance remains stale and is excluded from the available total. You can remove the demo profile instead.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove demo profile'),
          ),
        ],
      ),
    ) ??
    false;

Future<void> showAccountCatalog(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => const _AccountCatalog(),
    );

class _AccountCatalog extends ConsumerWidget {
  const _AccountCatalog();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(demoAccountCatalogProvider);
    final overview = ref.watch(accountsProvider).value;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Link a demo account', style: AppTypography.headlineSmall),
            const SizedBox(height: 8),
            const Text(
              'Add a sample profile for this session. No financial institution will be contacted and no credentials are needed.',
            ),
            const SizedBox(height: 12),
            for (final account in profiles)
              ListTile(
                key: ValueKey('catalog-${account.id}'),
                contentPadding: EdgeInsets.zero,
                title: Text(account.institution),
                subtitle: Text(account.name),
                trailing:
                    overview?.accounts.any((a) => a.id == account.id) == true
                    ? const Text('Listed')
                    : null,
                enabled:
                    overview != null &&
                    !overview.accounts.any((a) => a.id == account.id),
                onTap: () async {
                  final add = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Add ${account.institution} sample?'),
                      content: Text(
                        '${account.name}\n${account.maskedIdentifier}\nThis adds a fixed demo balance, not a real connection.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Add demo account'),
                        ),
                      ],
                    ),
                  );
                  if (add == true && context.mounted) {
                    ref.read(accountsProvider.notifier).addSample(account.id);
                    Navigator.pop(context);
                  }
                },
              ),
            const SizedBox(height: 12),
            Text(
              'Live connections for GCash, Maya, banks and Open Finance are unavailable in this demo.',
              style: AppTypography.bodySmall.copyWith(
                color: context.colors.mutedInk,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
