import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

/// Native illustration of the fixture. No remote photograph or camera feed.
class ReceiptViewfinder extends StatelessWidget {
  const ReceiptViewfinder({
    required this.onClose,
    required this.onGallery,
    required this.onFrame,
    required this.onFlash,
    required this.flash,
    super.key,
  });
  final VoidCallback onClose, onGallery, onFrame, onFlash;
  final String flash;
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.darkSurfaceSubtle,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Dismiss review',
                onPressed: onClose,
                icon: const Icon(
                  Icons.close,
                  size: 20,
                  color: AppColors.darkInk,
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    border: Border.all(color: AppColors.darkBorder),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.circle,
                        size: 8,
                        color: AppColors.positive,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Demo receipt • 98% sample confidence',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.darkInk,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onFlash,
                icon: const Icon(
                  Icons.flash_auto,
                  size: 18,
                  color: AppColors.warning,
                ),
                label: Text(
                  flash,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.darkInk,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Choose demo receipt',
                onPressed: onGallery,
                icon: const Icon(
                  Icons.photo_library_outlined,
                  size: 20,
                  color: AppColors.darkInk,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Semantics(
            label: 'Illustrative SM Supermarket receipt preview. No camera capture.',
            child: ExcludeSemantics(
              child: MediaQuery.withNoTextScaling(
                child: SizedBox(
                  width: 260,
                  height: 228,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.darkSurfaceMuted,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: .65),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: .12),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: .6),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'SM SUPERMARKET',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.darkInkSecondary,
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  'MEGAMALL BRANCH #042',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.darkInkMuted,
                                    fontSize: 8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          for (final text in [
                            'SELECT FRESH MILK     108.50',
                            'GARDENIA CLASSIC       75.00',
                            'FUJI APPLES           160.00',
                            'PUREFOODS BUNDLE      182.00',
                          ])
                            Text(
                              text,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.darkInkMuted.withValues(
                                  alpha: .5,
                                ),
                                fontSize: 8,
                              ),
                            ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            color: AppColors.positive.withValues(alpha: .2),
                            child: Text(
                              'TOTAL ₱525.50',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.darkPositive,
                                fontSize: 8,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '24/10/2024',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.darkInkMuted,
                                  fontSize: 8,
                                ),
                              ),
                              Text(
                                '11:42 AM',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.darkInkMuted,
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Demo frame preview',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.darkInkMuted,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onFrame,
                icon: const Icon(
                  Icons.crop,
                  size: 16,
                  color: AppColors.darkPrimary,
                ),
                label: Text(
                  'Adjust Frame',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.darkPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
