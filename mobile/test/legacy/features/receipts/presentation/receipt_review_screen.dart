import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pesoflow/app/theme/app_colors.dart';
import 'package:pesoflow/app/theme/app_typography.dart';
import 'package:pesoflow/core/formatting/money_formatter.dart';
import 'package:pesoflow/core/widgets/finance_card.dart';
import 'package:pesoflow/core/widgets/status_badge.dart';
import 'package:pesoflow/features/receipts/application/receipts_provider.dart';
import 'package:pesoflow/features/receipts/domain/receipt_draft.dart';

import 'receipt_editors.dart';
import 'widgets/receipt_viewfinder.dart';
import 'widgets/receipt_review_cards.dart';

class ReceiptReviewScreen extends ConsumerStatefulWidget {
  const ReceiptReviewScreen({super.key});
  @override
  ConsumerState<ReceiptReviewScreen> createState() =>
      _ReceiptReviewScreenState();
}

class _ReceiptReviewScreenState extends ConsumerState<ReceiptReviewScreen> {
  String flash = 'Auto';
  Future<void> close() async {
    final draft = ref.read(receiptReviewProvider).value;
    if (draft != null &&
        draft.savedTransactionId == null &&
        !await confirmReceiptAction(
          context,
          'Discard receipt review?',
          'Discard these session corrections? No transaction has been saved.',
          'Discard review',
        )) {
      return;
    }
    if (!mounted) return;
    ref.invalidate(receiptReviewProvider);
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/add');
    }
  }

  Future<void> reload() async {
    if (!await confirmReceiptAction(
          context,
          'Reload demo receipt?',
          'Camera and gallery are not connected. Reload the original sample and discard unsaved corrections?',
          'Reload sample',
        ) ||
        !mounted) {
      return;
    }
    ref.invalidate(receiptReviewProvider);
  }

  Future<void> date(ReceiptDraft draft) async {
    final day = await showDatePicker(
      context: context,
      initialDate: draft.occurredAt,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030, 12, 31),
    );
    if (day == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(draft.occurredAt),
    );
    if (time != null && mounted) {
      ref
          .read(receiptReviewProvider.notifier)
          .setDate(
            DateTime(day.year, day.month, day.day, time.hour, time.minute),
          );
    }
  }

  Future<void> save(ReceiptDraft draft) async {
    final error = draft.validationError;
    if (draft.savedTransactionId == null && error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      if (draft.uncertain.isNotEmpty) {
        await showReceiptItemEditor(context, item: draft.uncertain.first);
      }
      return;
    }
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    final id = await ref.read(receiptReviewProvider.notifier).save();
    if (!mounted) return;
    context.pushReplacement('/transactions/$id');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(receiptReviewProvider);
    final c = context.colors;
    return PopScope(
      canPop: state.value == null || state.value?.savedTransactionId != null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) close();
      },
      child: ColoredBox(
        color: AppColors.darkSurface,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 512),
            child: Scaffold(
              backgroundColor: AppColors.darkSurface,
              body: SafeArea(
                child: SingleChildScrollView(
                  key: const PageStorageKey('receipt-scroll'),
                  child: Column(
                    children: [
                      ReceiptViewfinder(
                        onClose: close,
                        onGallery: reload,
                        flash: flash,
                        onFlash: () {
                          setState(
                            () => flash = flash == 'Auto'
                                ? 'Off'
                                : flash == 'Off'
                                ? 'On'
                                : 'Auto',
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Demo flash preference only. No camera is connected.',
                              ),
                            ),
                          );
                        },
                        onFrame: () => showDialog<void>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Demo frame preview'),
                            content: const Text(
                              'The frame illustrates the sample receipt. Cropping and camera capture will be available with the OCR integration.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                          decoration: BoxDecoration(
                            color: c.surface,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(
                                child: Container(
                                  width: 48,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: c.border,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              state.when(
                                loading: () => Semantics(
                                  label: 'Loading demo receipt',
                                  child: Column(
                                    children: [
                                      for (final height in [
                                        70.0,
                                        100.0,
                                        240.0,
                                        130.0,
                                      ])
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 16,
                                          ),
                                          child: FinanceCard(
                                            child: SizedBox(
                                              height: height,
                                              width: double.infinity,
                                              child: ColoredBox(
                                                color: c.mutedSurface,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                error: (_, _) => _ReceiptMessage(
                                  "We couldn't load this receipt.",
                                  'No transaction was saved.',
                                  () => ref.invalidate(receiptReviewProvider),
                                ),
                                data: (draft) => draft == null
                                    ? _ReceiptMessage(
                                        'No receipt to review',
                                        'Load the sample receipt to try the review flow.',
                                        () => ref.invalidate(
                                          receiptReviewProvider,
                                        ),
                                      )
                                    : content(draft),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget content(ReceiptDraft draft) {
    final c = context.colors;
    final controller = ref.read(receiptReviewProvider.notifier);
    final locked = draft.savedTransactionId != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                'Review Extracted Receipt',
                style: AppTypography.headlineMedium.copyWith(
                  fontSize: 24,
                  height: 28 / 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 120,
              child: StatusBadge(
                locked
                    ? 'Saved'
                    : draft.validationError == null
                    ? 'Ready to save'
                    : 'Ready to review',
                foreground: c.positive,
                background: c.soft(c.positive, AppColors.positiveSoft),
                icon: Icons.check_circle_outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Demo extraction · no camera or live OCR',
          style: AppTypography.bodyMedium.copyWith(color: c.mutedInk),
        ),
        const SizedBox(height: 20),
        ReceiptMerchantCard(
          draft: draft,
          onMerchant: locked
              ? null
              : () async {
                  final value = await editReceiptMerchant(
                    context,
                    draft.merchant,
                  );
                  if (value != null && mounted) controller.setMerchant(value);
                },
          onDate: locked ? null : () => date(draft),
        ),
        const SizedBox(height: 16),
        if (draft.uncertain.isNotEmpty) ...[
          FinanceCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: c.soft(c.warning, AppColors.warningSoft),
            borderColor: c.warning.withValues(alpha: .3),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber, size: 20, color: c.warning),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${draft.uncertain.length} item needs quick check',
                            style: AppTypography.labelMedium,
                          ),
                          Text(
                            'Low sample confidence · verify details',
                            style: AppTypography.bodySmall.copyWith(
                              color: c.secondaryInk,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => showReceiptItemEditor(
                    context,
                    item: draft.uncertain.first,
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: c.surface,
                    minimumSize: const Size(0, 28),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text('Tap to review'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Extracted Items (${draft.items.length})',
              style: AppTypography.headlineSmall,
            ),
            TextButton.icon(
              onPressed: locked ? null : () => showReceiptItemEditor(context),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Missing Item'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ReceiptItemsCard(
          items: draft.items,
          onItem: locked
              ? null
              : (i) => showReceiptItemEditor(context, item: i),
        ),
        const SizedBox(height: 24),
        ReceiptTotalsCard(draft),
        const SizedBox(height: 20),
        ReceiptAssignments(
          draft: draft,
          onCategory: locked
              ? null
              : () async {
                  final value = await chooseReceiptCategory(context);
                  if (value != null && mounted) controller.setCategory(value);
                },
          onAccount: locked
              ? null
              : () async {
                  final value = await chooseReceiptAccount(context);
                  if (value != null && mounted) controller.setAccount(value);
                },
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          key: const ValueKey('save-receipt'),
          onPressed: () => save(draft),
          icon: const Icon(Icons.task_alt, size: 20),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          label: Text(
            locked
                ? 'View saved transaction'
                : 'Confirm & Save Transaction — ${MoneyFormatter.php(draft.total)}',
            textAlign: TextAlign.center,
            style: AppTypography.headlineSmall,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) => Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              for (final (label, icon, action) in [
                ('Retake Photo', Icons.replay, locked ? null : reload),
                ('Discard', Icons.delete_outline, close),
              ])
                SizedBox(
                  width:
                      constraints.maxWidth < 300 ||
                          MediaQuery.textScalerOf(context).scale(12) > 18
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 12) / 2,
                  child: OutlinedButton.icon(
                    onPressed: action,
                    icon: Icon(icon, size: 18),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: c.mutedSurface,
                    ),
                    label: Text(label),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReceiptMessage extends StatelessWidget {
  const _ReceiptMessage(this.title, this.message, this.retry);
  final String title, message;
  final VoidCallback retry;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        Text(
          title,
          style: AppTypography.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        FilledButton(onPressed: retry, child: const Text('Load sample')),
      ],
    ),
  );
}
