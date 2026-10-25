import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getIconForCategory(String category) {
    switch (category) {
      case AppConstants.categoryBeaches:
        return Icons.beach_access_rounded;
      case AppConstants.categoryMountains:
        return Icons.terrain_rounded;
      case AppConstants.categoryHeritage:
        return Icons.account_balance_rounded;
      case AppConstants.categoryAdventure:
        return Icons.hiking_rounded;
      case AppConstants.categorySpiritual:
        return Icons.temple_hindu_rounded;
      case AppConstants.categoryAll:
      default:
        return Icons.explore_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = CategoryPalette.forCategory(label);
    final primaryCol = palette.currentPrimary(isDark);
    final bgCol = isSelected
        ? primaryCol
        : (isDark ? palette.darkSurface : palette.backgroundTint);
    final borderCol = isSelected ? primaryCol : palette.currentBorder(isDark);
    final contentCol = isSelected
        ? palette.onPrimary
        : (isDark ? palette.darkPrimary : palette.primary);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: bgCol,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(color: borderCol, width: isSelected ? 1.5 : 1.0),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primaryCol.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getIconForCategory(label), size: 16, color: contentCol),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: contentCol,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
