import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/identity/new_id.dart';
import '../../../core/time/clock.dart';
import '../../accounts/domain/ledger_account.dart';
import '../../accounts/domain/financial_account.dart';
import '../../transactions/domain/categorization.dart';
import '../../transactions/domain/transaction.dart';
import '../../workspace/application/finance_controller.dart';
import '../data/mlkit_receipt_ocr.dart';
import '../data/native_receipt_images.dart';
import '../domain/ocr_document.dart';
import '../domain/receipt_draft.dart';
import '../domain/receipt_evidence.dart';
import '../domain/receipt_image.dart';
import '../domain/receipt_image_repository.dart';
import '../domain/receipt_parser.dart';

final receiptImagesProvider = Provider<ReceiptImages>(
  (ref) => NativeReceiptImages(),
);
final receiptOcrProvider = Provider<ReceiptOcrService>(
  (ref) => MlKitReceiptOcr(),
);
final receiptScanProvider =
    NotifierProvider.autoDispose<ReceiptScanController, ReceiptScanState>(
      ReceiptScanController.new,
    );
final receiptImageProvider = FutureProvider.autoDispose
    .family<Uint8List?, String>((ref, imageId) {
      final repository = ref.watch(financeRepositoryProvider);
      return (repository as ReceiptImageRepository).loadReceiptImage(imageId);
    });

class ReceiptScanState {
  const ReceiptScanState({
    this.image,
    this.draft,
    this.progress,
    this.error,
    this.rememberCategory = false,
  });
  final ReceiptImage? image;
  final ReceiptDraft? draft;
  final String? progress;
  final ReceiptFailure? error;
  final bool rememberCategory;
  bool get busy => progress != null;
}

/// One review session. Native OCR and parsing never mutate financial state;
/// only explicit confirmation invokes the existing durable command.
class ReceiptScanController extends Notifier<ReceiptScanState> {
  ReceiptImage? _image;
  late ReceiptImages _images;
  bool _recovered = false;
  @override
  ReceiptScanState build() {
    _images = ref.read(receiptImagesProvider);
    ref.onDispose(() {
      final image = _image;
      if (image != null) unawaited(_images.release(image));
    });
    return const ReceiptScanState();
  }

  void _publish({
    ReceiptDraft? draft,
    String? progress,
    ReceiptFailure? error,
    bool? remember,
  }) {
    if (ref.mounted) {
      state = ReceiptScanState(
        image: _image,
        draft: draft ?? state.draft,
        progress: progress,
        error: error,
        rememberCategory: remember ?? state.rememberCategory,
      );
    }
  }

  Future<void> recover() async {
    if (_recovered || state.busy || _image != null) return;
    _recovered = true;
    await _acquire(_images.recover);
  }

  Future<void> openSettings() async {
    try {
      await _images.openSettings();
    } catch (_) {
      _publish(
        error: const ReceiptFailure(
          'Open device Settings and choose PesoFlow to manage Camera access.',
        ),
      );
    }
  }

  Future<void> acquire(ReceiptImageSource source) =>
      _acquire(() => _images.acquire(source));
  Future<void> crop() async {
    final image = _image;
    if (image != null) await _acquire(() => _images.crop(image));
  }

  Future<void> _acquire(Future<ReceiptImage?> Function() action) async {
    if (state.busy || state.draft?.savedTransactionId != null) return;
    _publish(progress: 'Processing receipt…');
    try {
      final image = await action();
      if (!ref.mounted) {
        if (image != null) await _images.release(image);
        return;
      }
      if (image == null) {
        _publish();
        return;
      }
      final old = _image;
      _image = image;
      state = ReceiptScanState(image: image, progress: 'Reading text…');
      if (old != null && old.path != image.path) await _images.release(old);
      await _recognize();
    } catch (error) {
      _publish(
        error: error is ReceiptFailure
            ? error
            : const ReceiptFailure(
                'The image could not be opened. Please try another photo.',
              ),
      );
    }
  }

  Future<void> retry() async {
    if (state.busy ||
        _image == null ||
        state.draft?.savedTransactionId != null) {
      return;
    }
    await _recognize();
  }

  Future<void> _recognize() async {
    final image = _image!;
    _publish(progress: 'Reading text…');
    try {
      final document = await ref.read(receiptOcrProvider).recognize(image.path);
      if (!ref.mounted) return;
      _publish(progress: 'Extracting items…');
      final parsed = await Isolate.run(() => ReceiptParser.parse(document));
      if (!ref.mounted) return;
      _publish(draft: _draft(parsed));
    } catch (error) {
      if (!ref.mounted) return;
      _publish(
        draft: state.draft ?? _draft(ReceiptParser.parse(OcrDocument('', []))),
        error: error is ReceiptFailure
            ? error
            : const ReceiptFailure(
                'Receipt details could not be extracted. Retry or enter them manually.',
              ),
      );
    }
  }

  ReceiptDraft _draft(ParsedReceipt parsed) {
    final id = newId();
    final now = ref.read(clockProvider)();
    final workspace = ref.read(workspaceProvider);
    final defaultAccount = workspace.accounts
        .where(
          (a) =>
              a.id == workspace.preferences.defaultAccountId &&
              !a.archived &&
              a.source == BalanceSource.manual,
        )
        .firstOrNull;
    return ReceiptDraft(
      id: id,
      merchant: parsed.merchant,
      accountId: defaultAccount?.id ?? '',
      account: defaultAccount?.name ?? '',
      occurredAt: parsed.date ?? now,
      items: parsed.items,
      category: categorize(
        kind: TransactionKind.expense,
        merchant: parsed.merchant,
        userRules: ref.read(workspaceProvider).merchantRules,
      ),
      evidence: ReceiptEvidence(
        imageId: id,
        rawText: parsed.rawText,
        createdAt: now,
        total: parsed.total ?? 0,
        subtotal: parsed.subtotal,
        tax: parsed.tax,
        discount: parsed.discount,
        currency: parsed.currency,
        paymentMethod: parsed.paymentMethod,
        parserVersion: ReceiptParser.version,
        confidence: parsed.confidence,
        warnings: parsed.warnings,
      ),
    );
  }

  void setDraft(ReceiptDraft value) {
    if (state.busy ||
        state.draft?.savedTransactionId != null ||
        value.id != state.draft?.id) {
      return;
    }
    _publish(
      draft: value.copyWith(
        evidence: value.evidence!.copyWith(confirmed: false),
      ),
    );
  }

  void setMerchant(String value) {
    final d = state.draft;
    if (d == null) return;
    setDraft(
      d.copyWith(
        merchant: value.trim(),
        category: categorize(
          kind: TransactionKind.expense,
          merchant: value,
          userRules: ref.read(workspaceProvider).merchantRules,
        ),
      ),
    );
  }

  void setNote(String value) {
    final d = state.draft;
    if (d != null) setDraft(d.copyWith(note: value));
  }

  void setDate(DateTime value) {
    final d = state.draft;
    if (d != null) setDraft(d.copyWith(occurredAt: value));
  }

  void setCategory(TransactionCategory value) {
    final d = state.draft;
    if (d != null) setDraft(d.copyWith(category: value));
  }

  void setAccount(LedgerAccount value) {
    final d = state.draft;
    if (d != null) {
      setDraft(d.copyWith(account: value.label, accountId: value.id));
    }
  }

  String nextItemId() => newId();
  void saveItem(ReceiptItem item) {
    final d = state.draft;
    if (d == null) return;
    setDraft(
      d.copyWith(
        items: [
          for (final i in d.items)
            if (i.id == item.id) item else i,
          if (!d.items.any((i) => i.id == item.id)) item,
        ],
      ),
    );
  }

  void removeItem(String id) {
    final d = state.draft;
    if (d != null) {
      setDraft(d.copyWith(items: d.items.where((i) => i.id != id).toList()));
    }
  }

  void confirm(bool value) {
    final d = state.draft;
    if (d != null && !state.busy && d.savedTransactionId == null) {
      _publish(
        draft: d.copyWith(evidence: d.evidence!.copyWith(confirmed: value)),
      );
    }
  }

  void rememberCategory(bool value) {
    if (!state.busy) _publish(remember: value);
  }

  Future<String?> save() async {
    final d = state.draft;
    if (state.busy || d == null || _image == null) return null;
    if (d.savedTransactionId != null) return d.savedTransactionId;
    if (d.validationError != null) {
      _publish(error: ReceiptFailure(d.validationError!));
      return null;
    }
    _publish(progress: 'Saving receipt…');
    try {
      final id = await ref
          .read(financeControllerProvider.notifier)
          .saveReceipt(
            d,
            imageBytes: _image!.bytes,
            rememberCategory: state.rememberCategory,
          );
      _publish(draft: d.copyWith(savedTransactionId: id));
      await _images.release(_image!);
      return id;
    } catch (_) {
      _publish(
        error: const ReceiptFailure(
          'The receipt could not be saved. Your review is intact. Check available storage and retry.',
        ),
      );
      return null;
    }
  }
}
