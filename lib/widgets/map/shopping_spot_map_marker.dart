import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/shopping_spot.dart';

/// Interactive map marker styled specifically for authentic local shopping spots and bazaars.
class ShoppingSpotMapMarker extends StatelessWidget {
  final ShoppingSpot spot;
  final bool isSelected;
  final VoidCallback onTap;

  const ShoppingSpotMapMarker({
    super.key,
    required this.spot,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const markerColor = AppColors.terracotta;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Spot Name Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.creamSurface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: isSelected ? markerColor : markerColor.withOpacity(0.7),
                width: isSelected ? 2.0 : 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🛍️', style: TextStyle(fontSize: 10)),
                const SizedBox(width: 3),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 85),
                  child: Text(
                    spot.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: markerColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          // Shopping Pin Head
          Container(
            width: isSelected ? 38 : 34,
            height: isSelected ? 38 : 34,
            decoration: BoxDecoration(
              color: markerColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: isSelected ? 2.5 : 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: markerColor.withOpacity(isSelected ? 0.55 : 0.35),
                  blurRadius: isSelected ? 9 : 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.shopping_bag_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
