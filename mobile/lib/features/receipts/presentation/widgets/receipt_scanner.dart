import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

/// Native-camera entry, not a simulated camera feed. Capture opens the device's
/// tested camera adapter; the frame is guidance until an actual image exists.
class ReceiptScanner extends StatelessWidget {
  const ReceiptScanner({
    required this.onClose,
    required this.onCamera,
    required this.onGallery,
    required this.status,
    super.key,
  });
  final VoidCallback? onClose, onCamera, onGallery;
  final Widget status;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.darkSurface,
    body: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Close receipt',
                  onPressed: onClose,
                  icon: const Icon(Icons.close, color: AppColors.primary),
                ),
                Expanded(
                  child: Text(
                    'RECEIPT SCANNER',
                    textAlign: TextAlign.center,
                    style: AppTypography.labelMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Select receipt image',
                  onPressed: onGallery,
                  icon: const Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(40, 24, 40, 24),
              constraints: const BoxConstraints(minHeight: 330),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 72,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Keep the full receipt in focus',
                    textAlign: TextAlign.center,
                    style: AppTypography.headlineSmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Open the camera to take a clear photo. You will review every expense before saving.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: status,
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primarySoft,
                      foregroundColor: AppColors.primaryStrong,
                    ),
                    onPressed: onCamera,
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: AppColors.primary,
                    ),
                    label: const Text('Take receipt photo'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: onGallery,
                    icon: const Icon(
                      Icons.photo_library_outlined,
                      color: AppColors.primary,
                    ),
                    label: const Text('Choose receipt photo'),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Single receipt · On-device text recognition',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
