import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/formatting/money_formatter.dart';
import '../../demo_workspace/application/demo_workspace_providers.dart';
import '../../transactions/application/transactions_provider.dart';
import '../../transactions/data/transaction_fixture.dart';
import '../../transactions/domain/manual_transaction_draft.dart';
import '../application/subscriptions_provider.dart';
import '../domain/subscription_plan.dart';
import 'widgets/subscription_cards.dart';

Future<void> showSubscriptionEditor(
  BuildContext context, {
  SubscriptionPlan? plan,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _SubscriptionEditor(plan: plan),
);

class _SubscriptionEditor extends ConsumerStatefulWidget {
  const _SubscriptionEditor({this.plan});
  final SubscriptionPlan? plan;
  @override
  ConsumerState<_SubscriptionEditor> createState() =>
      _SubscriptionEditorState();
}

class _SubscriptionEditorState extends ConsumerState<_SubscriptionEditor> {
  final form = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.plan?.name);
  late final amount = TextEditingController(
    text: widget.plan == null
        ? ''
        : '${widget.plan!.amount ~/ 100}.${(widget.plan!.amount % 100).toString().padLeft(2, '0')}',
  );
  late BillingCycle cycle = widget.plan?.cycle ?? BillingCycle.monthly;
  late String source = widget.plan?.paymentSource ?? 'GCash Personal';
  late String category = widget.plan?.category ?? 'Entertainment & Leisure';
  late DateTime renewal =
      widget.plan?.nextRenewal ??
      DateTime(demoClock.year, demoClock.month, demoClock.day);
  @override
  void dispose() {
    name.dispose();
    amount.dispose();
    super.dispose();
  }

  void save() {
    if (!form.currentState!.validate()) return;
    final controller = ref.read(demoSubscriptionsProvider.notifier);
    controller.save(
      SubscriptionPlan(
        id: widget.plan?.id ?? controller.nextId(),
        name: name.text.trim(),
        amount: parsePhpAmount(amount.text)!,
        cycle: cycle,
        nextRenewal: renewal,
        paymentSource: source,
        category: category,
        active: widget.plan?.active ?? true,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.plan == null ? 'Add subscription' : 'Edit subscription',
                style: AppTypography.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                ref.watch(demoPersistenceEnabledProvider)
                    ? 'Demo tracking is saved on this device. Renewals do not create charges.'
                    : 'Demo tracking only. Changes last for this session and do not create charges.',
                style: AppTypography.bodySmall.copyWith(
                  color: context.colors.mutedInk,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('subscription-name'),
                controller: name,
                maxLength: 80,
                decoration: const InputDecoration(
                  labelText: 'Service name',
                  border: OutlineInputBorder(),
                  errorMaxLines: 3,
                ),
                validator: (v) {
                  final value = (v ?? '').trim();
                  if (value.isEmpty) return 'Enter a service name.';
                  return value.length > 80
                      ? 'Use a shorter service name.'
                      : null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('subscription-amount'),
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'PHP price per billing cycle',
                  prefixText: '₱ ',
                  border: OutlineInputBorder(),
                  errorMaxLines: 3,
                ),
                validator: (v) => parsePhpAmount(v ?? '') == null
                    ? 'Enter a positive amount with up to 2 decimals.'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<BillingCycle>(
                key: const ValueKey('subscription-cycle'),
                initialValue: cycle,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Billing cycle',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final c in BillingCycle.values)
                    DropdownMenuItem(value: c, child: Text(c.name)),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => cycle = v);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: source,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Sample payment source',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final s in {
                    'GCash Personal',
                    'Maya Wallet',
                    'BDO Checking',
                    'Cash',
                    source,
                  })
                    DropdownMenuItem(
                      value: s,
                      child: Text(
                        s,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => source = v);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: category,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final s in {
                    'Entertainment & Leisure',
                    'Productivity & Cloud',
                    'Cloud Storage',
                    'Other',
                    category,
                  })
                    DropdownMenuItem(
                      value: s,
                      child: Text(
                        s,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => category = v);
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: const ValueKey('subscription-renewal'),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: renewal,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035, 12, 31),
                  );
                  if (date != null && mounted) setState(() => renewal = date);
                },
                icon: const Icon(Icons.calendar_today_outlined, size: 18),
                label: Text(
                  'Next renewal: ${DateFormat('MMM d, yyyy').format(renewal)}',
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: save,
                child: const Text('Save subscription'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> showSubscriptionDetails(
  BuildContext context,
  SubscriptionPlan plan,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _SubscriptionDetails(plan: plan),
);

class _SubscriptionDetails extends ConsumerWidget {
  const _SubscriptionDetails({required this.plan});
  final SubscriptionPlan plan;
  @override
  Widget build(BuildContext context, WidgetRef ref) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(plan.name, style: AppTypography.headlineMedium),
          const SizedBox(height: 12),
          Text(
            '${MoneyFormatter.php(plan.amount)} / ${plan.cycle.unit}',
            style: AppTypography.numericLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '${MoneyFormatter.php(plan.monthlyEquivalent)}/month equivalent · ${MoneyFormatter.php(plan.annualized)}/year',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 12),
          Text(plan.paymentSource),
          Text(plan.category),
          Text(plan.active ? renewalLabel(plan, demoClock) : 'Tracking paused'),
          const SizedBox(height: 12),
          Text(
            plan.origin == SubscriptionOrigin.stitchFixture
                ? 'Source: demo sample plan.'
                : 'Source: manually entered demo plan.',
          ),
          const Text('Recurring detection confidence: unknown.'),
          const SizedBox(height: 12),
          Text(
            'Tracking only. Pausing or removing this plan does not cancel the service, stop payments, or change recorded expenses.',
            style: AppTypography.bodySmall.copyWith(
              color: context.colors.mutedInk,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              showSubscriptionEditor(context, plan: plan);
            },
            child: const Text('Edit plan'),
          ),
          OutlinedButton(
            onPressed: () {
              ref
                  .read(demoSubscriptionsProvider.notifier)
                  .setActive(plan.id, !plan.active);
              Navigator.pop(context);
            },
            child: Text(plan.active ? 'Pause tracking' : 'Resume tracking'),
          ),
          TextButton(
            onPressed: () async {
              final remove = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Remove tracking?'),
                  content: Text(
                    'Remove ${plan.name} from ${ref.read(demoPersistenceEnabledProvider) ? 'this device' : 'this demo session'}? This does not cancel your service or delete recorded charges.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Keep plan'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Remove tracking'),
                    ),
                  ],
                ),
              );
              if (remove == true && context.mounted) {
                ref.read(demoSubscriptionsProvider.notifier).remove(plan.id);
                Navigator.pop(context);
              }
            },
            child: Text(
              'Remove plan',
              style: TextStyle(color: context.colors.danger),
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

Future<void> showSubscriptionHistory(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _SubscriptionHistory(),
    );

class _SubscriptionHistory extends ConsumerWidget {
  const _SubscriptionHistory();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = subscriptionHistory(ref.watch(demoLedgerProvider));
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Subscription History', style: AppTypography.headlineMedium),
            const SizedBox(height: 8),
            const Text(
              'Posted recurring expenses from the demo ledger. No automated billing is connected.',
            ),
            const SizedBox(height: 16),
            if (history.isEmpty) const Text('No recorded recurring charges'),
            for (final t in history)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t.merchant),
                subtitle: Text(
                  '${DateFormat('MMM d, yyyy').format(t.occurredAt)} · ${t.account}',
                ),
                trailing: Text(MoneyFormatter.php(t.amount)),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/transactions/${t.id}');
                },
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
