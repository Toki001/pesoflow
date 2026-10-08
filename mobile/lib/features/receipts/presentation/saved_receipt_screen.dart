import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_typography.dart';
import '../../workspace/application/finance_controller.dart';
import '../application/receipt_scan_controller.dart';
import 'widgets/receipt_review_cards.dart';
import 'widgets/receipt_preview.dart';

class SavedReceiptScreen extends ConsumerWidget {
  const SavedReceiptScreen({required this.transactionId, super.key});
  final String transactionId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(workspaceProvider).receipts[transactionId];
    final evidence = draft?.evidence;
    return Scaffold(
      appBar: AppBar(title: const Text('Saved receipt')),
      body: SafeArea(
        child: draft == null
            ? const Center(child: Text('Receipt no longer available.'))
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 512),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (evidence != null)
                        ref
                            .watch(receiptImageProvider(evidence.imageId))
                            .when(
                              loading: () => const SizedBox(
                                height: 220,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              error: (_, _) => Column(
                                children: [
                                  const Text(
                                    'Receipt image could not be opened.',
                                  ),
                                  TextButton(
                                    onPressed: () => ref.invalidate(
                                      receiptImageProvider(evidence.imageId),
                                    ),
                                    child: const Text('Retry image'),
                                  ),
                                ],
                              ),
                              data: (bytes) => bytes == null
                                  ? const Text('Receipt image is unavailable.')
                                  : SizedBox(
                                      height: 260,
                                      child: ColoredBox(
                                        color: Colors.black87,
                                        child: InkWell(
                                          onTap: () =>
                                              showReceiptImage(context, bytes),
                                          child: receiptImage(bytes),
                                        ),
                                      ),
                                    ),
                            )
                      else
                        const Text(
                          'This earlier receipt has no captured image.',
                        ),
                      const SizedBox(height: 20),
                      Text(
                        'Reviewed receipt',
                        style: AppTypography.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      ReceiptMerchantCard(
                        draft: draft,
                        onMerchant: null,
                        onDate: null,
                      ),
                      const SizedBox(height: 16),
                      ReceiptItemsCard(items: draft.items, onItem: null),
                      const SizedBox(height: 16),
                      ReceiptTotalsCard(draft),
                      const SizedBox(height: 16),
                      ReceiptAssignments(
                        draft: draft,
                        onCategory: null,
                        onAccount: null,
                      ),
                      if (evidence != null)
                        ExpansionTile(
                          title: const Text('Original extracted text'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: SelectableText(
                                evidence.rawText.isEmpty
                                    ? 'Details entered manually.'
                                    : evidence.rawText,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
