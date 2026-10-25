import 'package:flutter_test/flutter_test.dart';
import 'package:travel_explorer/models/destination.dart';
import 'package:travel_explorer/models/expense.dart';
import 'package:travel_explorer/models/itinerary_activity.dart';
import 'package:travel_explorer/models/trip.dart';
import 'package:travel_explorer/models/user_profile.dart';

void main() {
  group('Data Model JSON Serialization & Parsing Tests', () {
    test('Destination JSON round-trip serialization preserves all fields', () {
      const dest = Destination(
        id: 'coorg_test',
        name: 'Coorg',
        city: 'Madikeri',
        state: 'Karnataka',
        country: 'India',
        category: 'Mountains',
        description: 'Lush coffee estates and misty peaks.',
        imageUrl: 'https://example.com/coorg.jpg',
        galleryUrls: ['https://example.com/c1.jpg'],
        bestTimeToVisit: 'Oct - Mar',
        seasons: ['Winter (Oct - Mar)'],
        estimatedDailyCost: 2900.0,
        suggestedDurationDays: 3,
        latitude: 12.4244,
        longitude: 75.7382,
        rating: 4.8,
        reviewCount: 1500,
        tags: ['Coffee', 'Trekking'],
        highlights: ['Abbey Falls', 'Tadiandamol Peak'],
        localFoods: ['Pandi Curry'],
        travelTips: ['Wear trekking shoes'],
        attractions: [],
      );

      final json = dest.toJson();
      final parsed = Destination.fromJson(json);

      expect(parsed.id, equals(dest.id));
      expect(parsed.name, equals(dest.name));
      expect(parsed.estimatedDailyCost, equals(2900.0));
      expect(parsed.suggestedDurationDays, equals(3));
      expect(parsed.tags, equals(['Coffee', 'Trekking']));
    });

    test('Trip JSON round-trip serialization preserves all fields', () {
      final trip = Trip(
        id: 't_123',
        title: 'Kerala Backwaters Tour',
        destinationName: 'Alleppey, Kerala',
        startDate: DateTime(2026, 12, 1),
        endDate: DateTime(2026, 12, 5),
        numberOfTravelers: 2,
        plannedBudget: 35000.0,
        travelStyle: 'Leisure',
        notes: 'Book houseboat early',
        createdAt: DateTime(2026, 10, 24),
      );

      final json = trip.toJson();
      final parsed = Trip.fromJson(json);

      expect(parsed.id, equals(trip.id));
      expect(parsed.title, equals(trip.title));
      expect(parsed.plannedBudget, equals(35000.0));
      expect(parsed.numberOfTravelers, equals(2));
      expect(parsed.totalDays, equals(5));
    });

    test(
      'Expense JSON round-trip serialization preserves amount and category',
      () {
        final expense = Expense(
          id: 'exp_999',
          tripId: 't_123',
          title: 'Authentic Goan Thali',
          amount: 850.0,
          category: 'Food',
          date: DateTime(2026, 10, 24),
          notes: 'Includes drinks',
        );

        final json = expense.toJson();
        final parsed = Expense.fromJson(json);

        expect(parsed.id, equals('exp_999'));
        expect(parsed.amount, equals(850.0));
        expect(parsed.category, equals('Food'));
        expect(parsed.title, equals('Authentic Goan Thali'));
      },
    );

    test(
      'ItineraryActivity JSON round-trip serialization preserves details',
      () {
        final act = ItineraryActivity(
          id: 'act_001',
          tripId: 't_123',
          dayNumber: 2,
          date: DateTime(2026, 12, 2),
          title: 'Visit Hawa Mahal',
          locationName: 'Jaipur, Rajasthan',
          time: '10:00 AM',
          notes: 'Carry camera',
          isCompleted: true,
          latitude: 26.9239,
          longitude: 75.8267,
        );

        final json = act.toJson();
        final parsed = ItineraryActivity.fromJson(json);

        expect(parsed.dayNumber, equals(2));
        expect(parsed.title, equals('Visit Hawa Mahal'));
        expect(parsed.isCompleted, isTrue);
        expect(parsed.latitude, equals(26.9239));
      },
    );

    test('UserProfile Guest profile initialization has correct flags', () {
      final guest = UserProfile.guest();
      expect(guest.isGuest, isTrue);
      expect(guest.displayName, equals('Guest Traveler'));

      final registered = guest.copyWith(
        displayName: 'Aarav Sharma',
        isGuest: false,
      );
      expect(registered.isGuest, isFalse);
      expect(registered.displayName, equals('Aarav Sharma'));
    });
  });
}
