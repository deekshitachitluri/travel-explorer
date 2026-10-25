import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../providers/destination_provider.dart';
import '../../services/recommendation_service.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/rating_badge.dart';

class TravelMatcherScreen extends StatefulWidget {
  const TravelMatcherScreen({super.key});

  @override
  State<TravelMatcherScreen> createState() => _TravelMatcherScreenState();
}

class _TravelMatcherScreenState extends State<TravelMatcherScreen> {
  String? _selectedCategory;
  double _maxDailyBudget = 3500.0;
  int? _tripDuration = 4;
  String? _selectedSeason;
  final Set<String> _selectedInterests = {
    'Nature & Wildlife',
    'Beaches & Coastal',
  };

  List<DestinationMatchResult>? _results;

  void _runMatcher() {
    final destProvider = context.read<DestinationProvider>();
    final criteria = MatchCriteria(
      preferredCategory: _selectedCategory,
      maxDailyBudget: _maxDailyBudget,
      preferredDurationDays: _tripDuration,
      interests: _selectedInterests.toList(),
      preferredSeason: _selectedSeason,
    );

    final matches = RecommendationService.matchDestinations(
      allDestinations: destProvider.allDestinations,
      criteria: criteria,
    );

    setState(() {
      _results = matches;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Smart Destination Matcher')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Explanation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.creamSurface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: isDark
                      ? AppColors.dividerDark
                      : AppColors.mutedSage.withOpacity(0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.forestGreen,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tell us what you\'re looking for and our transparent local matching algorithm will score India\'s best destinations for you.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 1. Preferred Category
            Text(
              '1. Preferred Category',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  [
                    'Any Category',
                    AppConstants.categoryBeaches,
                    AppConstants.categoryMountains,
                    AppConstants.categoryHeritage,
                    AppConstants.categoryAdventure,
                  ].map((cat) {
                    final isSelected =
                        (_selectedCategory == null && cat == 'Any Category') ||
                        _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppColors.forestGreen,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.warmCream
                            : (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight),
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = cat == 'Any Category'
                              ? null
                              : cat;
                        });
                      },
                    );
                  }).toList(),
            ),
            const SizedBox(height: 24),

            // 2. Max Daily Budget
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '2. Max Daily Budget',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  Formatters.formatCurrency(_maxDailyBudget),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.forestGreen,
                  ),
                ),
              ],
            ),
            Slider(
              value: _maxDailyBudget,
              min: 2000,
              max: 5500,
              divisions: 7,
              activeColor: AppColors.forestGreen,
              label: Formatters.formatCurrency(_maxDailyBudget),
              onChanged: (val) => setState(() => _maxDailyBudget = val),
            ),
            const SizedBox(height: 16),

            // 3. Desired Duration
            Text(
              '3. Desired Trip Duration (Days)',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [3, 4, 5, 7].map((days) {
                final isSelected = _tripDuration == days;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isSelected
                            ? AppColors.forestGreen.withOpacity(0.12)
                            : null,
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.forestGreen
                              : (isDark
                                    ? AppColors.dividerDark
                                    : AppColors.creamBorder),
                          width: isSelected ? 1.8 : 1.0,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () => setState(() => _tripDuration = days),
                      child: Text(
                        '$days Days',
                        style: TextStyle(
                          color: isSelected ? AppColors.forestGreen : null,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 4. Interests / Vibes
            Text(
              '4. Travel Interests & Vibe',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.travelInterests.map((interest) {
                final isSelected = _selectedInterests.contains(interest);
                return FilterChip(
                  label: Text(interest),
                  selected: isSelected,
                  selectedColor: AppColors.mutedSage.withOpacity(0.25),
                  checkmarkColor: AppColors.forestGreen,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.forestGreen : null,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedInterests.add(interest);
                      } else {
                        _selectedInterests.remove(interest);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // Match Action Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text(
                  'Find Matching Destinations',
                  style: TextStyle(fontSize: 15),
                ),
                onPressed: _runMatcher,
              ),
            ),

            // Results Section
            if (_results != null) ...[
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ranked Matches (${_results!.length})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const Text(
                    'Scored out of 100',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ..._results!.map(
                (match) => _buildMatchCard(context, match, isDark),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMatchCard(
    BuildContext context,
    DestinationMatchResult match,
    bool isDark,
  ) {
    final dest = match.destination;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.creamSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.creamBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            context.push('/destination/${dest.id}');
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppNetworkImage(
                      imageUrl: dest.imageUrl,
                      width: 80,
                      height: 80,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                dest.name,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.terracotta.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.full,
                                  ),
                                ),
                                child: Text(
                                  '${match.score}% MATCH',
                                  style: const TextStyle(
                                    color: AppColors.terracotta,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${dest.city}, ${dest.state}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              RatingBadge(rating: dest.rating, compact: true),
                              const SizedBox(width: 8),
                              Text(
                                '${Formatters.formatCurrency(dest.estimatedDailyCost)}/day',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.forestGreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 6),
                // Match reasons list
                ...match.matchReasons.map(
                  (reason) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 14,
                          color: AppColors.forestGreen,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            reason,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
