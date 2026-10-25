import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_explorer/core/constants/app_constants.dart';
import 'package:travel_explorer/data/local/destination_seed_data.dart';
import 'package:travel_explorer/data/local/local_storage_service.dart';
import 'package:travel_explorer/providers/destination_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageService storage;
  late DestinationProvider provider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = await LocalStorageService.init();
    provider = DestinationProvider(storage);
  });

  group('DestinationProvider Filtering & Search Tests', () {
    test('Initial destinations count matches seed data (at least 12)', () {
      expect(provider.allDestinations.length, greaterThanOrEqualTo(12));
      expect(
        provider.allDestinations.length,
        equals(DestinationSeedData.destinations.length),
      );
    });

    test('Filter by Category "Beaches" returns only beach destinations', () {
      provider.setSelectedCategory(AppConstants.categoryBeaches);
      final beaches = provider.filteredDestinations;

      expect(beaches.isNotEmpty, isTrue);
      for (final dest in beaches) {
        expect(dest.matchesCategory(AppConstants.categoryBeaches), isTrue);
      }
    });

    test(
      'Filter by Category "Mountains" returns mountains like Manali & Munnar',
      () {
        provider.setSelectedCategory(AppConstants.categoryMountains);
        final mountains = provider.filteredDestinations;

        expect(mountains.any((d) => d.id == 'manali'), isTrue);
        expect(mountains.any((d) => d.id == 'munnar'), isTrue);
        expect(mountains.any((d) => d.id == 'goa'), isFalse);
      },
    );

    test(
      'Search matching is case-insensitive across name, city, state, and tags',
      () {
        provider.setSearchQuery('gOa');
        expect(provider.filteredDestinations.any((d) => d.id == 'goa'), isTrue);

        provider.setSearchQuery('hIMACHAL');
        expect(
          provider.filteredDestinations.any((d) => d.id == 'manali'),
          isTrue,
        );
        expect(
          provider.filteredDestinations.any((d) => d.id == 'shimla'),
          isTrue,
        );

        provider.setSearchQuery('scuba');
        expect(
          provider.filteredDestinations.any((d) => d.id == 'andaman'),
          isTrue,
        );
      },
    );

    test('Combining Category filter and Budget filter works accurately', () {
      provider.setSelectedCategory(AppConstants.categoryHeritage);
      provider.setBudgetFilter(2500.0);

      final results = provider.filteredDestinations;
      for (final d in results) {
        expect(d.matchesCategory(AppConstants.categoryHeritage), isTrue);
        expect(d.estimatedDailyCost, lessThanOrEqualTo(2500.0));
      }
    });

    test('Sorting by Budget: Low to High works correctly', () {
      provider.setSelectedSort(AppConstants.sortBudgetLowHigh);
      final list = provider.filteredDestinations;

      for (int i = 0; i < list.length - 1; i++) {
        expect(
          list[i].estimatedDailyCost,
          lessThanOrEqualTo(list[i + 1].estimatedDailyCost),
        );
      }
    });

    test('Resetting filters restores full list', () {
      provider.setSelectedCategory(AppConstants.categoryAdventure);
      provider.setSearchQuery('Rishikesh');
      expect(provider.filteredDestinations.length, equals(1));

      provider.resetFilters();
      expect(
        provider.filteredDestinations.length,
        equals(provider.allDestinations.length),
      );
      expect(provider.searchQuery, isEmpty);
      expect(provider.selectedCategory, equals(AppConstants.categoryAll));
    });
  });
}
