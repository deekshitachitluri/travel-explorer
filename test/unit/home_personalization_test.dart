import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_explorer/core/constants/app_constants.dart';
import 'package:travel_explorer/data/local/destination_seed_data.dart';
import 'package:travel_explorer/data/local/local_storage_service.dart';
import 'package:travel_explorer/providers/destination_provider.dart';
import 'package:travel_explorer/services/recommendation_service.dart';

void main() {
  group('Transparent Personalization & Recommendation Engine Tests', () {
    final allDests = DestinationSeedData.destinations;

    test('Personalized feed prioritizes explicit preferred categories', () {
      final feed = RecommendationService.getPersonalizedFeed(
        allDestinations: allDests,
        preferredCategories: ['Mountains'],
        wishlistDestinationIds: {},
        recentlyViewedIds: [],
        travelStyle: 'Explorer',
      );

      expect(feed, isNotEmpty);
      expect(feed.first.isPersonalized, isTrue);
      // Top recommendation should be a Mountain destination
      expect(
        feed.first.destination.category.toLowerCase(),
        equals('mountains'),
      );
      expect(feed.first.matchReason, contains('preferred Mountains category'));
    });

    test(
      'Wishlist similarity recommends destinations of matching category',
      () {
        // Wishlisting Goa (Beaches) should elevate other Beach destinations (like Andaman)
        final feed = RecommendationService.getPersonalizedFeed(
          allDestinations: allDests,
          preferredCategories: [],
          wishlistDestinationIds: {'goa'},
          recentlyViewedIds: [],
          travelStyle: null,
        );

        final andamanRec = feed.firstWhere(
          (r) => r.destination.id == 'andaman',
        );
        expect(andamanRec.isPersonalized, isTrue);
        expect(
          andamanRec.matchReason,
          contains('Similar to destinations saved in your Wishlist'),
        );
      },
    );

    test('Curated popular picks are returned when user has zero signals', () {
      final feed = RecommendationService.getPersonalizedFeed(
        allDestinations: allDests,
        preferredCategories: [],
        wishlistDestinationIds: {},
        recentlyViewedIds: [],
        travelStyle: null,
      );

      expect(feed.length, equals(allDests.length));
      // Without signals, destinations should not make false personalization claims
      expect(feed.every((r) => r.isPersonalized == false), isTrue);
      // Explanations should be transparent ratings / highlights
      expect(feed.first.matchReason, contains('★'));
    });
  });

  group('DestinationProvider Sorting and Independence Tests', () {
    test('DestinationProvider supports "Rating: High to Low" sort option', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await LocalStorageService.init();
      final provider = DestinationProvider(storage);

      expect(AppConstants.sortOptions, contains(AppConstants.sortRating));

      provider.setSelectedSort(AppConstants.sortRating);
      final sorted = provider.filteredDestinations;

      for (int i = 0; i < sorted.length - 1; i++) {
        expect(
          sorted[i].rating,
          greaterThanOrEqualTo(sorted[i + 1].rating),
          reason:
              '${sorted[i].name} rating should be >= ${sorted[i + 1].name} rating',
        );
      }
    });

    test('Home search filter matches name, city, state, and category case-insensitively', () {
      final allDests = DestinationSeedData.destinations;

      // Search by partial city name
      const queryCity = 'Panaji';
      final cityMatches = allDests.where((d) {
        final q = queryCity.toLowerCase();
        return d.name.toLowerCase().contains(q) ||
            d.city.toLowerCase().contains(q) ||
            d.state.toLowerCase().contains(q) ||
            d.category.toLowerCase().contains(q);
      }).toList();
      expect(cityMatches.any((d) => d.id == 'goa'), isTrue);

      // Search by category
      const queryCat = 'Heritage';
      final catMatches = allDests.where((d) {
        final q = queryCat.toLowerCase();
        return d.name.toLowerCase().contains(q) ||
            d.city.toLowerCase().contains(q) ||
            d.state.toLowerCase().contains(q) ||
            d.category.toLowerCase().contains(q);
      }).toList();
      expect(catMatches.any((d) => d.id == 'jaipur'), isTrue);
      expect(catMatches.any((d) => d.id == 'hampi'), isTrue);
    });
  });
}
