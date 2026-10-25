import '../models/destination.dart';
import '../models/home_preferences.dart';

class MatchCriteria {
  final String? preferredCategory; // Beaches, Mountains, Heritage, Adventure
  final double? maxDailyBudget; // INR
  final int? preferredDurationDays;
  final List<String> interests; // Nature, Trekking, Palaces, etc.
  final String? preferredSeason;

  const MatchCriteria({
    this.preferredCategory,
    this.maxDailyBudget,
    this.preferredDurationDays,
    this.interests = const [],
    this.preferredSeason,
  });
}

class DestinationMatchResult {
  final Destination destination;
  final int score; // 0 to 100
  final List<String> matchReasons;

  const DestinationMatchResult({
    required this.destination,
    required this.score,
    required this.matchReasons,
  });
}

/// A personalized recommendation score and explanation for the Home Feed.
class PersonalizedRecommendation {
  final Destination destination;
  final String matchReason;
  final int score;
  final bool isPersonalized;

  const PersonalizedRecommendation({
    required this.destination,
    required this.matchReason,
    required this.score,
    required this.isPersonalized,
  });
}

class RecommendationService {
  static List<DestinationMatchResult> matchDestinations({
    required List<Destination> allDestinations,
    required MatchCriteria criteria,
  }) {
    final List<DestinationMatchResult> results = [];

    for (final dest in allDestinations) {
      int score = 0;
      final List<String> reasons = [];

      // 1. Category Matching (Weight: 30 pts)
      if (criteria.preferredCategory != null &&
          criteria.preferredCategory != 'All' &&
          criteria.preferredCategory!.isNotEmpty) {
        if (dest.category.toLowerCase() ==
            criteria.preferredCategory!.toLowerCase()) {
          score += 30;
          reasons.add('Perfect match for your ${dest.category} preference');
        }
      } else {
        score += 15; // baseline neutral
      }

      // 2. Budget Matching (Weight: 25 pts)
      if (criteria.maxDailyBudget != null && criteria.maxDailyBudget! > 0) {
        if (dest.estimatedDailyCost <= criteria.maxDailyBudget!) {
          score += 25;
          final diff = criteria.maxDailyBudget! - dest.estimatedDailyCost;
          if (diff >= 1000) {
            reasons.add(
              'Very affordable: ₹${dest.estimatedDailyCost.toInt()}/day fits well inside budget',
            );
          } else {
            reasons.add(
              'Comfortably matches your ₹${criteria.maxDailyBudget!.toInt()}/day budget',
            );
          }
        } else if (dest.estimatedDailyCost <= criteria.maxDailyBudget! * 1.2) {
          // slight stretch
          score += 10;
        }
      } else {
        score += 15;
      }

      // 3. Duration Matching (Weight: 20 pts)
      if (criteria.preferredDurationDays != null &&
          criteria.preferredDurationDays! > 0) {
        final diff =
            (dest.suggestedDurationDays - criteria.preferredDurationDays!)
                .abs();
        if (diff == 0) {
          score += 20;
          reasons.add(
            'Ideal for a ${dest.suggestedDurationDays}-day itinerary',
          );
        } else if (diff <= 1) {
          score += 15;
          reasons.add(
            'Great fit for your ${criteria.preferredDurationDays}-day travel window',
          );
        } else if (diff <= 2) {
          score += 8;
        }
      } else {
        score += 10;
      }

      // 4. Season Matching (Weight: 15 pts)
      if (criteria.preferredSeason != null &&
          criteria.preferredSeason!.isNotEmpty) {
        final seasonMatch = dest.seasons.any(
          (s) => s.toLowerCase().contains(
            criteria.preferredSeason!.toLowerCase().split(' ').first,
          ),
        );
        if (seasonMatch || dest.seasons.contains('Year-round')) {
          score += 15;
          reasons.add(
            'Peak season matches your travel period (${dest.bestTimeToVisit})',
          );
        }
      } else {
        score += 10;
      }

      // 5. Interests & Tags Matching (Weight: 10 pts)
      if (criteria.interests.isNotEmpty) {
        int matchingTags = 0;
        for (final interest in criteria.interests) {
          final interestLower = interest.toLowerCase();
          final hasTag =
              dest.tags.any(
                (t) =>
                    t.toLowerCase().contains(interestLower) ||
                    interestLower.contains(t.toLowerCase()),
              ) ||
              dest.description.toLowerCase().contains(interestLower);
          if (hasTag) {
            matchingTags++;
          }
        }

        if (matchingTags > 0) {
          final pts = (matchingTags * 5).clamp(0, 10);
          score += pts;
          reasons.add(
            'Aligns with your interests in ${criteria.interests.take(2).join(', ')}',
          );
        }
      }

      // Normalize score between 0 and 100
      final normalizedScore = score.clamp(0, 100);

      if (reasons.isEmpty) {
        reasons.add('Popular destination rated ${dest.rating}★ by travelers');
      }

      results.add(
        DestinationMatchResult(
          destination: dest,
          score: normalizedScore,
          matchReasons: reasons,
        ),
      );
    }

    // Sort descending by score, then by destination rating
    results.sort((a, b) {
      final scoreComp = b.score.compareTo(a.score);
      if (scoreComp != 0) return scoreComp;
      return b.destination.rating.compareTo(a.destination.rating);
    });

    return results;
  }

  /// Generates a transparent, explainable personalized feed for the Home screen.
  ///
  /// Signals used:
  /// 1. User's explicit preferred categories (+40 pts)
  /// 2. Categories represented in user's active Wishlist (+30 pts)
  /// 3. User's chosen travel style alignment (+20 pts)
  /// 4. Rating quality benchmark (+10 pts)
  ///
  /// If no preference signals exist, provides a curated popular feed without
  /// making false personalization claims (`isPersonalized: false`).
  static List<PersonalizedRecommendation> getPersonalizedFeed({
    required List<Destination> allDestinations,
    required List<String> preferredCategories,
    required Set<String> wishlistDestinationIds,
    required List<String> recentlyViewedIds,
    String? travelStyle,
  }) {
    if (allDestinations.isEmpty) return const [];

    // Derive wishlist categories for similarity recommendations
    final wishlistCategories = allDestinations
        .where((d) => wishlistDestinationIds.contains(d.id))
        .map((d) => d.category.toLowerCase())
        .toSet();

    final hasSignals =
        preferredCategories.isNotEmpty ||
        wishlistDestinationIds.isNotEmpty ||
        recentlyViewedIds.isNotEmpty;

    final List<PersonalizedRecommendation> recommendations = [];

    for (final dest in allDestinations) {
      int score = 0;
      final List<String> reasons = [];
      final destCatLower = dest.category.toLowerCase();

      // 1. Explicit Category Preference (40 pts)
      final matchesPreferred = preferredCategories.any(
        (cat) => cat.toLowerCase() == destCatLower,
      );
      if (matchesPreferred) {
        score += 40;
        reasons.add('Matches your preferred ${dest.category} category');
      }

      // 2. Wishlist Affinity (30 pts) - recommend non-wishlisted places of same category
      if (!wishlistDestinationIds.contains(dest.id) &&
          wishlistCategories.contains(destCatLower)) {
        score += 30;
        reasons.add('Similar to destinations saved in your Wishlist');
      }

      // 3. Travel Style Alignment (20 pts)
      if (travelStyle != null && travelStyle.isNotEmpty) {
        final style = travelStyle.toLowerCase();
        if (style.contains('adventure') && destCatLower == 'adventure') {
          score += 20;
          reasons.add('Tailored for your Adventure travel style');
        } else if ((style.contains('relax') || style.contains('leisure')) &&
            (destCatLower == 'beaches' || destCatLower == 'mountains')) {
          score += 20;
          reasons.add('Curated for your relaxed Leisure travel style');
        } else if (style.contains('culture') && destCatLower == 'heritage') {
          score += 20;
          reasons.add('Historical pick for your Cultural travel style');
        } else if (dest.isPopular || dest.rating >= 4.7) {
          score += 15;
          reasons.add('Top-rated highlight for Explorer travel style');
        }
      }

      // 4. Quality Benchmark (10 pts)
      if (dest.rating >= 4.8) {
        score += 10;
      } else if (dest.rating >= 4.6) {
        score += 5;
      }

      // If user has no signals, generate curated popular reasons
      final isPersonalizedItem = hasSignals && score > 15;
      final mainReason = reasons.isNotEmpty
          ? reasons.first
          : 'Top-rated ${dest.category} destination (${dest.rating}★)';

      recommendations.add(
        PersonalizedRecommendation(
          destination: dest,
          matchReason: mainReason,
          score: isPersonalizedItem ? score : (dest.rating * 10).round(),
          isPersonalized: isPersonalizedItem,
        ),
      );
    }

    // Sort descending by score, prioritizing un-wishlisted places to spur discovery
    recommendations.sort((a, b) {
      final aInWish = wishlistDestinationIds.contains(a.destination.id) ? 1 : 0;
      final bInWish = wishlistDestinationIds.contains(b.destination.id) ? 1 : 0;
      if (aInWish != bInWish) return aInWish.compareTo(bInWish);

      final scoreCmp = b.score.compareTo(a.score);
      if (scoreCmp != 0) return scoreCmp;
      return b.destination.rating.compareTo(a.destination.rating);
    });

    return recommendations;
  }

  /// Evaluates whether a destination satisfies the active Home Preferences constraints.
  static bool matchesHomePreferences({
    required Destination destination,
    required HomePreferences preferences,
  }) {
    if (!preferences.isActive) return true;

    final tagsLower = destination.tags.map((t) => t.toLowerCase()).toList();
    final catLower = destination.category.toLowerCase();

    // 1. Preferred Scenery (OR match across selected scenery options)
    if (preferences.preferredScenery.isNotEmpty) {
      final matchesAnyScenery = preferences.preferredScenery.any((scenery) {
        final s = scenery.toLowerCase();
        if (s.contains('beach')) {
          return catLower == 'beaches';
        } else if (s.contains('mountain')) {
          return catLower == 'mountains';
        } else if (s.contains('forest')) {
          return tagsLower.any(
            (t) =>
                t.contains('forest') ||
                t.contains('wildlife') ||
                t.contains('safari') ||
                t.contains('plantations') ||
                t.contains('nature') ||
                t.contains('coffee'),
          );
        } else if (s.contains('lake')) {
          return tagsLower.any(
                (t) =>
                    t.contains('lake') ||
                    t.contains('boating') ||
                    t.contains('backwaters'),
              ) ||
              destination.id == 'udaipur';
        } else if (s.contains('historic') || s.contains('culture')) {
          return catLower == 'heritage' ||
              tagsLower.any(
                (t) =>
                    t.contains('palace') ||
                    t.contains('temple') ||
                    t.contains('fort') ||
                    t.contains('history') ||
                    t.contains('ruins') ||
                    t.contains('monument'),
              );
        }
        return false;
      });
      if (!matchesAnyScenery) return false;
    }

    // 2. Travel Vibe (OR match across selected vibes)
    if (preferences.travelVibes.isNotEmpty) {
      final matchesAnyVibe = preferences.travelVibes.any((vibe) {
        final v = vibe.toLowerCase();
        if (v.contains('peace') || v.contains('relax')) {
          return tagsLower.any(
                (t) =>
                    t.contains('peace') ||
                    t.contains('relax') ||
                    t.contains('calm') ||
                    t.contains('serene') ||
                    t.contains('yoga') ||
                    t.contains('ayurveda') ||
                    t.contains('quiet'),
              ) ||
              catLower == 'beaches' ||
              catLower == 'mountains';
        } else if (v.contains('adventure')) {
          return catLower == 'adventure' ||
              tagsLower.any(
                (t) =>
                    t.contains('adventure') ||
                    t.contains('trekking') ||
                    t.contains('rafting') ||
                    t.contains('sports') ||
                    t.contains('scuba') ||
                    t.contains('camping'),
              );
        } else if (v.contains('nature') || v.contains('wildlife')) {
          return tagsLower.any(
            (t) =>
                t.contains('nature') ||
                t.contains('wildlife') ||
                t.contains('safari') ||
                t.contains('waterfalls') ||
                t.contains('tea') ||
                t.contains('coffee') ||
                t.contains('hills'),
          );
        } else if (v.contains('culture') || v.contains('heritage')) {
          return catLower == 'heritage' ||
              tagsLower.any(
                (t) =>
                    t.contains('culture') ||
                    t.contains('temple') ||
                    t.contains('fort') ||
                    t.contains('ghats') ||
                    t.contains('history') ||
                    t.contains('palace'),
              );
        } else if (v.contains('food') || v.contains('local')) {
          return tagsLower.any(
            (t) =>
                t.contains('food') ||
                t.contains('cuisine') ||
                t.contains('street food') ||
                t.contains('seafood') ||
                t.contains('cafes') ||
                t.contains('market') ||
                t.contains('coffee'),
          );
        } else if (v.contains('romantic')) {
          return tagsLower.any(
                (t) =>
                    t.contains('romantic') ||
                    t.contains('honeymoon') ||
                    t.contains('sunset') ||
                    t.contains('luxury') ||
                    t.contains('cruises'),
              ) ||
              destination.id == 'goa' ||
              destination.id == 'udaipur' ||
              destination.id == 'munnar' ||
              destination.id == 'andaman' ||
              destination.id == 'ooty';
        } else if (v.contains('photo') || v.contains('scenic')) {
          return tagsLower.any(
            (t) =>
                t.contains('scenic') ||
                t.contains('view') ||
                t.contains('photo') ||
                t.contains('landscape') ||
                t.contains('sunrise') ||
                t.contains('snow'),
          );
        }
        return false;
      });
      if (!matchesAnyVibe) return false;
    }

    // 3. Budget Preference
    if (preferences.customMaxBudget != null) {
      if (destination.estimatedDailyCost > preferences.customMaxBudget!) {
        return false;
      }
    } else if (preferences.budgetPreference == 'Budget-friendly') {
      if (destination.estimatedDailyCost > 2800) return false;
    } else if (preferences.budgetPreference == 'Moderate') {
      if (destination.estimatedDailyCost > 4500) return false;
    }

    // 4. Trip Duration
    if (preferences.tripDuration == 'Day trip') {
      if (destination.suggestedDurationDays > 1) return false;
    } else if (preferences.tripDuration.contains('Weekend') ||
        preferences.tripDuration.contains('2–3') ||
        preferences.tripDuration.contains('2-3')) {
      if (destination.suggestedDurationDays > 3) return false;
    } else if (preferences.tripDuration.contains('4–7') ||
        preferences.tripDuration.contains('4-7')) {
      if (destination.suggestedDurationDays < 4 ||
          destination.suggestedDurationDays > 7) {
        return false;
      }
    } else if (preferences.tripDuration.contains('Longer') ||
        preferences.tripDuration.contains('8+')) {
      if (destination.suggestedDurationDays < 8) return false;
    }

    // 5. Preferred Seasons (OR match across selected seasons)
    if (preferences.preferredSeasons.isNotEmpty &&
        !preferences.preferredSeasons.contains('All seasons')) {
      final matchesAnySeason = preferences.preferredSeasons.any(
        (season) => matchesSeason(destination, season),
      );
      if (!matchesAnySeason) return false;
    }

    return true;
  }

  /// Checks if a destination is suitable for a specific travel season.
  static bool matchesSeason(Destination destination, String season) {
    final sLower = season.trim().toLowerCase();
    if (sLower.isEmpty || sLower == 'all' || sLower == 'all seasons') return true;

    final destSeasons = destination.seasons.map((s) => s.toLowerCase()).toList();
    final bestTime = destination.bestTimeToVisit.toLowerCase();

    // Year-round destinations match every season
    if (destSeasons.any((s) => s.contains('year-round') || s.contains('throughout'))) {
      return true;
    }

    switch (sLower) {
      case 'spring':
        // Spring in India: February to April / May
        return destSeasons.any((s) => s.contains('spring')) ||
            bestTime.contains('spring') ||
            bestTime.contains('feb') ||
            bestTime.contains('mar') ||
            bestTime.contains('apr') ||
            bestTime.contains('may');

      case 'summer':
        // Summer in India: April to June
        return destSeasons.any((s) => s.contains('summer')) ||
            bestTime.contains('summer') ||
            bestTime.contains('apr') ||
            bestTime.contains('may') ||
            bestTime.contains('jun');

      case 'monsoon':
        // Monsoon in India: June/July to September
        return destSeasons.any((s) => s.contains('monsoon') || s.contains('rain')) ||
            bestTime.contains('monsoon') ||
            bestTime.contains('jul') ||
            bestTime.contains('aug') ||
            bestTime.contains('sep');

      case 'autumn':
        // Autumn / Fall in India: September to November
        return destSeasons.any((s) => s.contains('autumn') || s.contains('fall')) ||
            bestTime.contains('autumn') ||
            bestTime.contains('sep') ||
            bestTime.contains('oct') ||
            bestTime.contains('nov');

      case 'winter':
        // Winter in India: October to March
        return destSeasons.any((s) => s.contains('winter')) ||
            bestTime.contains('winter') ||
            bestTime.contains('oct') ||
            bestTime.contains('nov') ||
            bestTime.contains('dec') ||
            bestTime.contains('jan') ||
            bestTime.contains('feb') ||
            bestTime.contains('mar');

      default:
        // Fallback for custom strings: check substring
        return destSeasons.any((s) => s.contains(sLower)) || bestTime.contains(sLower);
    }
  }

  /// Builds a personalized feed tailored using the dedicated [HomePreferences] panel.
  static List<PersonalizedRecommendation>
  getPersonalizedFeedWithHomePreferences({
    required List<Destination> allDestinations,
    required HomePreferences homePreferences,
    required List<String> userPreferredCategories,
    required Set<String> wishlistDestinationIds,
    required List<String> recentlyViewedIds,
    String? travelStyle,
  }) {
    if (allDestinations.isEmpty) return const [];

    // Filter by home preferences first
    final matchingDestinations = allDestinations
        .where(
          (d) => matchesHomePreferences(
            destination: d,
            preferences: homePreferences,
          ),
        )
        .toList();

    // If active preferences yielded no matches, return empty so UI can suggest adjusting
    if (homePreferences.isActive && matchingDestinations.isEmpty) {
      return const [];
    }

    final sourceList = homePreferences.isActive
        ? matchingDestinations
        : allDestinations;

    final wishlistCategories = allDestinations
        .where((d) => wishlistDestinationIds.contains(d.id))
        .map((d) => d.category.toLowerCase())
        .toSet();

    final List<PersonalizedRecommendation> recommendations = [];

    for (final dest in sourceList) {
      int score = 0;
      final List<String> reasons = [];
      final destCatLower = dest.category.toLowerCase();
      final tagsLower = dest.tags.map((t) => t.toLowerCase()).toList();

      // Scenery Match (+30 pts)
      for (final scenery in homePreferences.preferredScenery) {
        final s = scenery.toLowerCase();
        if (s.contains('beach') && destCatLower == 'beaches') {
          score += 30;
          reasons.add('Matches your preferred $scenery scenery');
          break;
        } else if (s.contains('mountain') && destCatLower == 'mountains') {
          score += 30;
          reasons.add('Matches your preferred $scenery scenery');
          break;
        } else if (s.contains('historic') && destCatLower == 'heritage') {
          score += 30;
          reasons.add('Matches your $scenery interest');
          break;
        }
      }

      // Vibe Match (+25 pts)
      for (final vibe in homePreferences.travelVibes) {
        final v = vibe.toLowerCase();
        if ((v.contains('peace') || v.contains('relax')) &&
            (destCatLower == 'beaches' || destCatLower == 'mountains')) {
          score += 25;
          reasons.add('Perfect for a $vibe escape');
          break;
        } else if (v.contains('adventure') && destCatLower == 'adventure') {
          score += 25;
          reasons.add('Thrilling match for your $vibe style');
          break;
        } else if (v.contains('culture') && destCatLower == 'heritage') {
          score += 25;
          reasons.add('Rich in $vibe');
          break;
        } else if (v.contains('nature') &&
            tagsLower.any(
              (t) =>
                  t.contains('nature') ||
                  t.contains('wildlife') ||
                  t.contains('hills'),
            )) {
          score += 25;
          reasons.add('Surrounded by $vibe');
          break;
        }
      }

      // Season Match (+20 pts)
      for (final season in homePreferences.preferredSeasons) {
        if (season == 'All seasons') break;
        if (matchesSeason(dest, season)) {
          score += 20;
          reasons.add('Prime time to travel: matches $season preference');
          break;
        }
      }

      // Budget Fit (+15 pts)
      if (homePreferences.budgetPreference == 'Budget-friendly' &&
          dest.estimatedDailyCost <= 2500) {
        score += 15;
        reasons.add(
          'Budget-friendly (₹${dest.estimatedDailyCost.toInt()}/day)',
        );
      }

      // Recommendation Priority (+25 pts)
      if (homePreferences.recommendationPriority == 'Similar to wishlist' &&
          !wishlistDestinationIds.contains(dest.id) &&
          wishlistCategories.contains(destCatLower)) {
        score += 25;
        reasons.add('Similar to your saved Wishlist spots');
      } else if (homePreferences.recommendationPriority ==
              'Popular destinations' &&
          dest.isPopular) {
        score += 25;
        reasons.add('Top traveler favorite (${dest.rating}★)');
      } else if (homePreferences.recommendationPriority == 'New places' &&
          !recentlyViewedIds.contains(dest.id) &&
          !wishlistDestinationIds.contains(dest.id)) {
        score += 25;
        reasons.add('Fresh unexplored destination for you');
      }

      // User Profile Category fallback (+20 pts)
      if (userPreferredCategories.any(
        (cat) => cat.toLowerCase() == destCatLower,
      )) {
        score += 20;
        if (reasons.isEmpty) {
          reasons.add('Matches your saved category preference');
        }
      }

      // Quality benchmark (+10 pts)
      if (dest.rating >= 4.8) {
        score += 10;
      } else if (dest.rating >= 4.6) {
        score += 5;
      }

      final isPersonalized =
          homePreferences.isActive || score > 15 || reasons.isNotEmpty;
      final mainReason = reasons.isNotEmpty
          ? reasons.first
          : 'Top-rated ${dest.category} destination (${dest.rating}★)';

      recommendations.add(
        PersonalizedRecommendation(
          destination: dest,
          matchReason: mainReason,
          score: isPersonalized ? score : (dest.rating * 10).round(),
          isPersonalized: isPersonalized,
        ),
      );
    }

    // Sort descending by score, prioritizing un-wishlisted items when discovering
    recommendations.sort((a, b) {
      if (homePreferences.recommendationPriority == 'New places') {
        final aViewed = recentlyViewedIds.contains(a.destination.id) ? 1 : 0;
        final bViewed = recentlyViewedIds.contains(b.destination.id) ? 1 : 0;
        if (aViewed != bViewed) return aViewed.compareTo(bViewed);
      }
      final scoreCmp = b.score.compareTo(a.score);
      if (scoreCmp != 0) return scoreCmp;
      return b.destination.rating.compareTo(a.destination.rating);
    });

    return recommendations;
  }
}
