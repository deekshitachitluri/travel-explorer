import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../models/shopping_spot.dart';

/// Floating bottom preview card displayed when selecting a shopping spot pin on the interactive map.
class ShoppingSpotPreviewCard extends StatelessWidget {
  final ShoppingSpot spot;
  final VoidCallback onClose;
  final VoidCallback? onBackToDestination;

  const ShoppingSpotPreviewCard({
    super.key,
    required this.spot,
    required this.onClose,
    this.onBackToDestination,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.surfaceDark : AppColors.creamSurface)
            .withOpacity(0.98),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.creamBorder,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shopping icon avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.terracotta.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppColors.terracotta.withOpacity(0.3),
                  ),
                ),
                child: const Center(
                  child: Text('🛍️', style: TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.terracotta.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: const Text(
                        'LOCAL TREASURE & SHOPPING',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.terracotta,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      spot.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: AppColors.mutedSage,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            spot.locality,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.mutedSage,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: onClose,
                visualDensity: VisualDensity.compact,
                tooltip: 'Close preview',
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Known For Description
          Text(
            spot.knownFor,
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? AppColors.textSecondaryDark : AppColors.charcoal,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 10),

          // Specialities Wrap
          Wrap(
            spacing: 6,
            runSpacing: 5,
            children: spot.specialities.map((spec) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.cardDark
                      : AppColors.warmCream.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: isDark
                        ? AppColors.dividerDark
                        : AppColors.creamBorder,
                  ),
                ),
                child: Text(
                  '✨ $spec',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.creamSurface
                        : AppColors.forestGreen,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 10),

          // Opening Hours & Tips
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 14,
                color: AppColors.terracotta,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  spot.openingHours,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          if (spot.tips != null) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 14,
                  color: AppColors.accentAmber,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    spot.tips!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: AppColors.mutedSage,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark
                        ? AppColors.creamSurface
                        : AppColors.forestGreen,
                    side: BorderSide(
                      color: isDark
                          ? AppColors.dividerDark
                          : AppColors.forestGreen.withOpacity(0.4),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: const Text('Back to Destination'),
                  onPressed: () {
                    if (onBackToDestination != null) {
                      onBackToDestination!();
                    } else {
                      context.push('/destination/${spot.destinationId}');
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.terracotta,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.check_rounded, size: 16),
                label: const Text('Got it'),
                onPressed: onClose,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
