import 'package:pesoflow/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pesoflow/features/workspace/application/finance_controller.dart';
import 'package:pesoflow/features/accounts/domain/ledger_account.dart';
import 'package:pesoflow/features/accounts/domain/financial_account.dart';

import '../domain/receipt_evidence.dart';
import '../../accounts/presentation/manual_account_editor.dart';

import 'package:pesoflow/app/theme/app_typography.dart';
import 'package:pesoflow/features/transactions/domain/manual_transaction_draft.dart';
import 'package:pesoflow/features/transactions/domain/transaction.dart';
import 'package:pesoflow/features/receipts/application/receipt_scan_controller.dart';
import 'package:pesoflow/features/receipts/domain/receipt_draft.dart';

Future<bool> confirmReceiptAction(
  BuildContext context,
  String title,
  String message,
  String action,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep reviewing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(action),
          ),
        ],
      ),
    ) ??
    false;

Future<void> showReceiptItemEditor(BuildContext context, {ReceiptItem? item}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ItemEditor(item: item),
    );

class _ItemEditor extends ConsumerStatefulWidget {
  const _ItemEditor({this.item});
  final ReceiptItem? item;
  @override
  ConsumerState<_ItemEditor> createState() => _ItemEditorState();
}

class _ItemEditorState extends ConsumerState<_ItemEditor> {
  final form = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.item?.name);
  late final quantity = TextEditingController(
    text: '${widget.item?.quantity ?? 1}',
  );
  late final price = TextEditingController(
    text: widget.item == null
        ? ''
        : '${widget.item!.unitPrice ~/ 100}.${(widget.item!.unitPrice % 100).toString().padLeft(2, '0')}',
  );
  @override
  void dispose() {
    name.dispose();
    quantity.dispose();
    price.dispose();
    super.dispose();
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
                widget.item == null
                    ? 'Add missing item'
                    : 'Review receipt item',
                style: AppTypography.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Check the item name, quantity and unit price before confirming.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('receipt-item-name'),
                controller: name,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'Item name',
                  border: OutlineInputBorder(),
                  errorMaxLines: 3,
                ),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Enter an item name.' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('receipt-item-quantity'),
                controller: quantity,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  return n == null || n < 1 || n > 999
                      ? 'Enter a whole quantity from 1 to 999.'
                      : null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('receipt-item-price'),
                controller: price,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'PHP unit price',
                  prefixText: '₱ ',
                  border: OutlineInputBorder(),
                  errorMaxLines: 3,
                ),
                validator: (v) => parsePhpAmount(v ?? '') == null
                    ? 'Enter a positive price with up to 2 decimals.'
                    : null,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  if (!form.currentState!.validate()) return;
                  final controller = ref.read(receiptScanProvider.notifier);
                  controller.saveItem(
                    ReceiptItem(
                      id: widget.item?.id ?? controller.nextItemId(),
                      name: name.text.trim(),
                      quantity: int.parse(quantity.text),
                      unitPrice: parsePhpAmount(price.text)!,
                      confidence: widget.item?.confidence,
                      reviewed: true,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Confirm item'),
              ),
              if (widget.item != null)
                TextButton(
                  onPressed: () async {
                    if (await confirmReceiptAction(
                          context,
                          'Remove item?',
                          'Remove this item from the local review? The receipt total stays unchanged; verify it separately.',
                          'Remove item',
                        ) &&
                        context.mounted) {
                      ref
                          .read(receiptScanProvider.notifier)
                          .removeItem(widget.item!.id);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Remove item'),
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

Future<String?> editReceiptMerchant(BuildContext context, String value) =>
    showDialog<String>(
      context: context,
      builder: (_) => _MerchantEditor(value),
    );

class _MerchantEditor extends StatefulWidget {
  const _MerchantEditor(this.value);
  final String value;
  @override
  State<_MerchantEditor> createState() => _MerchantEditorState();
}

class _MerchantEditorState extends State<_MerchantEditor> {
  late final text = TextEditingController(text: widget.value);
  final form = GlobalKey<FormState>();
  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit merchant'),
    content: Form(
      key: form,
      child: TextFormField(
        key: const ValueKey('receipt-merchant'),
        controller: text,
        maxLength: 100,
        decoration: const InputDecoration(
          labelText: 'Merchant',
          errorMaxLines: 3,
        ),
        validator: (v) {
          final s = (v ?? '').trim();
          return s.isEmpty || s.length > 100
              ? 'Enter a valid merchant name.'
              : null;
        },
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () {
          if (form.currentState!.validate()) {
            Navigator.pop(context, text.text.trim());
          }
        },
        child: const Text('Apply'),
      ),
    ],
  );
}

Future<TransactionCategory?> chooseReceiptCategory(BuildContext context) =>
    showModalBottomSheet<TransactionCategory>(
      context: context,
      showDragHandle: true,
      builder: (context) => Consumer(
        builder: (context, ref, _) => SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Choose category', style: AppTypography.headlineSmall),
                for (final c in TransactionCategory.values.where(
                  (c) =>
                      isExpenseCategory(c) &&
                      !ref
                          .watch(workspaceProvider)
                          .preferences
                          .hiddenCategories
                          .contains(c),
                ))
                  ListTile(
                    title: Text(categoryLabel(c)),
                    onTap: () => Navigator.pop(context, c),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
Future<LedgerAccount?> chooseReceiptAccount(BuildContext context) =>
    showModalBottomSheet<LedgerAccount>(
      context: context,
      showDragHandle: true,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final accounts = ref
              .watch(workspaceProvider)
              .accounts
              .where((a) => !a.archived && a.source == BalanceSource.manual);
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Choose payment source',
                    style: AppTypography.headlineSmall,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Choose the account that paid. Creating an account keeps your receipt review open.',
                    ),
                  ),
                  for (final account in accounts)
                    ListTile(
                      title: Text(account.name),
                      subtitle: const Text(
                        'Records an expense against this account',
                      ),
                      onTap: () => Navigator.pop(
                        context,
                        LedgerAccount(id: account.id, label: account.name),
                      ),
                    ),
                  TextButton.icon(
                    onPressed: () => showManualAccountEditor(context),
                    icon: const Icon(Icons.add, color: AppColors.primary),
                    label: const Text('Create manual account'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

Future<void> editReceiptTotals(
  BuildContext context,
  ReceiptEvidence evidence,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _TotalsEditor(evidence),
);

class _TotalsEditor extends ConsumerStatefulWidget {
  const _TotalsEditor(this.evidence);
  final ReceiptEvidence evidence;
  @override
  ConsumerState<_TotalsEditor> createState() => _TotalsEditorState();
}

class _TotalsEditorState extends ConsumerState<_TotalsEditor> {
  final form = GlobalKey<FormState>();
  late final fields =
      [
            widget.evidence.total == 0 ? null : widget.evidence.total,
            widget.evidence.subtotal,
            widget.evidence.tax,
            widget.evidence.discount,
          ]
          .map(
            (v) => TextEditingController(
              text: v == null
                  ? ''
                  : '${v ~/ 100}.${(v % 100).toString().padLeft(2, '0')}',
            ),
          )
          .toList();
  late bool php = widget.evidence.currency == 'PHP';
  int? amount(String text) => RegExp(r'^0(?:\.0{1,2})?$').hasMatch(text.trim())
      ? 0
      : parsePhpAmount(text);
  @override
  void dispose() {
    for (final field in fields) {
      field.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Verify receipt totals', style: AppTypography.headlineMedium),
            const SizedBox(height: 8),
            const Text(
              'Copy the final amount due. Leave optional amounts blank when absent. Tax may already be included; it is not added again.',
            ),
            for (final (i, label) in [
              'Total amount',
              'Subtotal (optional)',
              'VAT / tax (optional)',
              'Discount (optional)',
            ].indexed)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: TextFormField(
                  key: ValueKey('receipt-total-$i'),
                  controller: fields[i],
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: label,
                    prefixText: '₱ ',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => i > 0 && (value ?? '').trim().isEmpty
                      ? null
                      : amount(value ?? '') == null ||
                            (i == 0 && amount(value ?? '') == 0)
                      ? 'Enter a valid PHP amount with up to 2 decimals.'
                      : null,
                ),
              ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: php,
              onChanged: (v) => setState(() => php = v ?? false),
              title: const Text('This receipt is in Philippine pesos (PHP)'),
              subtitle: const Text('No currency conversion is performed.'),
            ),
            FilledButton(
              onPressed: () {
                if (!form.currentState!.validate() || !php) return;
                final controller = ref.read(receiptScanProvider.notifier);
                final draft = ref.read(receiptScanProvider).draft!;
                controller.setDraft(
                  draft.copyWith(
                    evidence: widget.evidence.copyWith(
                      total: amount(fields[0].text),
                      subtotal: amount(fields[1].text),
                      tax: amount(fields[2].text),
                      discount: amount(fields[3].text),
                      clearSubtotal: fields[1].text.trim().isEmpty,
                      clearTax: fields[2].text.trim().isEmpty,
                      clearDiscount: fields[3].text.trim().isEmpty,
                      currency: 'PHP',
                    ),
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Apply totals'),
            ),
          ],
        ),
      ),
    ),
  );
}
