import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_explorer/core/constants/app_constants.dart';
import 'package:travel_explorer/core/constants/map_constants.dart';
import 'package:travel_explorer/data/local/destination_seed_data.dart';
import 'package:travel_explorer/data/local/local_storage_service.dart';
import 'package:travel_explorer/models/itinerary_activity.dart';
import 'package:travel_explorer/providers/destination_provider.dart';
import 'package:travel_explorer/providers/trip_provider.dart';
import 'package:travel_explorer/providers/wishlist_provider.dart';
import 'package:travel_explorer/widgets/map/attraction_map_preview_card.dart';
import 'package:travel_explorer/widgets/map/destination_map_marker.dart';
import 'package:travel_explorer/widgets/map/destination_map_preview_card.dart';
import 'package:travel_explorer/widgets/map/itinerary_stop_marker.dart';

void main() {
  group('MapConstants & OpenStreetMap Policy Compliance Tests', () {
    test(
      'MapConstants has valid OSM raster endpoint and custom User-Agent',
      () {
        expect(MapConstants.osmTileUrl, contains('tile.openstreetmap.org'));
        expect(MapConstants.userAgentPackageName, contains('travelexplorer'));
        expect(MapConstants.osmAttribution, contains('OpenStreetMap'));
      },
    );

    test(
      'MapConstants computes accurate bounding boxes for coordinate lists',
      () {
        final points = [
          const LatLng(15.2993, 74.1240), // Goa
          const LatLng(32.2396, 77.1887), // Manali
          const LatLng(10.0889, 77.0595), // Munnar
        ];

        final bounds = MapConstants.boundsFromPoints(points);

        expect(bounds.south, lessThanOrEqualTo(10.0889));
        expect(bounds.north, greaterThanOrEqualTo(32.2396));
        expect(bounds.west, lessThanOrEqualTo(74.1240));
        expect(bounds.east, greaterThanOrEqualTo(77.1887));
      },
    );

    test(
      'All seeded destinations have valid non-null coordinates within India',
      () {
        final destinations = DestinationSeedData.destinations;
        expect(destinations.length, greaterThanOrEqualTo(12));

        for (final dest in destinations) {
          expect(
            dest.latitude,
            inInclusiveRange(8.0, 36.0),
            reason: '${dest.name} latitude out of India range',
          );
          expect(
            dest.longitude,
            inInclusiveRange(68.0, 98.0),
            reason: '${dest.name} longitude out of India range',
          );
        }
      },
    );
  });

  group('Map Marker & Preview Widget Tests', () {
    testWidgets(
      'DestinationMapMarker renders destination name and category palette',
      (WidgetTester tester) async {
        final goa = DestinationSeedData.destinations.firstWhere(
          (d) => d.id == 'goa',
        );
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: DestinationMapMarker(
                  destination: goa,
                  isSelected: false,
                  onTap: () => tapped = true,
                ),
              ),
            ),
          ),
        );

        expect(find.text('Goa'), findsOneWidget);
        expect(find.byIcon(Icons.beach_access_rounded), findsOneWidget);

        await tester.tap(find.text('Goa'));
        await tester.pump();
        expect(tapped, isTrue);
      },
    );

    testWidgets('ItineraryStopMarker renders numbered sequence and Day badge', (
      WidgetTester tester,
    ) async {
      final activity = ItineraryActivity(
        id: 'act_test',
        tripId: 'trip_test',
        dayNumber: 2,
        date: DateTime(2026, 11, 15),
        title: 'Sunset Cruise',
        locationName: 'Mandovi River',
        latitude: 15.4989,
        longitude: 73.8278,
      );

      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ItineraryStopMarker(
                stopIndex: 0,
                activity: activity,
                isSelected: true,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Day 2 • #1'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      await tester.tap(find.text('Day 2 • #1'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('DestinationMapPreviewCard displays info and handles actions', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final storage = await LocalStorageService.init();
      final destProvider = DestinationProvider(storage);
      final tripProvider = TripProvider(storage);
      final wishlistProvider = WishlistProvider(storage);

      final jaipur = DestinationSeedData.destinations.firstWhere(
        (d) => d.id == 'jaipur',
      );
      bool closed = false;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: destProvider),
            ChangeNotifierProvider.value(value: tripProvider),
            ChangeNotifierProvider.value(value: wishlistProvider),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: DestinationMapPreviewCard(
                destination: jaipur,
                onClose: () => closed = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Jaipur'), findsOneWidget);
      expect(find.text('HERITAGE'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Add to Trip'), findsOneWidget);

      // Verify close action
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      expect(closed, isTrue);
    });

    test(
      'AppConstants categories list has exactly one All and correct chips',
      () {
        expect(
          AppConstants.categories,
          equals([
            'All',
            'Beaches',
            'Mountains',
            'Heritage',
            'Adventure',
            'Spiritual',
          ]),
        );
        final allCount = AppConstants.categories
            .where((c) => c.toLowerCase() == 'all')
            .length;
        expect(allCount, equals(1));
      },
    );

    test('AppConstants category normalization matches singular, plural, and case variations', () {
      expect(AppConstants.matchesCategory('Beaches', 'All'), isTrue);
      expect(AppConstants.matchesCategory('Beaches', 'Beaches'), isTrue);
      expect(AppConstants.matchesCategory('Beach', 'Beaches'), isTrue);
      expect(AppConstants.matchesCategory('Beaches', 'Beach'), isTrue);
      expect(AppConstants.matchesCategory('Mountains', 'Mountain'), isTrue);
      expect(AppConstants.matchesCategory('Mountain', 'Mountains'), isTrue);
      expect(AppConstants.matchesCategory('Heritage', 'Heritage'), isTrue);
      expect(AppConstants.matchesCategory('Adventure', 'Adventure'), isTrue);
      expect(AppConstants.matchesCategory('Beaches', 'Mountains'), isFalse);
    });

    testWidgets(
      'AttractionMapPreviewCard renders details and triggers back callback',
      (WidgetTester tester) async {
        bool backTapped = false;
        bool closeTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AttractionMapPreviewCard(
                attractionName: 'Basilica of Bom Jesus',
                parentDestinationName: 'Goa, Goa',
                description: 'A 16th-century UNESCO World Heritage church.',
                imageUrl: 'assets/images/attractions/goa_bom_jesus.jpg',
                isFallbackCoordinates: false,
                onBackToDetails: () => backTapped = true,
                onClose: () => closeTapped = true,
              ),
            ),
          ),
        );

        expect(find.text('Basilica of Bom Jesus'), findsOneWidget);
        expect(find.text('Goa, Goa'), findsOneWidget);
        expect(find.text('Back to Destination Details'), findsOneWidget);

        await tester.tap(find.text('Back to Destination Details'));
        await tester.pump();
        expect(backTapped, isTrue);

        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pump();
        expect(closeTapped, isTrue);
      },
    );

    testWidgets(
      'AttractionMapPreviewCard shows fallback badge when coordinates missing',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AttractionMapPreviewCard(
                attractionName: 'Remote Viewpoint',
                parentDestinationName: 'Manali, Himachal Pradesh',
                isFallbackCoordinates: true,
                onBackToDetails: () {},
                onClose: () {},
              ),
            ),
          ),
        );

        expect(
          find.textContaining(
            'Precise coordinates for this attraction are unavailable',
          ),
          findsOneWidget,
        );
      },
    );
  });
}
