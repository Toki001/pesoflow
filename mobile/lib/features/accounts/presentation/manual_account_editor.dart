import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_typography.dart';
import '../../../core/identity/new_id.dart';
import '../../../core/time/clock.dart';
import '../../../core/widgets/finance_card.dart';
import '../../../core/widgets/task_screen.dart';
import '../../workspace/application/finance_controller.dart';
import '../../transactions/domain/manual_transaction_draft.dart';
import '../domain/financial_account.dart';

Future<void> showManualAccountEditor(
  BuildContext context, {
  FinancialAccount? account,
}) => Navigator.of(context).push<void>(
  MaterialPageRoute(builder: (_) => ManualAccountEditor(account: account)),
);

class ManualAccountEditor extends ConsumerStatefulWidget {
  const ManualAccountEditor({this.account, super.key});
  final FinancialAccount? account;
  @override
  ConsumerState<ManualAccountEditor> createState() =>
      _ManualAccountEditorState();
}

class _ManualAccountEditorState extends ConsumerState<ManualAccountEditor> {
  final form = GlobalKey<FormState>();
  late final TextEditingController name,
      opening,
      institution,
      lastDigits,
      notes,
      creditLimit,
      cardDigits;
  String cardNetwork = '';
  late AccountType type;
  bool saving = false;
  String? error;
  @override
  void initState() {
    super.initState();
    final account = widget.account;
    name = TextEditingController(text: account?.name ?? '');
    final balance = account?.startingBalance ?? 0;
    opening = TextEditingController(
      text:
          '${balance < 0 ? '-' : ''}${balance.abs() ~/ 100}.${(balance.abs() % 100).toString().padLeft(2, '0')}',
    );
    institution = TextEditingController(text: account?.institution ?? '');
    lastDigits = TextEditingController(
      text: account?.maskedIdentifier.replaceAll(RegExp(r'[^0-9]'), '') ?? '',
    );
    notes = TextEditingController(text: account?.notes ?? '');
    creditLimit = TextEditingController(
      text: account?.creditLimit == null
          ? ''
          : (account!.creditLimit! / 100).toStringAsFixed(2),
    );
    cardDigits = TextEditingController(text: account?.cardLastFour ?? '');
    cardNetwork = account?.cardNetwork ?? '';
    type = account?.type ?? AccountType.cash;
  }

  @override
  void dispose() {
    for (final c in [
      name,
      opening,
      institution,
      lastDigits,
      notes,
      creditLimit,
      cardDigits,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> save() async {
    if (saving || !form.currentState!.validate()) return;
    setState(() {
      saving = true;
      error = null;
    });
    try {
      final existing = widget.account;
      final account = FinancialAccount(
        id: existing?.id ?? newId(),
        name: name.text.trim(),
        type: type,
        startingBalance: parseStartingBalance(opening.text)!,
        currency: ref.read(workspaceProvider).preferences.currency,
        createdAt: existing?.createdAt ?? ref.read(clockProvider)(),
        institution: institution.text.trim(),
        notes: notes.text.trim(),
        maskedIdentifier: lastDigits.text.trim().isEmpty
            ? ''
            : '•••• ${lastDigits.text.trim()}',
        archived: existing?.archived ?? false,
        creditLimit: type == AccountType.credit && creditLimit.text.isNotEmpty
            ? parseStartingBalance(creditLimit.text)
            : null,
        cardNetwork: cardNetwork,
        cardLastFour: cardDigits.text,
      );
      await ref.read(financeControllerProvider.notifier).saveAccount(account);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() {
          saving = false;
          error =
              'Account could not be saved. Check the details and try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(workspaceProvider).preferences.currency;
    return TaskScreen(
      title: widget.account == null
          ? 'Add Manual Account'
          : 'Edit Manual Account',
      backIcon: Icons.close,
      backTooltip: 'Close',
      fallbackRoute: '/accounts',
      footer: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: saving ? null : save,
          child: Text(saving ? 'Saving…' : 'Save Account'),
        ),
      ),
      child: Form(
        key: form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FinanceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manually tracked balance',
                    style: AppTypography.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your balance follows the starting amount and transactions you enter. This does not connect to a bank or wallet.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FinanceCard(
              child: Column(
                children: [
                  TextFormField(
                    controller: name,
                    maxLength: 80,
                    decoration: const InputDecoration(
                      labelText: 'Account name',
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Enter an account name.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<AccountType>(
                    initialValue: type,
                    decoration: const InputDecoration(
                      labelText: 'Account type',
                    ),
                    items: [
                      for (final t in AccountType.values)
                        DropdownMenuItem(
                          value: t,
                          child: Text(switch (t) {
                            AccountType.cash => 'Cash',
                            AccountType.wallet => 'E-wallet',
                            AccountType.bank => 'Bank account',
                            AccountType.savings => 'Savings account',
                            AccountType.credit => 'Credit account',
                          }),
                        ),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => type = v);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: opening,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    style: AppTypography.numericLarge,
                    decoration: InputDecoration(
                      labelText: 'Starting balance ($currency)',
                      helperText: type == AccountType.credit
                          ? 'Enter an amount owed as a negative balance.'
                          : 'Balance before the transactions you will record.',
                    ),
                    validator: (v) => parseStartingBalance(v ?? '') == null
                        ? 'Use an amount with at most two decimal places.'
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FinanceCard(
              child: Column(
                children: [
                  TextFormField(
                    controller: institution,
                    maxLength: 80,
                    decoration: const InputDecoration(
                      labelText: 'Institution (optional)',
                      hintText: 'GCash, Maya or your bank',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: lastDigits,
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Last four digits (optional)',
                      helperText: 'Only a masked identifier is stored.',
                    ),
                    validator: (v) =>
                        v!.isNotEmpty && !RegExp(r'^\d{4}$').hasMatch(v)
                        ? 'Enter only the last four digits.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  if (type == AccountType.credit)
                    TextFormField(
                      controller: creditLimit,
                      decoration: const InputDecoration(
                        labelText: 'Credit limit (optional)',
                        helperText: 'Tracked separately from cash balances.',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) =>
                          v!.isNotEmpty &&
                              (parseStartingBalance(v) == null ||
                                  parseStartingBalance(v)! < 0)
                          ? 'Enter a non-negative limit.'
                          : null,
                    ),
                  if (type == AccountType.bank ||
                      type == AccountType.savings ||
                      type == AccountType.credit) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: cardNetwork,
                      decoration: const InputDecoration(
                        labelText: 'Card network (optional)',
                      ),
                      items: [
                        for (final network in [
                          '',
                          'Visa',
                          'Mastercard',
                          'Other',
                        ])
                          DropdownMenuItem(
                            value: network,
                            child: Text(network.isEmpty ? 'No card' : network),
                          ),
                      ],
                      onChanged: (v) => setState(() => cardNetwork = v ?? ''),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: cardDigits,
                      maxLength: 4,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Card last four digits (optional)',
                        helperText: 'Debit cards use this account balance; no separate balance.',
                      ),
                      validator: (v) =>
                          v!.isNotEmpty && !RegExp(r'^\d{4}$').hasMatch(v)
                          ? 'Enter four digits only.'
                          : null,
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: notes,
                    maxLength: 1000,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                    ),
                  ),
                ],
              ),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(error!),
              ),
          ],
        ),
      ),
    );
  }
}
