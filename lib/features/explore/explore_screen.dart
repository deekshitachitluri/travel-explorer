import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../providers/destination_provider.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/destination_card.dart';
import '../../widgets/empty_state_view.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final destProvider = context.read<DestinationProvider>();
    _searchController.text = destProvider.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterModal(BuildContext context) {
    final destProvider = context.read<DestinationProvider>();
    double tempBudget = destProvider.maxBudgetFilter ?? 5000.0;
    int? tempDuration = destProvider.maxDurationFilter;
    String tempSort = destProvider.selectedSort;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.creamSurface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.dividerDark
                          : AppColors.creamBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter & Sort',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          tempBudget = 5000.0;
                          tempDuration = null;
                          tempSort = AppConstants.sortPopularity;
                        });
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 12),

                // Sort Dropdown
                Text(
                  'Sort Destinations By',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.backgroundDark
                        : AppColors.warmCream,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: isDark
                          ? AppColors.dividerDark
                          : AppColors.creamBorder,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: tempSort,
                      isExpanded: true,
                      items: AppConstants.sortOptions.map((opt) {
                        return DropdownMenuItem(
                          value: opt,
                          child: Text(
                            opt,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => tempSort = val);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Daily Budget Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Max Daily Budget',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      'Up to ${Formatters.formatCurrency(tempBudget)}/day',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.mutedSage
                            : AppColors.forestGreen,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: tempBudget,
                  min: 1500,
                  max: 6000,
                  divisions: 9,
                  activeColor: isDark
                      ? AppColors.mutedSage
                      : AppColors.forestGreen,
                  label: Formatters.formatCurrency(tempBudget),
                  onChanged: (val) {
                    setModalState(() => tempBudget = val);
                  },
                ),
                const SizedBox(height: 14),

                // Trip Duration Filter
                Text(
                  'Trip Duration (Days)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildDurationOption(
                      'Any',
                      null,
                      tempDuration,
                      (v) => setModalState(() => tempDuration = v),
                    ),
                    const SizedBox(width: 8),
                    _buildDurationOption(
                      '≤ 3 Days',
                      3,
                      tempDuration,
                      (v) => setModalState(() => tempDuration = v),
                    ),
                    const SizedBox(width: 8),
                    _buildDurationOption(
                      '≤ 5 Days',
                      5,
                      tempDuration,
                      (v) => setModalState(() => tempDuration = v),
                    ),
                    const SizedBox(width: 8),
                    _buildDurationOption(
                      '≤ 7 Days',
                      7,
                      tempDuration,
                      (v) => setModalState(() => tempDuration = v),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Apply Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      destProvider.setSelectedSort(tempSort);
                      destProvider.setBudgetFilter(
                        tempBudget < 6000 ? tempBudget : null,
                      );
                      destProvider.setDurationFilter(tempDuration);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDurationOption(
    String label,
    int? value,
    int? currentValue,
    Function(int?) onSelect,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = currentValue == value;
    return Expanded(
      child: OutlinedButton(
        onPressed: () => onSelect(value),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10),
          side: BorderSide(
            color: isSelected
                ? (isDark ? AppColors.mutedSage : AppColors.forestGreen)
                : (isDark ? AppColors.dividerDark : AppColors.creamBorder),
            width: isSelected ? 1.5 : 1.0,
          ),
          backgroundColor: isSelected
              ? (isDark ? AppColors.forestGreenDark : AppColors.mutedSageLight)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? (isDark ? AppColors.warmCream : AppColors.forestGreen)
                : null,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final destProvider = context.watch<DestinationProvider>();
    final destinations = destProvider.filteredDestinations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Destinations'),
        actions: [
          IconButton(
            tooltip: 'Interactive Map View',
            icon: const Icon(Icons.map_rounded),
            onPressed: () => context.push('/map'),
          ),
          IconButton(
            tooltip: 'Filter & Sort',
            icon: Stack(
              children: [
                const Icon(Icons.tune_rounded),
                if (destProvider.maxBudgetFilter != null ||
                    destProvider.maxDurationFilter != null ||
                    destProvider.selectedSort != AppConstants.sortPopularity)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.terracotta,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => _showFilterModal(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => destProvider.setSearchQuery(val),
              decoration: InputDecoration(
                hintText:
                    'Search city, state, or tags (e.g. Goa, snow, temples)...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          destProvider.setSearchQuery('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // 2. Category Chips
          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: AppConstants.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = AppConstants.categories[index];
                final isSelected = destProvider.selectedCategory == category;
                return CategoryChip(
                  label: category,
                  isSelected: isSelected,
                  onTap: () => destProvider.setSelectedCategory(category),
                );
              },
            ),
          ),

          // 3. Status Bar (Count & Active Filters Summary)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${destinations.length} ${destinations.length == 1 ? 'destination' : 'destinations'} found',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => context.push('/map'),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.forestGreen.withValues(
                              alpha: 0.08,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.mutedSage.withValues(alpha: 0.5)
                                  : AppColors.forestGreen.withValues(
                                      alpha: 0.3,
                                    ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.map_rounded,
                                size: 13,
                                color: isDark
                                    ? AppColors.mutedSage
                                    : AppColors.forestGreen,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Map View',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.mutedSage
                                      : AppColors.forestGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (destProvider.searchQuery.isNotEmpty ||
                    destProvider.selectedCategory != AppConstants.categoryAll ||
                    destProvider.maxBudgetFilter != null ||
                    destProvider.maxDurationFilter != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      destProvider.resetFilters();
                    },
                    child: Text(
                      'Clear Filters',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.mutedSage
                            : AppColors.forestGreen,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 4. Destinations List / Grid
          Expanded(
            child: destinations.isEmpty
                ? EmptyStateView(
                    icon: Icons.travel_explore_rounded,
                    title: 'No Destinations Found',
                    message: 'We couldn\'t find any destinations matching your current filters. Try searching with different keywords or clearing filters.',
                    buttonText: 'Reset Filters',
                    onButtonPressed: () {
                      _searchController.clear();
                      destProvider.resetFilters();
                    },
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      // Responsive column count based on available screen width
                      final crossAxisCount = width > 1100
                          ? 4
                          : (width > 720 ? 3 : (width < 330 ? 1 : 2));

                      // Responsive mainAxisExtent: guarantees sufficient vertical space
                      // across all viewport sizes without RenderFlex overflow stripes
                      final double cardExtent = width > 900
                          ? 290.0
                          : (width > 600
                                ? 275.0
                                : (width < 360 ? 250.0 : 260.0));

                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisExtent: cardExtent,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemCount: destinations.length,
                        itemBuilder: (context, index) {
                          final dest = destinations[index];
                          return DestinationCard(
                            destination: dest,
                            onTap: () {
                              destProvider.markAsViewed(dest.id);
                              context.push('/destination/${dest.id}');
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
