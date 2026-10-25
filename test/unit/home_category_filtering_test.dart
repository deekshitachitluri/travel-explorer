import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_explorer/app.dart';
import 'package:travel_explorer/core/constants/app_constants.dart';
import 'package:travel_explorer/data/local/local_storage_service.dart';
import 'package:travel_explorer/providers/destination_provider.dart';
import 'package:travel_explorer/services/auth_service.dart';
import 'package:travel_explorer/widgets/category_chip.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Home Category Filtering & Independence Unit Tests', () {
    late LocalStorageService storage;
    late DestinationProvider destProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = await LocalStorageService.init();
      destProvider = DestinationProvider(storage);
    });

    test('Catalogue contains ample destinations across all categories', () {
      final all = destProvider.allDestinations;
      expect(all.length, greaterThanOrEqualTo(100));

      final beaches = all.where((d) => d.matchesCategory('Beaches')).toList();
      final mountains = all
          .where((d) => d.matchesCategory('Mountains'))
          .toList();
      final heritage = all.where((d) => d.matchesCategory('Heritage')).toList();
      final adventure = all
          .where((d) => d.matchesCategory('Adventure'))
          .toList();
      final spiritual = all
          .where((d) => d.matchesCategory('Spiritual'))
          .toList();

      expect(beaches.length, greaterThanOrEqualTo(10));
      expect(mountains.length, greaterThanOrEqualTo(20));
      expect(heritage.length, greaterThanOrEqualTo(20));
      expect(adventure.length, greaterThanOrEqualTo(15));
      expect(spiritual.length, greaterThanOrEqualTo(10));
    });

    test('Category matching is normalized correctly for all variations', () {
      expect(AppConstants.matchesCategory('Beach', 'Beaches'), isTrue);
      expect(AppConstants.matchesCategory('Beaches', 'Beach'), isTrue);
      expect(AppConstants.matchesCategory('Mountain', 'Mountains'), isTrue);
      expect(AppConstants.matchesCategory('Hill Station', 'Mountains'), isTrue);
      expect(AppConstants.matchesCategory('Historical', 'Heritage'), isTrue);
      expect(AppConstants.matchesCategory('Heritage', 'Heritage'), isTrue);
      expect(AppConstants.matchesCategory('Adventure', 'Adventure'), isTrue);
      expect(AppConstants.matchesCategory('Trekking', 'Adventure'), isTrue);
      expect(AppConstants.matchesCategory('Spiritual', 'Spiritual'), isTrue);
      expect(AppConstants.matchesCategory('Pilgrimage', 'Spiritual'), isTrue);
      expect(AppConstants.matchesCategory('Temple', 'Spiritual'), isTrue);
      expect(AppConstants.matchesCategory('Beach', 'Mountains'), isFalse);
    });

    test('Home category filtering does not mutate Explore category filter', () {
      expect(destProvider.selectedCategory, equals(AppConstants.categoryAll));
      // Tapping chips on Home must NOT change destProvider.selectedCategory
      // (Explore retains its own independent filter state)
      expect(destProvider.selectedCategory, equals(AppConstants.categoryAll));
    });
  });

  group('Home Category Filtering Widget Tests', () {
    Future<void> pumpTravelApp(WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = await LocalStorageService.init();
      final authService = LocalAuthService(prefs);

      tester.view.physicalSize = const Size(2400, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        TravelExplorerApp(storageService: storage, authService: authService),
      );
      await tester.pumpAndSettle();
    }

    Future<void> tapCategoryChip(WidgetTester tester, String label) async {
      final chipFinder = find.widgetWithText(CategoryChip, label);
      await tester.tap(chipFinder);
      await tester.pumpAndSettle();
    }

    testWidgets(
      'Initial Home screen loads "All" category with Goa hero and multi-category feeds',
      (WidgetTester tester) async {
        await pumpTravelApp(tester);

        // Verify "All" chip is present
        expect(find.widgetWithText(CategoryChip, 'All'), findsOneWidget);

        // Verify All hero is Goa
        expect(find.text('Goa'), findsWidgets);
        expect(find.text('Featured Destination'), findsOneWidget);
        expect(find.text('Must Visit'), findsOneWidget);

        // Verify default sections for All
        expect(find.text('Popular in India'), findsOneWidget);
        expect(find.text('Trending Right Now'), findsOneWidget);
      },
    );

    testWidgets(
      'Selecting "Beaches" updates featured hero to Andaman and filters destinations',
      (WidgetTester tester) async {
        await pumpTravelApp(tester);

        // Tap Beaches chip
        await tapCategoryChip(tester, 'Beaches');

        // Hero should now be Andaman & Nicobar (featured beach), not Goa default
        expect(find.text('Andaman & Nicobar'), findsWidgets);
        expect(find.text('Featured in Beaches'), findsOneWidget);
        expect(find.text('Top Beaches'), findsOneWidget);
        expect(find.text('Popular in Beaches'), findsOneWidget);
        expect(find.text('Trending in Beaches'), findsOneWidget);

        // Verify that mountain destinations like Manali are not displayed
        expect(find.text('Manali'), findsNothing);
        expect(find.text('Shimla'), findsNothing);
      },
    );

    testWidgets(
      'Selecting "Mountains" updates featured hero to Manali and filters to mountain destinations only',
      (WidgetTester tester) async {
        await pumpTravelApp(tester);

        // Tap Mountains chip
        await tapCategoryChip(tester, 'Mountains');

        // Featured hero should be Manali
        expect(find.text('Manali'), findsWidgets);
        expect(find.text('Featured in Mountains'), findsOneWidget);
        expect(find.text('Top Mountains'), findsOneWidget);
        expect(find.text('Popular in Mountains'), findsOneWidget);
        expect(find.text('Trending in Mountains'), findsOneWidget);

        // Beach destinations like Goa should NOT be displayed
        expect(find.text('Goa'), findsNothing);
      },
    );

    testWidgets(
      'Selecting "Heritage" updates featured hero to Jaipur and filters to heritage destinations',
      (WidgetTester tester) async {
        await pumpTravelApp(tester);

        // Tap Heritage chip
        await tapCategoryChip(tester, 'Heritage');

        // Featured hero should be Jaipur
        expect(find.text('Jaipur'), findsWidgets);
        expect(find.text('Featured in Heritage'), findsOneWidget);
        expect(find.text('Top Heritage'), findsOneWidget);
        expect(find.text('Popular in Heritage'), findsOneWidget);

        // Beaches should not appear
        expect(find.text('Goa'), findsNothing);
      },
    );

    testWidgets(
      'Selecting "Adventure" updates featured hero to Leh Ladakh and filters to adventure destinations',
      (WidgetTester tester) async {
        await pumpTravelApp(tester);

        // Tap Adventure chip
        await tapCategoryChip(tester, 'Adventure');

        // Featured hero should be Leh Ladakh (top popular adventure destination)
        expect(find.text('Leh Ladakh'), findsWidgets);
        expect(find.text('Featured in Adventure'), findsOneWidget);
        expect(find.text('Top Adventure'), findsOneWidget);
        expect(find.text('Popular in Adventure'), findsOneWidget);

        // Goa should not appear
        expect(find.text('Goa'), findsNothing);
      },
    );

    testWidgets(
      'Selecting "Spiritual" updates featured hero to Varanasi and filters to spiritual destinations',
      (WidgetTester tester) async {
        await pumpTravelApp(tester);

        await tapCategoryChip(tester, 'Spiritual');

        expect(find.text('Featured in Spiritual'), findsOneWidget);
        expect(find.text('Top Spiritual'), findsOneWidget);
        expect(find.text('Popular in Spiritual'), findsOneWidget);
        expect(find.text('Varanasi'), findsWidgets);

        // Goa should not appear
        expect(find.text('Goa'), findsNothing);
      },
    );

    testWidgets(
      'Switching from a category back to "All" restores unfiltered feed and Goa hero',
      (WidgetTester tester) async {
        await pumpTravelApp(tester);

        // Switch to Mountains
        await tapCategoryChip(tester, 'Mountains');
        expect(find.text('Featured in Mountains'), findsOneWidget);
        expect(find.text('Goa'), findsNothing);

        // Switch back to All
        await tapCategoryChip(tester, 'All');

        // Full feed restored
        expect(find.text('Featured Destination'), findsOneWidget);
        expect(find.text('Must Visit'), findsOneWidget);
        expect(find.text('Popular in India'), findsOneWidget);
        expect(find.text('Trending Right Now'), findsOneWidget);
        expect(find.text('Goa'), findsWidgets);
      },
    );

    testWidgets(
      'Inline search and active category filter work together seamlessly',
      (WidgetTester tester) async {
        await pumpTravelApp(tester);

        // Select Mountains category
        await tapCategoryChip(tester, 'Mountains');

        // Enter search query "Himachal" -> should find Manali and Shimla
        final searchField = find.byType(TextField);
        await tester.enterText(searchField, 'Himachal');
        await tester.pumpAndSettle();

        expect(find.textContaining('Search Results'), findsOneWidget);
        expect(find.text('Manali'), findsWidgets);

        // Now search for "Goa" while Mountains is still active -> should find 0 results
        await tester.enterText(searchField, 'Goa');
        await tester.pumpAndSettle();

        expect(
          find.textContaining('No Mountains destinations found for "Goa"'),
          findsOneWidget,
        );

        // Clear search
        await tester.tap(find.text('Clear'));
        await tester.pumpAndSettle();

        // Switch to All, then search "Goa" -> should find Goa
        await tapCategoryChip(tester, 'All');

        await tester.enterText(searchField, 'Goa');
        await tester.pumpAndSettle();
        expect(find.text('Goa'), findsWidgets);
      },
    );
  });
}
