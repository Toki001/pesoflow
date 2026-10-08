import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/formatting/money_formatter.dart';
import '../../../core/widgets/finance_card.dart';
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
          'A successful new scan will replace your unsaved corrections. Cancelling capture keeps this review.',
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
                      ReceiptPreview(
                        bytes: state.image?.bytes,
                        busy: locked,
                        onClose: close,
                        onCamera: locked
                            ? null
                            : () => replace(
                                () => controller.acquire(
                                  ReceiptImageSource.camera,
                                ),
                              ),
                        onGallery: locked
                            ? null
                            : () => replace(
                                () => controller.acquire(
                                  ReceiptImageSource.photos,
                                ),
                              ),
                        onCrop: locked || state.image == null
                            ? null
                            : () => replace(controller.crop),
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
                              if (state.progress != null) ...[
                                Semantics(
                                  liveRegion: true,
                                  child: Text(
                                    state.progress!,
                                    style: AppTypography.headlineSmall,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const LinearProgressIndicator(),
                                const SizedBox(height: 20),
                              ],
                              if (state.error != null) ...[
                                FinanceCard(
                                  color: c.soft(
                                    c.warning,
                                    AppColors.warningSoft,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Semantics(
                                        liveRegion: true,
                                        child: Text(state.error!.message),
                                      ),
                                      if (state.error!.settings)
                                        TextButton(
                                          onPressed: controller.openSettings,
                                          child: const Text(
                                            'Open device Settings',
                                          ),
                                        ),
                                      if (state.image != null)
                                        TextButton(
                                          onPressed: locked
                                              ? null
                                              : () => replace(controller.retry),
                                          child: const Text(
                                            'Retry text recognition',
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              if (state.draft == null && !locked) ...[
                                Text(
                                  'Scan a receipt',
                                  style: AppTypography.headlineMedium,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Take a clear photo or select a receipt image. Text is read on your device. You review every expense before saving.',
                                ),
                                const SizedBox(height: 20),
                                FilledButton.icon(
                                  onPressed: () => controller.acquire(
                                    ReceiptImageSource.camera,
                                  ),
                                  icon: const Icon(Icons.camera_alt_outlined),
                                  label: const Text('Take receipt photo'),
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  onPressed: () => controller.acquire(
                                    ReceiptImageSource.photos,
                                  ),
                                  icon: const Icon(
                                    Icons.photo_library_outlined,
                                  ),
                                  label: const Text('Choose receipt photo'),
                                ),
                              ],
                              if (state.draft != null)
                                AbsorbPointer(
                                  absorbing: locked,
                                  child: Material(
                                    color: c.surface,
                                    child: content(state),
                                  ),
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

  Widget content(ReceiptScanState state) {
    final draft = state.draft!;
    final evidence = draft.evidence!;
    final controller = ref.read(receiptScanProvider.notifier);
    final c = context.colors;
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
                evidence.confirmed ? 'Reviewed' : 'Ready to review',
                foreground: c.positive,
                background: c.soft(c.positive, AppColors.positiveSoft),
                icon: Icons.check_circle_outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'On-device extraction · verify against your receipt',
          style: AppTypography.bodyMedium.copyWith(color: c.mutedInk),
        ),
        const SizedBox(height: 20),
        ReceiptMerchantCard(
          draft: draft,
          onMerchant: () async {
            final value = await editReceiptMerchant(context, draft.merchant);
            if (value != null && mounted) controller.setMerchant(value);
          },
          onDate: () => date(draft),
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
              icon: const Icon(Icons.add, size: 16),
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
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: const Text('Original extracted text'),
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: SelectableText(
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
          icon: const Icon(Icons.task_alt, size: 20),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
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
                icon: const Icon(Icons.replay, size: 18),
                label: const Text('Retake Photo'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: close,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Discard'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
