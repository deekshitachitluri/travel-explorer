import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Interactive map marker styled specifically for an attraction stop.
class AttractionMapMarker extends StatelessWidget {
  final String attractionName;
  final bool isSelected;
  final VoidCallback onTap;

  const AttractionMapMarker({
    super.key,
    required this.attractionName,
    this.isSelected = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const markerColor = AppColors.accentAmber;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Attraction name pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.creamSurface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: markerColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, size: 11, color: markerColor),
                const SizedBox(width: 3),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 90),
                  child: Text(
                    attractionName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: markerColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          // Pin Head
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: markerColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: markerColor.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.place_rounded, size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
