import 'package:flutter_test/flutter_test.dart';
import 'package:travel_explorer/data/local/destination_seed_data.dart';
import 'package:travel_explorer/models/destination.dart';
import 'package:travel_explorer/models/trip.dart';
import 'package:travel_explorer/services/travel_buddy_service.dart';

void main() {
  group('TravelBuddyService Interactive AI Companion Tests', () {
    late TravelBuddyService buddy;
    late List<Destination> destinations;

    setUp(() {
      buddy = TravelBuddyService();
      destinations = DestinationSeedData.destinations;
    });

    test('Initializes with welcome message and default prompt actions', () {
      expect(buddy.messages.length, equals(1));
      final welcome = buddy.messages.first;
      expect(welcome.isUser, isFalse);
      expect(welcome.text, contains("Hey, I'm Travel Buddy!"));
      expect(welcome.actionButtons, isNotEmpty);
      expect(welcome.actionButtons.any((b) => b.route == '/explore'), isTrue);
      expect(welcome.actionButtons.any((b) => b.route == '/map'), isTrue);
    });

    test(
      'Answers navigation questions with direct routes and buttons',
      () async {
        // 1. Wishlist navigation
        final reply1 = await buddy.processUserMessage(
          userText: 'Where can I find my wishlist?',
          allDestinations: destinations,
          wishlistDestinations: [],
          trips: [],
        );
        expect(reply1.text, contains('Wishlist'));
        expect(reply1.actionButtons.any((b) => b.route == '/wishlist'), isTrue);

        // 2. Trips & Itinerary navigation
        final reply2 = await buddy.processUserMessage(
          userText: 'How do I add a place to my trip?',
          allDestinations: destinations,
          wishlistDestinations: [],
          trips: [],
        );
        expect(reply2.text, contains('My Trips'));
        expect(reply2.actionButtons.any((b) => b.route == '/trips'), isTrue);

        // 3. Map navigation
        final reply3 = await buddy.processUserMessage(
          userText: 'Where is the map?',
          allDestinations: destinations,
          wishlistDestinations: [],
          trips: [],
        );
        expect(reply3.text, contains('Interactive Map'));
        expect(reply3.actionButtons.any((b) => b.route == '/map'), isTrue);
      },
    );

    test(
      'Budget query calculates planned budget vs actual spending accurately',
      () async {
        final trip = Trip(
          id: 'trip_1',
          title: 'Goa Coastal Getaway',
          destinationId: 'goa',
          destinationName: 'Goa, Goa',
          destinationImage: 'assets/images/destinations/goa.jpg',
          startDate: DateTime(2026, 12, 1),
          endDate: DateTime(2026, 12, 5),
          plannedBudget: 20000,
          createdAt: DateTime(2026, 11, 1),
        );

        final reply = await buddy.processUserMessage(
          userText: 'Where can I check my budget and actual spending?',
          allDestinations: destinations,
          wishlistDestinations: [],
          trips: [trip],
          totalActualExpenses: 7000,
        );

        // Total planned: 20000, total actual: 7000, remaining: 13000
        expect(reply.text, contains('Planned Budget: ₹20000'));
        expect(reply.text, contains('Actual Spending: ₹7000'));
        expect(reply.text, contains('Remaining Balance: ₹13000'));
        expect(reply.actionButtons.any((b) => b.route == '/trips'), isTrue);
      },
    );

    test(
      'Wishlist query lists saved destinations or guides empty state',
      () async {
        // Empty state
        final emptyReply = await buddy.processUserMessage(
          userText: 'Show me my wishlist',
          allDestinations: destinations,
          wishlistDestinations: [],
          trips: [],
        );
        expect(emptyReply.text, contains('currently empty'));
        expect(emptyReply.destinations, isEmpty);

        // Populated state
        final goa = destinations.firstWhere((d) => d.id == 'goa');
        final populatedReply = await buddy.processUserMessage(
          userText: 'What are my saved places in my wishlist?',
          allDestinations: destinations,
          wishlistDestinations: [goa],
          trips: [],
        );
        expect(
          populatedReply.text,
          contains('saved 1 destination(s) in your Wishlist'),
        );
        expect(populatedReply.destinations.length, equals(1));
        expect(populatedReply.destinations.first.id, equals('goa'));
      },
    );

    test('Respects positive and negative category constraints ("mountains, not beaches")', () async {
      final reply = await buddy.processUserMessage(
        userText: 'I want mountains, not beaches',
        allDestinations: destinations,
        wishlistDestinations: [],
        trips: [],
      );

      expect(reply.destinations, isNotEmpty);
      // All returned destinations must be Mountains
      for (final dest in reply.destinations) {
        expect(dest.category, equals('Mountains'));
      }
      // Zero Beach destinations returned
      expect(reply.destinations.any((d) => d.category == 'Beaches'), isFalse);
    });

    test(
      'Budget constraint filters recommendations under specified limit',
      () async {
        final reply = await buddy.processUserMessage(
          userText: 'Find peaceful places under ₹3,500',
          allDestinations: destinations,
          wishlistDestinations: [],
          trips: [],
        );

        expect(reply.destinations, isNotEmpty);
        for (final dest in reply.destinations) {
          expect(dest.estimatedDailyCost, lessThanOrEqualTo(3500));
        }
      },
    );

    test('Follow-up query retains previous category context', () async {
      // Turn 1: Ask for mountains
      await buddy.processUserMessage(
        userText: 'Show me mountains',
        allDestinations: destinations,
        wishlistDestinations: [],
        trips: [],
      );
      expect(buddy.context.positiveCategory, equals('Mountains'));

      // Turn 2: Follow-up specifying budget only
      final followUpReply = await buddy.processUserMessage(
        userText: 'under ₹3,500',
        allDestinations: destinations,
        wishlistDestinations: [],
        trips: [],
      );

      expect(followUpReply.destinations, isNotEmpty);
      // Retained category Mountains from Turn 1
      for (final dest in followUpReply.destinations) {
        expect(dest.category, equals('Mountains'));
        expect(dest.estimatedDailyCost, lessThanOrEqualTo(3500));
      }
    });

    test('Suggest peaceful places in South India', () async {
      final reply = await buddy.processUserMessage(
        userText: 'Suggest peaceful places in South India',
        allDestinations: destinations,
        wishlistDestinations: [],
        trips: [],
      );
      expect(reply.destinations, isNotEmpty);
      for (final dest in reply.destinations) {
        expect(
          dest.tags.contains('South India') ||
              [
                'Kerala',
                'Karnataka',
                'Tamil Nadu',
                'Andhra Pradesh',
                'Telangana',
                'Goa',
                'Puducherry',
                'Lakshadweep',
              ].contains(dest.state),
          isTrue,
        );
      }
    });

    test('Show me hill stations in India', () async {
      final reply = await buddy.processUserMessage(
        userText: 'Show me hill stations in India',
        allDestinations: destinations,
        wishlistDestinations: [],
        trips: [],
      );
      expect(reply.destinations, isNotEmpty);
      for (final dest in reply.destinations) {
        expect(dest.category, equals('Mountains'));
      }
    });

    test('Find heritage destinations in Rajasthan', () async {
      final reply = await buddy.processUserMessage(
        userText: 'Find heritage destinations in Rajasthan',
        allDestinations: destinations,
        wishlistDestinations: [],
        trips: [],
      );
      expect(reply.destinations, isNotEmpty);
      for (final dest in reply.destinations) {
        expect(dest.state, equals('Rajasthan'));
        expect(dest.category, equals('Heritage'));
      }
    });

    test('Suggest beaches outside Goa', () async {
      final reply = await buddy.processUserMessage(
        userText: 'Suggest beaches outside Goa',
        allDestinations: destinations,
        wishlistDestinations: [],
        trips: [],
      );
      expect(reply.destinations, isNotEmpty);
      for (final dest in reply.destinations) {
        expect(dest.category, equals('Beaches'));
        expect(dest.id, isNot(equals('goa')));
        expect(dest.state, isNot(equals('Goa')));
      }
    });

    test('Recommend places in Northeast India', () async {
      final reply = await buddy.processUserMessage(
        userText: 'Recommend places in Northeast India',
        allDestinations: destinations,
        wishlistDestinations: [],
        trips: [],
      );
      expect(reply.destinations, isNotEmpty);
      for (final dest in reply.destinations) {
        expect(
          dest.tags.contains('Northeast India') ||
              [
                'Assam',
                'Meghalaya',
                'Arunachal Pradesh',
                'Nagaland',
                'Manipur',
                'Mizoram',
                'Tripura',
                'Sikkim',
              ].contains(dest.state),
          isTrue,
        );
      }
    });

    test('Find destinations suitable for a weekend', () async {
      final reply = await buddy.processUserMessage(
        userText: 'Find destinations suitable for a weekend',
        allDestinations: destinations,
        wishlistDestinations: [],
        trips: [],
      );
      expect(reply.destinations, isNotEmpty);
      for (final dest in reply.destinations) {
        expect(
          dest.isWeekendGetaway || dest.suggestedDurationDays <= 3,
          isTrue,
        );
      }
    });

    test('Show me lesser-known destinations', () async {
      final reply = await buddy.processUserMessage(
        userText: 'Show me lesser-known destinations',
        allDestinations: destinations,
        wishlistDestinations: [],
        trips: [],
      );
      expect(reply.destinations, isNotEmpty);
      for (final dest in reply.destinations) {
        expect(
          !dest.isPopular ||
              dest.tags.any(
                (t) =>
                    t.toLowerCase().contains('offbeat') ||
                    t.toLowerCase().contains('peaceful'),
              ),
          isTrue,
        );
      }
    });

    test('Compare Munnar and Coorg', () async {
      final reply = await buddy.processUserMessage(
        userText: 'Compare Munnar and Coorg',
        allDestinations: destinations,
        wishlistDestinations: [],
        trips: [],
      );
      expect(reply.text, contains('Munnar'));
      expect(reply.text, contains('Coorg'));
      expect(reply.text, contains('Estimated Daily Cost'));
      expect(reply.destinations.length, equals(2));
      expect(reply.destinations.any((d) => d.id == 'munnar'), isTrue);
      expect(reply.destinations.any((d) => d.id == 'coorg'), isTrue);
    });

    test(
      'Clear conversation resets messages and context back to welcome',
      () async {
        await buddy.processUserMessage(
          userText: 'Show me mountains',
          allDestinations: destinations,
          wishlistDestinations: [],
          trips: [],
        );
        expect(buddy.messages.length, greaterThan(1));
        expect(buddy.context.positiveCategory, isNotNull);

        buddy.clearConversation();
        expect(buddy.messages.length, equals(1));
        expect(buddy.messages.first.text, contains("Hey, I'm Travel Buddy!"));
        expect(buddy.context.positiveCategory, isNull);
      },
    );

    test('Spiritual query returns verified spiritual destinations', () async {
      final reply = await buddy.processUserMessage(
        userText: 'Show me spiritual places',
        allDestinations: destinations,
        wishlistDestinations: [],
        trips: [],
      );

      expect(reply.destinations, isNotEmpty);
      expect(buddy.context.positiveCategory, equals('Spiritual'));
      for (final dest in reply.destinations) {
        expect(dest.matchesCategory('Spiritual'), isTrue);
      }
    });

    test('Pagination across turns returns non-overlapping batches and accurate counts', () async {
      // Turn 1: Ask for mountains
      final reply1 = await buddy.processUserMessage(
        userText: 'Show me mountains',
        allDestinations: destinations,
        wishlistDestinations: [],
        trips: [],
      );

      expect(reply1.destinations.length, equals(4));
      expect(reply1.text, contains('verified destination(s) in Mountains'));
      expect(reply1.text, contains('(showing top 4 of'));
      expect(
        reply1.actionButtons.any((b) => b.label.contains('Show More')),
        isTrue,
      );
      final turn1Ids = reply1.destinations.map((d) => d.id).toSet();

      // Turn 2: Ask for more mountains
      final reply2 = await buddy.processUserMessage(
        userText: 'more mountains',
        allDestinations: destinations,
        wishlistDestinations: [],
        trips: [],
      );

      expect(reply2.destinations.length, equals(4));
      expect(
        reply2.text,
        contains('Here are the next 4 destination(s) in Mountains'),
      );
      expect(reply2.text, contains('(8 of'));
      final turn2Ids = reply2.destinations.map((d) => d.id).toSet();

      // Ensure NO duplicate destinations between Turn 1 and Turn 2
      expect(turn1Ids.intersection(turn2Ids), isEmpty);

      // Turn 3: Ask "what else"
      final reply3 = await buddy.processUserMessage(
        userText: 'what else',
        allDestinations: destinations,
        wishlistDestinations: [],
        trips: [],
      );

      expect(reply3.destinations.length, equals(4));
      final turn3Ids = reply3.destinations.map((d) => d.id).toSet();
      expect(turn1Ids.intersection(turn3Ids), isEmpty);
      expect(turn2Ids.intersection(turn3Ids), isEmpty);
    });

    test('Pagination exhaustion returns friendly completion message and exploration buttons', () async {
      // Create a small mock list of 2 destinations
      final mockDests = destinations
          .where((d) => d.matchesCategory('Beaches'))
          .take(2)
          .toList();

      // Turn 1: Shows both
      final reply1 = await buddy.processUserMessage(
        userText: 'Show me beaches',
        allDestinations: mockDests,
        wishlistDestinations: [],
        trips: [],
      );
      expect(reply1.destinations.length, equals(2));

      // Turn 2: All 2 have already been shown -> exhausted!
      final reply2 = await buddy.processUserMessage(
        userText: 'show more beaches',
        allDestinations: mockDests,
        wishlistDestinations: [],
        trips: [],
      );

      expect(reply2.destinations, isEmpty);
      expect(
        reply2.text,
        contains("You've explored all 2 verified Beaches destination(s)"),
      );
      expect(reply2.actionButtons.any((b) => b.route == '/map'), isTrue);
      expect(reply2.actionButtons.any((b) => b.route == '/explore'), isTrue);
    });

    test('Scenario 1 & 2: Explicit recommendation request returns cards, followed by more', () async {
      final recReply = await buddy.processUserMessage(
        userText: 'Suggest peaceful mountain destinations',
        allDestinations: destinations,
        wishlistDestinations: [],
        trips: [],
      );
      expect(recReply.destinations, isNotEmpty);
      expect(
        recReply.destinations.every((d) => d.category == 'Mountains'),
        isTrue,
      );

      final initialIds = recReply.destinations.map((d) => d.id).toSet();

      final moreReply = await buddy.processUserMessage(
        userText: 'show me more',
        allDestinations: destinations,
        wishlistDestinations: [],
        trips: [],
      );
      expect(moreReply.destinations, isNotEmpty);
      for (final d in moreReply.destinations) {
        expect(initialIds.contains(d.id), isFalse);
      }
    });

    test('Scenario 3: Local food question returns authentic dishes and ZERO destination cards', () async {
      final foodReply = await buddy.processUserMessage(
        userText: 'What should I eat in Madurai?',
        allDestinations: destinations,
        wishlistDestinations: [],
        trips: [],
      );

      expect(foodReply.destinations, isEmpty);
      expect(foodReply.text, contains('Madurai'));
      expect(foodReply.text, contains('Jigarthanda'));
      expect(foodReply.text, contains('Kari Dosa'));
      expect(
        foodReply.actionButtons.any((b) => b.route.contains('madurai')),
        isTrue,
      );
    });

    test('Scenario 4: Shopping spots question returns authentic spots and ZERO destination cards', () async {
      final shopReply = await buddy.processUserMessage(
        userText: 'Where can I shop in Munnar?',
        allDestinations: destinations,
        wishlistDestinations: [],
        trips: [],
      );

      expect(shopReply.destinations, isEmpty);
      expect(shopReply.text, contains('Munnar'));
      expect(shopReply.text, contains('Market'));
      expect(shopReply.text, contains('Spice'));
      expect(
        shopReply.actionButtons.any((b) => b.route.contains('munnar')),
        isTrue,
      );
    });

    test('Scenario 5: Unrelated educational question politely redirects with ZERO destination cards', () async {
      final edReply = await buddy.processUserMessage(
        userText: 'Explain binary search.',
        allDestinations: destinations,
        wishlistDestinations: [],
        trips: [],
      );

      expect(edReply.destinations, isEmpty);
      expect(
        edReply.text,
        contains(
          "I'm mainly here to help with travel planning, destinations, local food, shopping spots, and itineraries.",
        ),
      );
      expect(edReply.text, contains('Want help planning a trip instead?'));
    });

    test('Scenario 6: Unknown real-time opening hours admits unknown status with ZERO destination cards', () async {
      final liveReply = await buddy.processUserMessage(
        userText: 'Is this particular local market open right now?',
        allDestinations: destinations,
        wishlistDestinations: [],
        trips: [],
      );

      expect(liveReply.destinations, isEmpty);
      expect(
        liveReply.text,
        contains(
          "I don't have verified current opening hours or live operational status",
        ),
      );
      expect(
        liveReply.text,
        contains('check the official listing or local notice before visiting'),
      );
    });

    test('Scenario 7: Ambiguous question asks for clarification with ZERO destination cards', () async {
      final ambReply = await buddy.processUserMessage(
        userText: 'places',
        allDestinations: destinations,
        wishlistDestinations: [],
        trips: [],
      );

      expect(ambReply.destinations, isEmpty);
      expect(
        ambReply.text,
        contains(
          "Could you tell me which destination or region in India you'd like to explore",
        ),
      );
      expect(ambReply.actionButtons, isNotEmpty);
    });
  });
}
