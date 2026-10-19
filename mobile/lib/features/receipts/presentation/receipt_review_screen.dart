import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/formatting/money_formatter.dart';
import '../../../core/widgets/finance_card.dart';
import '../../../core/widgets/task_screen.dart';
import 'widgets/receipt_scanner.dart';
import '../../../core/widgets/status_badge.dart';
import '../application/receipt_scan_controller.dart';
import '../domain/receipt_draft.dart';
import '../domain/receipt_image.dart';
import 'receipt_editors.dart';
import 'widgets/receipt_review_cards.dart';
import 'widgets/receipt_preview.dart';

class ReceiptReviewScreen extends ConsumerStatefulWidget {
  const ReceiptReviewScreen({super.key});
  @override
  ConsumerState<ReceiptReviewScreen> createState() =>
      _ReceiptReviewScreenState();
}

class _ReceiptReviewScreenState extends ConsumerState<ReceiptReviewScreen> {
  bool leaving = false;
  bool dialogOpen = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(receiptScanProvider.notifier).recover();
    });
  }

  Future<void> close() async {
    final state = ref.read(receiptScanProvider);
    if (state.busy || dialogOpen) return;
    dialogOpen = true;
    final discard =
        state.image == null ||
        state.draft?.savedTransactionId != null ||
        await confirmReceiptAction(
          context,
          'Discard receipt review?',
          'The image and unsaved corrections will be removed. No expense has been saved.',
          'Discard review',
        );
    dialogOpen = false;
    if (!mounted || !discard) return;
    setState(() => leaving = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/home');
      }
    });
  }

  Future<void> replace(Future<void> Function() action) async {
    if (ref.read(receiptScanProvider).busy || dialogOpen) return;
    dialogOpen = true;
    final proceed =
        ref.read(receiptScanProvider).draft == null ||
        await confirmReceiptAction(
          context,
          'Read receipt again?',
          'Changing the image replaces unsaved corrections. You can adjust it before scanning again. Cancelling keeps this review.',
          'Continue',
        );
    dialogOpen = false;
    if (mounted && proceed) await action();
  }

  Future<void> date(ReceiptDraft draft) async {
    final day = await showDatePicker(
      context: context,
      initialDate: draft.occurredAt,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (day == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(draft.occurredAt),
    );
    if (time != null && mounted) {
      ref
          .read(receiptScanProvider.notifier)
          .setDate(
            DateTime(day.year, day.month, day.day, time.hour, time.minute),
          );
    }
  }

  Future<void> save() async {
    final id = await ref.read(receiptScanProvider.notifier).save();
    if (id != null && mounted) context.pushReplacement('/transactions/$id');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(receiptScanProvider);
    final controller = ref.read(receiptScanProvider.notifier);
    final c = context.colors;
    final locked = state.busy;
    return PopScope(
      canPop: leaving || (!locked && state.image == null),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) close();
      },
      child: state.image == null
          ? ReceiptScanner(
              onClose: locked ? null : close,
              onCamera: locked
                  ? null
                  : () => controller.acquire(ReceiptImageSource.camera),
              onGallery: locked
                  ? null
                  : () => controller.acquire(ReceiptImageSource.photos),
              status: scanStatus(state),
            )
          : TaskScreen(
              title: state.draft == null ? 'Prepare Receipt' : 'Review Receipt',
              backIcon: Icons.arrow_back,
              backTooltip: 'Close receipt',
              onClose: close,
              actions: [
                TextButton(
                  onPressed: locked
                      ? null
                      : () => replace(
                          () => controller.acquire(ReceiptImageSource.camera),
                        ),
                  child: const Text('Retake'),
                ),
              ],
              child: SingleChildScrollView(
                key: const PageStorageKey('receipt-scroll'),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FinanceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (state.image != null)
                            InkWell(
                              onTap: () =>
                                  showReceiptImage(context, state.image!.bytes),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  height: state.draft == null
                                      ? (MediaQuery.sizeOf(context).height *
                                                .42)
                                            .clamp(200.0, 420.0)
                                      : 160,
                                  color: c.mutedSurface,
                                  child: receiptImage(state.image!.bytes),
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to inspect full receipt',
                            style: AppTypography.bodySmall,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                key: const ValueKey('rotate-receipt'),
                                onPressed: locked
                                    ? null
                                    : () => replace(controller.rotate),
                                icon: const Icon(
                                  Icons.rotate_right,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                label: const Text('Rotate'),
                              ),
                              TextButton.icon(
                                key: const ValueKey('crop-receipt'),
                                onPressed: locked
                                    ? null
                                    : () => replace(controller.crop),
                                icon: const Icon(
                                  Icons.crop,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                label: const Text('Crop'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    scanStatus(state),
                    if (state.draft == null) ...[
                      Text(
                        'Adjust before scanning',
                        style: AppTypography.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Rotate the writing upright and crop out the background. Keep the merchant, date and full amount table in the image.',
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        key: const ValueKey('scan-prepared-receipt'),
                        onPressed: locked ? null : controller.retry,
                        child: Text(state.progress ?? 'Scan receipt'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: locked
                            ? null
                            : () =>
                                  controller.acquire(ReceiptImageSource.photos),
                        child: const Text('Choose another photo'),
                      ),
                    ] else
                      AbsorbPointer(absorbing: locked, child: content(state)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget scanStatus(ReceiptScanState state) {
    final controller = ref.read(receiptScanProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.progress != null) ...[
          if (!MediaQuery.disableAnimationsOf(context))
            const LinearProgressIndicator(),
          const SizedBox(height: 12),
          Semantics(
            liveRegion: true,
            child: Text(
              state.progress!,
              style: TextStyle(
                color: state.image == null ? Colors.white : context.colors.ink,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (state.error != null) ...[
          FinanceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(liveRegion: true, child: Text(state.error!.message)),
                if (state.error!.settings)
                  TextButton(
                    onPressed: controller.openSettings,
                    child: const Text('Open device Settings'),
                  ),
                if (state.image != null)
                  TextButton(
                    onPressed: state.busy
                        ? null
                        : () => replace(controller.retry),
                    child: const Text('Retry text recognition'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget content(ReceiptScanState state) {
    final draft = state.draft!;
    final evidence = draft.evidence!;
    final controller = ref.read(receiptScanProvider.notifier);
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FinanceCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'TOTAL AMOUNT',
                style: AppTypography.labelMedium.copyWith(color: c.mutedInk),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      evidence.currency == 'PHP'
                          ? MoneyFormatter.php(draft.total)
                          : 'Verify currency',
                      textAlign: TextAlign.center,
                      style: AppTypography.numericXL,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Edit total amount',
                    onPressed: () => editReceiptTotals(context, evidence),
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Text(
                evidence.confirmed
                    ? 'Reviewed against receipt'
                    : 'Verify against printed receipt',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(color: c.mutedInk),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Review Extracted Receipt', style: AppTypography.headlineSmall),
        const SizedBox(height: 12),
        ReceiptMerchantCard(
          draft: draft,
          onMerchant: () async {
            final value = await editReceiptMerchant(context, draft.merchant);
            if (value != null && mounted) controller.setMerchant(value);
          },
          onDate: () => date(draft),
        ),
        const SizedBox(height: 16),
        ReceiptAssignments(
          draft: draft,
          onCategory: () async {
            final value = await chooseReceiptCategory(context);
            if (value != null && mounted) controller.setCategory(value);
          },
          onAccount: () async {
            final value = await chooseReceiptAccount(context);
            if (value != null && mounted) controller.setAccount(value);
          },
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            for (final field in ['merchant', 'date', 'total'])
              StatusBadge(
                '${field[0].toUpperCase()}${field.substring(1)}: ${(evidence.confidence[field] ?? 0) >= 85
                    ? 'High'
                    : (evidence.confidence[field] ?? 0) >= 65
                    ? 'Medium'
                    : 'Check'}',
                foreground: (evidence.confidence[field] ?? 0) >= 65
                    ? c.secondaryInk
                    : c.warning,
                background: (evidence.confidence[field] ?? 0) >= 65
                    ? c.mutedSurface
                    : c.soft(c.warning, AppColors.warningSoft),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Parser confidence estimates; corrections still need your confirmation.',
          style: AppTypography.bodySmall.copyWith(color: c.mutedInk),
        ),
        if (evidence.warnings.isNotEmpty) ...[
          const SizedBox(height: 12),
          FinanceCard(
            color: c.soft(c.warning, AppColors.warningSoft),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Check extracted details',
                  style: AppTypography.labelMedium,
                ),
                for (final warning in evidence.warnings)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(warning, style: AppTypography.bodySmall),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Extracted Items (${draft.items.length})',
              style: AppTypography.headlineSmall,
            ),
            TextButton.icon(
              onPressed: () => showReceiptItemEditor(context),
              icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
              label: const Text('Add Missing Item'),
            ),
          ],
        ),
        ReceiptItemsCard(
          items: draft.items,
          onItem: (item) => showReceiptItemEditor(context, item: item),
        ),
        const SizedBox(height: 24),
        ReceiptTotalsCard(
          draft,
          onEdit: () => editReceiptTotals(context, evidence),
        ),
        const SizedBox(height: 20),
        const SizedBox(height: 12),
        FinanceCard(
          child: TextFormField(
            key: ValueKey('receipt-note-${draft.id}'),
            initialValue: draft.note,
            onChanged: controller.setNote,
            maxLength: 2000,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Notes & Description',
              hintText: 'Optional note',
            ),
          ),
        ),
        const SizedBox(height: 12),
        ExpansionTile(
          // Keep expansion state separate from the receipt scroll offset.
          key: const PageStorageKey('receipt-original-text-expansion'),
          tilePadding: EdgeInsets.zero,
          title: const Text('Original extracted text'),
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: SelectableText(
                key: const PageStorageKey('receipt-original-text-selection'),
                evidence.rawText.isEmpty
                    ? 'No text was recognized. Enter details from the image.'
                    : evidence.rawText,
              ),
            ),
          ],
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: state.rememberCategory,
          onChanged: (v) => controller.rememberCategory(v ?? false),
          title: const Text('Remember category for this merchant'),
        ),
        CheckboxListTile(
          key: const ValueKey('receipt-confirm'),
          contentPadding: EdgeInsets.zero,
          value: evidence.confirmed,
          onChanged: (v) => controller.confirm(v ?? false),
          title: const Text(
            'I verified the merchant, date, total and items against the receipt.',
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          key: const ValueKey('save-receipt'),
          onPressed: state.busy ? null : save,
          icon: const Icon(Icons.task_alt, size: 20, color: AppColors.primary),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primarySoft,
            foregroundColor: AppColors.primaryStrong,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          label: Text(
            'Confirm & Save Transaction${draft.total > 0 && evidence.currency == 'PHP' ? ' — ${MoneyFormatter.php(draft.total)}' : ''}',
            textAlign: TextAlign.center,
            style: AppTypography.headlineSmall,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => replace(
                  () => controller.acquire(ReceiptImageSource.camera),
                ),
                icon: const Icon(
                  Icons.replay,
                  size: 18,
                  color: AppColors.primary,
                ),
                label: const Text('Retake Photo'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: close,
                icon: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: AppColors.primary,
                ),
                label: const Text('Discard'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
