import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_explorer/data/local/destination_seed_data.dart';
import 'package:travel_explorer/data/local/local_storage_service.dart';
import 'package:travel_explorer/models/home_preferences.dart';
import 'package:travel_explorer/providers/destination_provider.dart';
import 'package:travel_explorer/services/recommendation_service.dart';

void main() {
  group('HomePreferences Model Tests', () {
    test(
      'Default HomePreferences has isActive = false and 0 active filters',
      () {
        const prefs = HomePreferences.empty;
        expect(prefs.isActive, isFalse);
        expect(prefs.activeFiltersCount, equals(0));
      },
    );

    test(
      'Adding vibes, scenery, budget, and seasons accurately updates active count',
      () {
        final prefs = const HomePreferences().copyWith(
          travelVibes: ['Peaceful & Relaxing', 'Adventure'],
          preferredScenery: ['Mountains'],
          budgetPreference: 'Budget-friendly',
          preferredSeasons: ['Winter', 'Spring'],
        );

        expect(prefs.isActive, isTrue);
        // 2 vibes + 1 scenery + 1 budget + 2 seasons = 6 active filters
        expect(prefs.activeFiltersCount, equals(6));
      },
    );

    test('Selecting "All seasons" does not count as a restrictive active filter', () {
      final prefs = const HomePreferences(preferredSeasons: ['All seasons']);
      expect(prefs.isActive, isFalse);
      expect(prefs.activeFiltersCount, equals(0));
    });

    test('JSON serialization round-trip preserves all Home preferences including seasons', () {
      final prefs = const HomePreferences(
        travelVibes: ['Nature & Wildlife'],
        preferredScenery: ['Forests', 'Lakes'],
        budgetPreference: 'Moderate',
        customMaxBudget: 3500.0,
        tripDuration: 'Weekend (2–3 days)',
        recommendationPriority: 'Similar to wishlist',
        preferredSeasons: ['Winter', 'Autumn'],
      );

      final json = prefs.toJson();
      final roundTrip = HomePreferences.fromJson(json);

      expect(roundTrip.travelVibes, equals(['Nature & Wildlife']));
      expect(roundTrip.preferredScenery, equals(['Forests', 'Lakes']));
      expect(roundTrip.budgetPreference, equals('Moderate'));
      expect(roundTrip.customMaxBudget, equals(3500.0));
      expect(roundTrip.tripDuration, equals('Weekend (2–3 days)'));
      expect(roundTrip.recommendationPriority, equals('Similar to wishlist'));
      expect(roundTrip.preferredSeasons, equals(['Winter', 'Autumn']));
    });
  });

  group('RecommendationService Home Preferences Matching Tests', () {
    final allDests = DestinationSeedData.destinations;

    test('Scenery filter "Beaches" matches only beach destinations', () {
      final prefs = const HomePreferences(preferredScenery: ['Beaches']);

      for (final dest in allDests) {
        final matches = RecommendationService.matchesHomePreferences(
          destination: dest,
          preferences: prefs,
        );
        if (dest.category == 'Beaches') {
          expect(matches, isTrue, reason: '${dest.name} should match Beaches');
        } else {
          expect(
            matches,
            isFalse,
            reason: '${dest.name} should not match Beaches',
          );
        }
      }
    });

    test('Budget constraint filters out destinations above max limit', () {
      final prefs = const HomePreferences(customMaxBudget: 3000);

      for (final dest in allDests) {
        final matches = RecommendationService.matchesHomePreferences(
          destination: dest,
          preferences: prefs,
        );
        if (dest.estimatedDailyCost <= 3000) {
          expect(matches, isTrue);
        } else {
          expect(matches, isFalse);
        }
      }
    });

    test(
      'Combined vibe, scenery, and budget preferences filter accurately',
      () {
        final prefs = const HomePreferences(
          travelVibes: ['Adventure'],
          preferredScenery: ['Mountains'],
          budgetPreference: 'Moderate', // <= 4500
        );

        final matches = allDests
            .where(
              (d) => RecommendationService.matchesHomePreferences(
                destination: d,
                preferences: prefs,
              ),
            )
            .toList();

        expect(matches, isNotEmpty);
        for (final m in matches) {
          expect(m.category, equals('Mountains'));
          expect(m.estimatedDailyCost, lessThanOrEqualTo(4500));
        }
      },
    );

    test('Season filter "Winter" matches winter-suitable destinations like Goa and Manali', () {
      final prefs = const HomePreferences(preferredSeasons: ['Winter']);

      final matches = allDests
          .where(
            (d) => RecommendationService.matchesHomePreferences(
              destination: d,
              preferences: prefs,
            ),
          )
          .toList();

      expect(matches, isNotEmpty);
      expect(matches.any((d) => d.id == 'goa'), isTrue);
      expect(matches.any((d) => d.id == 'manali'), isTrue);
    });

    test('Season filter "Monsoon" matches monsoon getaways like Valley of Flowers and Munnar', () {
      final prefs = const HomePreferences(preferredSeasons: ['Monsoon']);

      final matches = allDests
          .where(
            (d) => RecommendationService.matchesHomePreferences(
              destination: d,
              preferences: prefs,
            ),
          )
          .toList();

      expect(matches, isNotEmpty);
      expect(matches.any((d) => d.id == 'munnar'), isTrue);
      expect(matches.any((d) => d.id == 'valley_of_flowers'), isTrue);
    });
  });

  group('Home & Explore Filters Independence Tests', () {
    test('Applying Home preferences does NOT modify DestinationProvider catalogue state', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await LocalStorageService.init();
      final provider = DestinationProvider(storage);

      // Explore provider starts with 'All' category and empty search query
      expect(provider.selectedCategory, equals('All'));
      expect(provider.searchQuery, isEmpty);
      expect(provider.maxBudgetFilter, isNull);

      // Apply Home preferences locally
      final homePrefs = const HomePreferences(
        preferredScenery: ['Mountains'],
        budgetPreference: 'Budget-friendly',
      );
      expect(homePrefs.isActive, isTrue);

      // Provider catalogue state remains completely unaffected
      expect(provider.selectedCategory, equals('All'));
      expect(provider.searchQuery, isEmpty);
      expect(
        provider.filteredDestinations.length,
        equals(provider.allDestinations.length),
      );

      // Applying Explore filters does not change Home preferences
      provider.setSelectedCategory('Beaches');
      provider.setSearchQuery('Goa');

      expect(provider.selectedCategory, equals('Beaches'));
      expect(provider.searchQuery, equals('Goa'));
      expect(homePrefs.preferredScenery, equals(['Mountains']));
    });
  });
}
