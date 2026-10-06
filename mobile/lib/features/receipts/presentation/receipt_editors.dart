import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_typography.dart';
import '../../transactions/domain/manual_transaction_draft.dart';
import '../../transactions/domain/transaction.dart';
import '../application/receipts_provider.dart';
import '../domain/receipt_draft.dart';

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
                  final controller = ref.read(receiptReviewProvider.notifier);
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
                          'Remove this item from the local review? The total will be recalculated.',
                          'Remove item',
                        ) &&
                        context.mounted) {
                      ref
                          .read(receiptReviewProvider.notifier)
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
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Choose category', style: AppTypography.headlineSmall),
              for (final c in TransactionCategory.values.where(
                (c) => ![
                  TransactionCategory.income,
                  TransactionCategory.transfer,
                  TransactionCategory.refund,
                ].contains(c),
              ))
                ListTile(
                  title: Text(categoryLabel(c)),
                  onTap: () => Navigator.pop(context, c),
                ),
            ],
          ),
        ),
      ),
    );
Future<String?> chooseReceiptAccount(BuildContext context) =>
    showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose sample payment source',
                style: AppTypography.headlineSmall,
              ),
              for (final account in ['GCash', 'Maya', 'BDO Checking', 'Cash'])
                ListTile(
                  title: Text(account),
                  subtitle: const Text(
                    'Demo source only · no payment initiated',
                  ),
                  onTap: () => Navigator.pop(context, account),
                ),
            ],
          ),
        ),
      ),
    );
