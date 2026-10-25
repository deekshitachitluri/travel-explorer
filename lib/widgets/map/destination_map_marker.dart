import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/destination.dart';

/// Interactive map marker styled according to the destination's natural category palette.
class DestinationMapMarker extends StatelessWidget {
  final Destination destination;
  final bool isSelected;
  final VoidCallback onTap;

  const DestinationMapMarker({
    super.key,
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'beaches':
        return Icons.beach_access_rounded;
      case 'mountains':
        return Icons.terrain_rounded;
      case 'heritage':
        return Icons.account_balance_rounded;
      case 'adventure':
        return Icons.paragliding_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = destination.palette;
    final pinColor = palette.currentPrimary(isDark);
    final size = isSelected ? 46.0 : 38.0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: isSelected ? 1.15 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Floating destination pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: isSelected ? pinColor : palette.cardBorder,
                  width: isSelected ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isSelected ? 0.25 : 0.12),
                    blurRadius: isSelected ? 6 : 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    destination.name,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: isSelected
                          ? pinColor
                          : (isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight),
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 3),
                    const Icon(
                      Icons.star_rounded,
                      size: 11,
                      color: AppColors.accentAmber,
                    ),
                    Text(
                      destination.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 2),
            // Pin Head Circle
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: pinColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: isSelected ? 2.5 : 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: pinColor.withOpacity(0.4),
                    blurRadius: isSelected ? 8 : 4,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  _getCategoryIcon(destination.category),
                  size: isSelected ? 22 : 18,
                  color: palette.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
