import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/finance_card.dart';
import '../../../core/widgets/task_screen.dart';
import '../../accounts/application/accounts_provider.dart';
import '../../accounts/presentation/widgets/account_detail_summary.dart';
import '../application/demo_access_provider.dart';
import '../domain/demo_access_result.dart';

class DemoAccessScreen extends ConsumerWidget {
  const DemoAccessScreen({required this.id, super.key});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acknowledged = ref.watch(demoAccessProvider(id));
    final profiles = ref
        .watch(demoAccountCatalogProvider)
        .where((a) => a.id == id);
    final accounts = ref.watch(accountsProvider);
    final c = context.colors;
    void close() {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/accounts');
      }
    }

    Widget message(String title, String body, {VoidCallback? retry}) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Disclosure(title: title, body: body, icon: Icons.info_outline),
        const SizedBox(height: AppSpacing.md),
        if (retry != null)
          FilledButton(onPressed: retry, child: const Text('Try Again')),
        TextButton(
          onPressed: close,
          child: const Text('Back to sample accounts'),
        ),
      ],
    );

    return TaskScreen(
      title: 'Review Demo Access',
      backIcon: Icons.arrow_back,
      backTooltip: 'Back',
      fallbackRoute: '/accounts',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: profiles.length != 1
            ? message(
                'Sample profile unavailable',
                'This link does not match a unique sample profile. No account has been added.',
              )
            : accounts.when(
                skipLoadingOnRefresh: false,
                loading: () => Semantics(
                  label: 'Loading demo access review',
                  child: FinanceCard(
                    child: SizedBox(
                      height: 120,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ),
                error: (_, _) => message(
                  "We couldn't load the demo review.",
                  'Please try again. No financial institution was contacted.',
                  retry: () => ref.invalidate(accountsProvider),
                ),
                data: (overview) {
                  final profile = profiles.single;
                  final listed = overview.accounts.any((a) => a.id == id);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _Disclosure(
                        title: 'Sample data only',
                        body: 'Review this fixed demo profile before adding it. This is not provider authorization or a real account connection.',
                        icon: Icons.lock_outline,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AccountDetailSummary(account: profile),
                      const SizedBox(height: AppSpacing.md),
                      const _Disclosure(
                        title: 'What the demo can show',
                        body: 'A masked sample profile, fixed balance and related demo activity. It cannot read your real accounts and grants no provider permissions.',
                        icon: Icons.visibility_outlined,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const _Disclosure(
                        title: 'Your money stays untouched',
                        body: 'No institution is contacted. No password, PIN or credentials are requested. PesoFlow cannot initiate transfers, execute debits or move funds.',
                        icon: Icons.shield_outlined,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const _Disclosure(
                        title: 'You control the sample list',
                        body: 'Added profiles and edits last for this session only. Remove a profile from Account Detail at any time; transaction history remains. Removal revokes no real provider consent.',
                        icon: Icons.link_off,
                      ),
                      if (profile.needsReauthentication) ...[
                        const SizedBox(height: AppSpacing.sm),
                        const _Disclosure(
                          title: 'This sample balance is stale',
                          body: 'Adding this profile keeps its last-known balance and original timestamp. It stays excluded from the available total; real reconnection is unavailable.',
                          icon: Icons.history,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      if (listed) ...[
                        const _Disclosure(
                          title: 'Already in your demo',
                          body: 'This sample profile is already listed. No duplicate account or provider authorization will be created.',
                          icon: Icons.check_circle_outline,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        FilledButton(
                          onPressed: () =>
                              context.pushReplacement('/accounts/$id'),
                          child: const Text('View sample profile'),
                        ),
                      ] else ...[
                        FinanceCard(
                          padding: EdgeInsets.zero,
                          child: Material(
                            type: MaterialType.transparency,
                            borderRadius: BorderRadius.circular(12),
                            clipBehavior: Clip.antiAlias,
                            child: CheckboxListTile(
                              key: const ValueKey('demo-access-acknowledgment'),
                              value: acknowledged,
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: AppSpacing.xs,
                              ),
                              title: Text(
                                'I understand this adds sample data only.',
                                style: AppTypography.bodyMedium,
                              ),
                              onChanged: overview.refreshing
                                  ? null
                                  : (value) => ref
                                        .read(demoAccessProvider(id).notifier)
                                        .acknowledge(value ?? false),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        FilledButton(
                          onPressed: !acknowledged || overview.refreshing
                              ? null
                              : () {
                                  final result = ref
                                      .read(demoAccessProvider(id).notifier)
                                      .confirm();
                                  if (result == DemoAccessResult.added ||
                                      result ==
                                          DemoAccessResult.alreadyListed) {
                                    context.pushReplacement('/accounts/$id');
                                  }
                                },
                          child: Text(
                            overview.refreshing
                                ? 'Checking demo…'
                                : 'Add demo account',
                          ),
                        ),
                      ],
                      TextButton(onPressed: close, child: const Text('Cancel')),
                      Text(
                        'No live GCash, Maya, bank or Open Finance connection is available.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmall.copyWith(
                          color: c.mutedInk,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

class _Disclosure extends StatelessWidget {
  const _Disclosure({
    required this.title,
    required this.body,
    required this.icon,
  });
  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) => FinanceCard(
    padding: const EdgeInsets.all(AppSpacing.md),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: context.colors.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.merchant),
              const SizedBox(height: AppSpacing.xs),
              Text(
                body,
                style: AppTypography.bodySmall.copyWith(
                  color: context.colors.secondaryInk,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
