import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_explorer/data/local/destination_seed_data.dart';
import 'package:travel_explorer/data/local/local_storage_service.dart';
import 'package:travel_explorer/features/explore/explore_screen.dart';
import 'package:travel_explorer/features/profile/profile_screen.dart';
import 'package:travel_explorer/models/destination.dart';
import 'package:travel_explorer/providers/auth_provider.dart';
import 'package:travel_explorer/providers/destination_provider.dart';
import 'package:travel_explorer/providers/trip_provider.dart';
import 'package:travel_explorer/providers/wishlist_provider.dart';
import 'package:travel_explorer/services/auth_service.dart';
import 'package:travel_explorer/widgets/destination_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageService storage;
  late WishlistProvider wishlistProvider;
  late DestinationProvider destProvider;
  late AuthProvider authProvider;
  late TripProvider tripProvider;
  late Destination standardDestination;
  late Destination longDestination;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    storage = LocalStorageService(prefs);
    wishlistProvider = WishlistProvider(storage);
    destProvider = DestinationProvider(storage);
    authProvider = AuthProvider(LocalAuthService(prefs));
    tripProvider = TripProvider(storage);

    standardDestination = DestinationSeedData.destinations.first;
    final base = DestinationSeedData.destinations[1];
    longDestination = Destination(
      id: 'test_long_dest',
      name: 'Great Himalayan National Park Conservation Area',
      city: 'Kullu Valley Ecozone Region',
      state: 'Himachal Pradesh Western Himalayas',
      description: base.description,
      category: 'Adventure',
      categories: base.categories,
      rating: 4.8,
      reviewCount: 342,
      imageUrl: base.imageUrl,
      galleryUrls: base.galleryUrls,
      bestTimeToVisit: base.bestTimeToVisit,
      seasons: base.seasons,
      tags: ['himalayas', 'trekking', 'unesco'],
      latitude: 31.7,
      longitude: 77.4,
      estimatedDailyCost: 4500.0,
      suggestedDurationDays: 5,
      highlights: base.highlights,
      localFoods: base.localFoods,
      travelTips: base.travelTips,
      attractions: base.attractions,
      isPopular: true,
      isTrending: true,
      isWeekendGetaway: false,
    );
  });

  Widget createExploreTestWidget({required Size screenSize}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: wishlistProvider),
        ChangeNotifierProvider.value(value: destProvider),
      ],
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: screenSize),
          child: const ExploreScreen(),
        ),
      ),
    );
  }

  Widget createProfileTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: wishlistProvider),
        ChangeNotifierProvider.value(value: tripProvider),
      ],
      child: const MaterialApp(home: ProfileScreen()),
    );
  }

  group('Explore Destination Card Responsive Layout Tests', () {
    final screenWidths = [320.0, 360.0, 375.0, 390.0, 412.0, 768.0, 1200.0];

    for (final width in screenWidths) {
      testWidgets(
        'Explore screen displays destination cards with ZERO overflow at width ${width}px',
        (tester) async {
          tester.view.physicalSize = Size(width, 800);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            createExploreTestWidget(screenSize: Size(width, 800)),
          );
          await tester.pumpAndSettle();

          // Ensure no Flutter layout exceptions were thrown
          expect(
            tester.takeException(),
            isNull,
            reason: 'Expected no RenderFlex overflow at width $width',
          );

          // Confirm destination cards exist and are visible
          expect(find.byType(DestinationCard), findsWidgets);
        },
      );
    }

    testWidgets(
      'DestinationCard renders long destination names and locations without overflow',
      (tester) async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [ChangeNotifierProvider.value(value: wishlistProvider)],
            child: MaterialApp(
              home: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 157,
                    height: 255,
                    child: DestinationCard(
                      destination: longDestination,
                      onTap: () {},
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(
          find.textContaining('Great Himalayan National Park'),
          findsOneWidget,
        );
        expect(find.textContaining('Kullu Valley'), findsOneWidget);
      },
    );

    testWidgets(
      'DestinationCard elements (badges, prices, tags) are all present and accessible',
      (tester) async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [ChangeNotifierProvider.value(value: wishlistProvider)],
            child: MaterialApp(
              home: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 165,
                    height: 255,
                    child: DestinationCard(
                      destination: standardDestination,
                      onTap: () {},
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Category tag
        expect(
          find.text(standardDestination.category.toUpperCase()),
          findsOneWidget,
        );
        // Destination name
        expect(find.text(standardDestination.name), findsOneWidget);
        // Duration tag
        expect(
          find.text('${standardDestination.suggestedDurationDays}d'),
          findsOneWidget,
        );
        // Wishlist icon
        expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
      },
    );
  });

  group('Profile Screen Firebase Setup Guide Removal Tests', () {
    testWidgets(
      'Firebase Setup Guide is removed from Profile while keeping other options',
      (tester) async {
        await tester.pumpWidget(createProfileTestWidget());
        await tester.pumpAndSettle();

        // 1. Firebase Setup Guide must be completely absent
        expect(find.text('Firebase Setup Guide'), findsNothing);
        expect(
          find.text('Instructions to link your Firebase project'),
          findsNothing,
        );

        // 2. Remaining profile options must remain present and functional
        expect(find.text('Edit Profile Details'), findsOneWidget);
        expect(find.text('Smart Destination Matcher'), findsOneWidget);
        expect(find.text('Settings & Appearance'), findsOneWidget);

        // 3. Authentication option must be present
        expect(find.text('Sign In or Create Account'), findsOneWidget);
      },
    );
  });
}
