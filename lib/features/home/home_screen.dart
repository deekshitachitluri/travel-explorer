import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/destination.dart';
import '../../models/home_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../providers/destination_provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../services/recommendation_service.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/destination_card.dart';
import '../../widgets/destination_carousel_card.dart';
import '../../widgets/rating_badge.dart';
import 'home_preferences_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _homeSearchController = TextEditingController();
  String _homeSearchQuery = '';
  String _homeCategoryFilter = 'All';
  HomePreferences _homePreferences = HomePreferences.empty;

  @override
  void dispose() {
    _homeSearchController.dispose();
    super.dispose();
  }

  void _openHomePreferencesPanel(BuildContext context) {
    HomePreferencesPanel.show(
      context: context,
      initialPreferences: _homePreferences,
      onApply: (newPrefs) {
        setState(() {
          _homePreferences = newPrefs;
        });
      },
      onReset: () {
        setState(() {
          _homePreferences = HomePreferences.empty;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final destProvider = context.watch<DestinationProvider>();
    final tripProvider = context.watch<TripProvider>();
    final wishlistProvider = context.watch<WishlistProvider>();

    final user = authProvider.currentUser;
    final allDestinations = destProvider.allDestinations;
    final nextTrip = tripProvider.nextUpcomingTrip;

    // Filtered by Category on Home (independent from Explore)
    final filteredByHomeCategory = _homeCategoryFilter == 'All'
        ? allDestinations
        : allDestinations
              .where(
                (d) => d.matchesCategory(_homeCategoryFilter),
              )
              .toList();

    // Featured Hero Destination strictly responding to the selected category
    Destination? featuredDest;
    if (_homeCategoryFilter == 'All') {
      featuredDest = destProvider.findById('goa') ??
          (allDestinations.isNotEmpty ? allDestinations.first : null);
    } else if (filteredByHomeCategory.isNotEmpty) {
      final normCategory = AppConstants.normalizeCategory(_homeCategoryFilter);
      if (normCategory == AppConstants.categoryBeaches) {
        // In Beaches, feature a distinct beach like Andaman (or Goa if not present)
        // so it differs from All's default Goa showcase
        featuredDest = filteredByHomeCategory.firstWhere(
          (d) => d.id == 'andaman',
          orElse: () => filteredByHomeCategory.firstWhere(
            (d) => d.isPopular,
            orElse: () => filteredByHomeCategory.first,
          ),
        );
      } else if (normCategory == AppConstants.categorySpiritual) {
        // In Spiritual, feature Varanasi as the quintessential sacred destination
        featuredDest = filteredByHomeCategory.firstWhere(
          (d) => d.id == 'varanasi',
          orElse: () => filteredByHomeCategory.firstWhere(
            (d) => d.isPopular,
            orElse: () => filteredByHomeCategory.first,
          ),
        );
      } else {
        featuredDest = filteredByHomeCategory.firstWhere(
          (d) => d.isPopular,
          orElse: () => filteredByHomeCategory.first,
        );
      }
    }

    // Filter discovery sections by the selected Home category
    final popularDests = _homeCategoryFilter == 'All'
        ? destProvider.popularDestinations
        : (filteredByHomeCategory.where((d) => d.isPopular).isNotEmpty
            ? filteredByHomeCategory.where((d) => d.isPopular).toList()
            : (List<Destination>.from(filteredByHomeCategory)
                ..sort((a, b) => b.rating.compareTo(a.rating)))
                .take(10)
                .toList());

    final trendingDests = _homeCategoryFilter == 'All'
        ? destProvider.trendingDestinations
        : (filteredByHomeCategory.where((d) => d.isTrending).isNotEmpty
            ? filteredByHomeCategory.where((d) => d.isTrending).toList()
            : (List<Destination>.from(filteredByHomeCategory)
                ..sort((a, b) => b.reviewCount.compareTo(a.reviewCount)))
                .take(8)
                .toList());

    final weekendDests = _homeCategoryFilter == 'All'
        ? destProvider.weekendGetaways
        : filteredByHomeCategory.where((d) => d.isWeekendGetaway).toList();

    final recentDests = _homeCategoryFilter == 'All'
        ? destProvider.recentlyViewedDestinations
        : destProvider.recentlyViewedDestinations
            .where((d) => d.matchesCategory(_homeCategoryFilter))
            .toList();

    // Live Inline Search Filtering (respects active Home category filter and preferences)
    final trimmedQuery = _homeSearchQuery.trim().toLowerCase();
    final isSearching = trimmedQuery.isNotEmpty;
    final searchBase = filteredByHomeCategory;
    final searchResults = isSearching
        ? searchBase.where((d) {
            final name = d.name.toLowerCase();
            final city = d.city.toLowerCase();
            final state = d.state.toLowerCase();
            final category = d.category.toLowerCase();
            final tags = d.tags.map((t) => t.toLowerCase()).toList();
            final matchesText =
                name.contains(trimmedQuery) ||
                city.contains(trimmedQuery) ||
                state.contains(trimmedQuery) ||
                category.contains(trimmedQuery) ||
                tags.any((t) => t.contains(trimmedQuery));
            if (!matchesText) return false;
            return RecommendationService.matchesHomePreferences(
              destination: d,
              preferences: _homePreferences,
            );
          }).toList()
        : <Destination>[];

    // Transparent Personalized Recommendations using Home Preferences
    final userSignalsExist =
        (user?.preferredCategories.isNotEmpty ?? false) ||
        wishlistProvider.wishlistIds.isNotEmpty ||
        destProvider.recentlyViewedIds.isNotEmpty ||
        _homePreferences.isActive;

    final personalizedFeed =
        RecommendationService.getPersonalizedFeedWithHomePreferences(
          allDestinations: filteredByHomeCategory,
          homePreferences: _homePreferences,
          userPreferredCategories: user?.preferredCategories ?? const [],
          wishlistDestinationIds: wishlistProvider.wishlistIds,
          recentlyViewedIds: destProvider.recentlyViewedIds,
          travelStyle: user?.travelStyle,
        );

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 300));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Personalized Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  user != null && !user.isGuest
                                      ? 'Namaste, ${user.displayName.split(' ').first}'
                                      : 'Namaste, Traveler',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text('✨', style: TextStyle(fontSize: 18)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Where would you like to explore next?',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Avatar / Profile entry
                      GestureDetector(
                        onTap: () => context.go('/profile'),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? AppColors.surfaceDark
                                : AppColors.mutedSageLight,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.mutedSage
                                  : AppColors.forestGreen,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: user != null && !user.isGuest
                                ? Text(
                                    user.displayName.isNotEmpty
                                        ? user.displayName
                                              .substring(0, 1)
                                              .toUpperCase()
                                        : 'U',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.mutedSage
                                          : AppColors.forestGreen,
                                      fontSize: 16,
                                    ),
                                  )
                                : Icon(
                                    Icons.person_rounded,
                                    color: isDark
                                        ? AppColors.mutedSage
                                        : AppColors.forestGreen,
                                    size: 24,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Active Inline Search Field (Live search on Home without navigating to Explore)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: TextField(
                    controller: _homeSearchController,
                    onChanged: (val) {
                      setState(() {
                        _homeSearchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search cities, beaches, hills, or heritage...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_homeSearchQuery.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 20),
                              tooltip: 'Clear search',
                              onPressed: () {
                                _homeSearchController.clear();
                                setState(() {
                                  _homeSearchQuery = '';
                                });
                              },
                            ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.tune_rounded, size: 20),
                                tooltip: 'Recommendation Preferences',
                                color: _homePreferences.isActive
                                    ? (isDark
                                          ? AppColors.mutedSage
                                          : AppColors.forestGreen)
                                    : (isDark
                                          ? AppColors.textMutedDark
                                          : AppColors.textMutedLight),
                                onPressed: () =>
                                    _openHomePreferencesPanel(context),
                              ),
                              if (_homePreferences.isActive)
                                Positioned(
                                  top: 8,
                                  right: 8,
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
                        ],
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.surfaceDark
                          : AppColors.creamSurface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppColors.dividerDark
                              : AppColors.creamBorder,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppColors.dividerDark
                              : AppColors.creamBorder,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppColors.mutedSage
                              : AppColors.forestGreen,
                          width: 1.8,
                        ),
                      ),
                    ),
                  ),
                ),

                // Active Home Preferences Chips
                if (_homePreferences.isActive) ...[
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 36,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      children: [
                        ..._homePreferences.travelVibes.map(
                          (v) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: InputChip(
                              avatar: Icon(
                                Icons.auto_awesome_rounded,
                                size: 12,
                                color: isDark
                                    ? AppColors.mutedSage
                                    : AppColors.forestGreen,
                              ),
                              label: Text(
                                v,
                                style: const TextStyle(fontSize: 11),
                              ),
                              onDeleted: () {
                                setState(() {
                                  final updated = List<String>.from(
                                    _homePreferences.travelVibes,
                                  )..remove(v);
                                  _homePreferences = _homePreferences.copyWith(
                                    travelVibes: updated,
                                  );
                                });
                              },
                            ),
                          ),
                        ),
                        ..._homePreferences.preferredScenery.map(
                          (s) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: InputChip(
                              avatar: Icon(
                                Icons.landscape_rounded,
                                size: 12,
                                color: isDark
                                    ? AppColors.mutedSage
                                    : AppColors.forestGreen,
                              ),
                              label: Text(
                                s,
                                style: const TextStyle(fontSize: 11),
                              ),
                              onDeleted: () {
                                setState(() {
                                  final updated = List<String>.from(
                                    _homePreferences.preferredScenery,
                                  )..remove(s);
                                  _homePreferences = _homePreferences.copyWith(
                                    preferredScenery: updated,
                                  );
                                });
                              },
                            ),
                          ),
                        ),
                        if (_homePreferences.budgetPreference != 'Any' ||
                            _homePreferences.customMaxBudget != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: InputChip(
                              avatar: Icon(
                                Icons.wallet_rounded,
                                size: 12,
                                color: isDark
                                    ? AppColors.mutedSage
                                    : AppColors.forestGreen,
                              ),
                              label: Text(
                                _homePreferences.customMaxBudget != null
                                    ? '≤ ₹${_homePreferences.customMaxBudget!.toInt()}'
                                    : _homePreferences.budgetPreference,
                                style: const TextStyle(fontSize: 11),
                              ),
                              onDeleted: () {
                                setState(() {
                                  _homePreferences = _homePreferences.copyWith(
                                    budgetPreference: 'Any',
                                    clearCustomBudget: true,
                                  );
                                });
                              },
                            ),
                          ),
                        if (_homePreferences.tripDuration != 'Any')
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: InputChip(
                              avatar: Icon(
                                Icons.timelapse_rounded,
                                size: 12,
                                color: isDark
                                    ? AppColors.mutedSage
                                    : AppColors.forestGreen,
                              ),
                              label: Text(
                                _homePreferences.tripDuration,
                                style: const TextStyle(fontSize: 11),
                              ),
                              onDeleted: () {
                                setState(() {
                                  _homePreferences = _homePreferences.copyWith(
                                    tripDuration: 'Any',
                                  );
                                });
                              },
                            ),
                          ),
                        ..._homePreferences.preferredSeasons
                            .where((s) => s != 'All seasons')
                            .map(
                              (season) => Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: InputChip(
                                  avatar: Icon(
                                    Icons.wb_sunny_rounded,
                                    size: 12,
                                    color: isDark
                                        ? AppColors.mutedSage
                                        : AppColors.forestGreen,
                                  ),
                                  label: Text(
                                    season,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  onDeleted: () {
                                    setState(() {
                                      final updated = List<String>.from(
                                        _homePreferences.preferredSeasons,
                                      )..remove(season);
                                      _homePreferences = _homePreferences.copyWith(
                                        preferredSeasons: updated,
                                      );
                                    });
                                  },
                                ),
                              ),
                            ),
                        ActionChip(
                          label: const Text(
                            'Clear all',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.terracotta,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _homePreferences = HomePreferences.empty;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],

                // If currently searching, show inline search results
                if (isSearching) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Search Results (${searchResults.length})',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _homeSearchController.clear();
                            setState(() => _homeSearchQuery = '');
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (searchResults.isEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: isDark
                              ? AppColors.dividerDark
                              : AppColors.dividerLight,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: AppColors.textMutedLight,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _homePreferences.isActive
                                ? (_homeCategoryFilter == 'All'
                                    ? 'No destinations match both "$_homeSearchQuery" and your active Home preferences.'
                                    : 'No $_homeCategoryFilter destinations match both "$_homeSearchQuery" and your active Home preferences.')
                                : (_homeCategoryFilter == 'All'
                                    ? 'No destinations found for "$_homeSearchQuery"'
                                    : 'No $_homeCategoryFilter destinations found for "$_homeSearchQuery"'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _homePreferences.isActive
                                ? 'Try clearing your Home preferences or search terms like "Goa", "Mountains", or "Kerala".'
                                : 'Try searching by city, state, or category like "Goa", "Mountains", or "Kerala".',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                            ),
                          ),
                          if (_homePreferences.isActive) ...[
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              label: const Text('Reset Home Preferences'),
                              onPressed: () {
                                setState(() {
                                  _homePreferences = HomePreferences.empty;
                                });
                              },
                            ),
                          ],
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: searchResults.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final dest = searchResults[index];
                        return DestinationCard(
                          destination: dest,
                          onTap: () {
                            destProvider.markAsViewed(dest.id);
                            context.push('/destination/${dest.id}');
                          },
                        );
                      },
                    ),
                ] else ...[
                  // 3. Category Filter Chips (Filters Home feed independently)
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: AppConstants.categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final category = AppConstants.categories[index];
                        final isSelected = _homeCategoryFilter == category;
                        return CategoryChip(
                          label: category,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _homeCategoryFilter = category;
                            });
                          },
                        );
                      },
                    ),
                  ),

                  // 4. Upcoming Trip Banner (if any)
                  if (nextTrip != null) ...[
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildUpcomingTripCard(context, nextTrip, isDark),
                    ),
                  ],

                  // 5. Featured Hero Destination
                  if (featuredDest != null) ...[
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _homeCategoryFilter == 'All'
                                  ? 'Featured Destination'
                                  : 'Featured in $_homeCategoryFilter',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentAmber.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              _homeCategoryFilter == 'All'
                                  ? 'Must Visit'
                                  : 'Top $_homeCategoryFilter',
                              style: const TextStyle(
                                color: AppColors.accentAmber,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildHeroCard(
                        context,
                        featuredDest,
                        isDark,
                        wishlistProvider,
                      ),
                    ),
                  ],

                  // 6. Transparent Personalized "For You" Section
                  if (personalizedFeed.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        _homePreferences.isActive
                                            ? 'Personalized For You'
                                            : (_homeCategoryFilter == 'All'
                                                ? 'Recommended For You'
                                                : 'Recommended in $_homeCategoryFilter'),
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? AppColors.textPrimaryDark
                                              : AppColors.textPrimaryLight,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 16,
                                    color: isDark
                                        ? AppColors.mutedSage
                                        : AppColors.forestGreen,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _homePreferences.isActive
                                    ? 'Refined by ${_homePreferences.activeFiltersCount} active recommendation preference${_homePreferences.activeFiltersCount > 1 ? "s" : ""}'
                                    : (userSignalsExist
                                          ? 'Tailored to your preferences and travel style'
                                          : 'Personalized recommendations based on your activity'),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _openHomePreferencesPanel(context),
                          icon: const Icon(Icons.tune_rounded, size: 14),
                          label: Text(
                            _homePreferences.isActive
                                ? 'Preferences (${_homePreferences.activeFiltersCount})'
                                : 'Preferences',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 380,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: personalizedFeed.length,
                      itemBuilder: (context, index) {
                        final rec = personalizedFeed[index];
                        return Container(
                          width: 250,
                          margin: const EdgeInsets.only(right: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: DestinationCarouselCard(
                                  destination: rec.destination,
                                  onTap: () {
                                    destProvider.markAsViewed(
                                      rec.destination.id,
                                    );
                                    context.push(
                                      '/destination/${rec.destination.id}',
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Transparent match reason explanation badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: rec.isPersonalized
                                      ? AppColors.primaryLight.withOpacity(0.1)
                                      : (isDark
                                            ? AppColors.surfaceDark
                                            : Colors.black.withOpacity(0.04)),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.sm,
                                  ),
                                  border: Border.all(
                                    color: rec.isPersonalized
                                        ? AppColors.primaryLight.withOpacity(
                                            0.25,
                                          )
                                        : (isDark
                                              ? AppColors.dividerDark
                                              : AppColors.dividerLight),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      rec.isPersonalized
                                          ? Icons.auto_awesome_rounded
                                          : Icons.star_rounded,
                                      size: 13,
                                      color: rec.isPersonalized
                                          ? AppColors.primaryLight
                                          : AppColors.accentAmber,
                                    ),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        rec.matchReason,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: rec.isPersonalized
                                              ? AppColors.primaryLight
                                              : (isDark
                                                    ? AppColors
                                                          .textSecondaryDark
                                                    : AppColors
                                                          .textSecondaryLight),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],

                  // 7. Popular Destinations in India
                  if (popularDests.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _buildSectionHeader(
                      context,
                      title: _homeCategoryFilter == 'All'
                          ? 'Popular in India'
                          : 'Popular in $_homeCategoryFilter',
                      subtitle: _homeCategoryFilter == 'All'
                          ? 'Top handpicked destinations travelers love'
                          : 'Top handpicked ${_homeCategoryFilter.toLowerCase()} destinations travelers love',
                      onSeeAll: () {
                        if (_homeCategoryFilter != 'All') {
                          destProvider.resetFilters();
                          destProvider.setSelectedCategory(_homeCategoryFilter);
                        } else {
                          destProvider.resetFilters();
                        }
                        context.go('/explore');
                      },
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 340,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: popularDests.length,
                        itemBuilder: (context, index) {
                          final dest = popularDests[index];
                          return DestinationCarouselCard(
                            destination: dest,
                            onTap: () {
                              destProvider.markAsViewed(dest.id);
                              context.push('/destination/${dest.id}');
                            },
                          );
                        },
                      ),
                    ),
                  ],

                  // 7. Travel Buddy AI Companion Callout Banner
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildTravelBuddyCallout(context, isDark),
                  ),

                  // 8. Smart Travel Matcher Callout Banner
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildMatcherCallout(context, isDark),
                  ),

                  // 8. Trending Destinations
                  if (trendingDests.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _buildSectionHeader(
                      context,
                      title: _homeCategoryFilter == 'All'
                          ? 'Trending Right Now'
                          : 'Trending in $_homeCategoryFilter',
                      subtitle: _homeCategoryFilter == 'All'
                          ? 'Rising hot spots for adventures & scenic stays'
                          : 'Rising hot spots for ${_homeCategoryFilter.toLowerCase()} getaways',
                      onSeeAll: () {
                        if (_homeCategoryFilter != 'All') {
                          destProvider.resetFilters();
                          destProvider.setSelectedCategory(_homeCategoryFilter);
                        } else {
                          destProvider.resetFilters();
                        }
                        context.go('/explore');
                      },
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 275,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: trendingDests.length,
                        itemBuilder: (context, index) {
                          final dest = trendingDests[index];
                          return Container(
                            width: 220,
                            margin: const EdgeInsets.only(right: 14),
                            child: DestinationCard(
                              destination: dest,
                              onTap: () {
                                destProvider.markAsViewed(dest.id);
                                context.push('/destination/${dest.id}');
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  // 9. Weekend Getaways
                  if (weekendDests.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _buildSectionHeader(
                      context,
                      title: _homeCategoryFilter == 'All'
                          ? 'Weekend Getaways'
                          : 'Weekend $_homeCategoryFilter Escapes',
                      subtitle: _homeCategoryFilter == 'All'
                          ? 'Quick and refreshing 2-3 day escapes'
                          : 'Quick and refreshing 2-3 day ${_homeCategoryFilter.toLowerCase()} trips',
                      onSeeAll: () {
                        if (_homeCategoryFilter != 'All') {
                          destProvider.resetFilters();
                          destProvider.setSelectedCategory(_homeCategoryFilter);
                        } else {
                          destProvider.resetFilters();
                        }
                        context.go('/explore');
                      },
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 275,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: weekendDests.length,
                        itemBuilder: (context, index) {
                          final dest = weekendDests[index];
                          return Container(
                            width: 220,
                            margin: const EdgeInsets.only(right: 14),
                            child: DestinationCard(
                              destination: dest,
                              onTap: () {
                                destProvider.markAsViewed(dest.id);
                                context.push('/destination/${dest.id}');
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  // 10. Recently Viewed Destinations
                  if (recentDests.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _buildSectionHeader(
                      context,
                      title: 'Recently Viewed',
                      subtitle: 'Jump back into destinations you checked',
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 275,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: recentDests.length,
                        itemBuilder: (context, index) {
                          final dest = recentDests[index];
                          return Container(
                            width: 220,
                            margin: const EdgeInsets.only(right: 14),
                            child: DestinationCard(
                              destination: dest,
                              onTap: () {
                                context.push('/destination/${dest.id}');
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
    VoidCallback? onSeeAll,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Row(
                children: [
                  Text(
                    'See All',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.arrow_forward_ios_rounded, size: 11),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    Destination dest,
    bool isDark,
    WishlistProvider wishlistProvider,
  ) {
    final isSaved = wishlistProvider.isWishlisted(dest.id);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Stack(
          children: [
            AppNetworkImage(
              imageUrl: dest.imageUrl,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Container(
              height: 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.15),
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.85),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 14,
              right: 14,
              child: Material(
                color: Colors.black.withOpacity(0.4),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    wishlistProvider.toggleWishlist(dest.id);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      isSaved
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 20,
                      color: isSaved ? AppColors.terracotta : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      RatingBadge(rating: dest.rating, compact: true),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: dest.palette.badgeBackground,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(
                            color: dest.palette.cardBorder,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          dest.category.toUpperCase(),
                          style: TextStyle(
                            color: dest.palette.badgeText,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${dest.city}, ${dest.state}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dest.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dest.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'From ${Formatters.formatCurrency(dest.estimatedDailyCost)} / day',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.push('/destination/${dest.id}');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: dest.palette.currentPrimary(isDark),
                          foregroundColor: dest.palette.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Discover'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingTripCard(
    BuildContext context,
    dynamic trip,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E2822), const Color(0xFF131A16)]
              : [AppColors.forestGreen, const Color(0xFF265A4D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF173F35).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.flight_takeoff_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'UPCOMING TRIP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${trip.totalDays} Days',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            trip.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${trip.destinationName} • ${Formatters.formatDateRange(trip.startDate, trip.endDate)}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget: ${Formatters.formatCurrency(trip.plannedBudget)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  context.push('/trip/${trip.id}');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('View Itinerary'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMatcherCallout(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.secondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart Destination Matcher',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Find destinations matched to your budget & style',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.push('/matcher');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Match',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelBuddyCallout(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1D2621), const Color(0xFF151D18)]
              : [const Color(0xFFEFF5ED), const Color(0xFFE2EDE0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.mutedSage.withOpacity(0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text('🌍', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meet Travel Buddy',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ask your AI companion for budget tips, itineraries, or mountain escapes',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.push('/travel-buddy'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Chat',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
