import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

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
                  icon: const Icon(Icons.close),
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
