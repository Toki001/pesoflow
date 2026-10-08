import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

class ReceiptPreview extends StatelessWidget {
  const ReceiptPreview({
    this.bytes,
    this.busy = false,
    this.onClose,
    this.onCamera,
    this.onGallery,
    this.onCrop,
    super.key,
  });
  final Uint8List? bytes;
  final bool busy;
  final VoidCallback? onClose, onCamera, onGallery, onCrop;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 340,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Close receipt',
                onPressed: busy ? null : onClose,
                icon: const Icon(Icons.close, color: Colors.white),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      bytes == null ? 'RECEIPT SCANNER' : 'ON-DEVICE OCR',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Take another photo',
                onPressed: onCamera,
                icon: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                ),
              ),
              IconButton(
                tooltip: 'Select receipt image',
                onPressed: onGallery,
                icon: const Icon(
                  Icons.photo_library_outlined,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 56),
            child: Container(
              width: 260,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: .6),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(6),
              child: bytes == null
                  ? const Center(
                      child: Icon(
                        Icons.receipt_long_outlined,
                        size: 72,
                        color: Colors.white54,
                      ),
                    )
                  : InkWell(
                      onTap: () => showReceiptImage(context, bytes!),
                      child: receiptImage(bytes!, fit: BoxFit.contain),
                    ),
            ),
          ),
        ),
        TextButton.icon(
          onPressed: onCrop,
          icon: Icon(
            bytes == null ? Icons.tips_and_updates_outlined : Icons.crop_rotate,
            color: Colors.white70,
            size: 16,
          ),
          label: Text(
            bytes == null
                ? 'Keep the full receipt in focus'
                : 'Tap to adjust frame & rotate',
            style: AppTypography.bodySmall.copyWith(color: Colors.white70),
          ),
        ),
        const SizedBox(height: 20),
      ],
    ),
  );
}

Widget receiptImage(Uint8List bytes, {BoxFit fit = BoxFit.contain}) =>
    Image.memory(
      bytes,
      fit: fit,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => const Center(
        child: Text(
          'Receipt image cannot be displayed.',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
      semanticLabel: 'Captured receipt image',
    );
Future<void> showReceiptImage(BuildContext context, Uint8List bytes) =>
    showDialog<void>(
      context: context,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: AppColors.darkSurface,
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: 'Close image',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
              Expanded(
                child: InteractiveViewer(
                  minScale: .5,
                  maxScale: 6,
                  child: Center(child: receiptImage(bytes)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
