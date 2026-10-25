import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_explorer/data/local/local_storage_service.dart';
import 'package:travel_explorer/models/trip.dart';
import 'package:travel_explorer/providers/trip_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageService storage;
  late TripProvider tripProvider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = await LocalStorageService.init();
    tripProvider = TripProvider(storage);
  });

  group('Trip & Budget Calculations Tests', () {
    test('Calculates totalDays correctly from start and end dates', () {
      final trip = Trip(
        id: 'test_trip',
        title: 'Himalayan Trek',
        destinationName: 'Manali, Himachal Pradesh',
        startDate: DateTime(2026, 11, 10),
        endDate: DateTime(2026, 11, 14),
        plannedBudget: 20000.0,
        createdAt: DateTime.now(),
      );

      expect(
        trip.totalDays,
        equals(5),
      ); // Nov 10, 11, 12, 13, 14 = 5 inclusive days
    });

    test(
      'Trip status (isUpcoming, isOngoing, isPast) evaluates accurately',
      () {
        final futureTrip = Trip(
          id: 'future',
          title: 'Upcoming',
          destinationName: 'Goa',
          startDate: DateTime.now().add(const Duration(days: 10)),
          endDate: DateTime.now().add(const Duration(days: 14)),
          plannedBudget: 15000.0,
          createdAt: DateTime.now(),
        );
        expect(futureTrip.isUpcoming, isTrue);
        expect(futureTrip.isPast, isFalse);

        final pastTrip = Trip(
          id: 'past',
          title: 'Past Journey',
          destinationName: 'Jaipur',
          startDate: DateTime.now().subtract(const Duration(days: 20)),
          endDate: DateTime.now().subtract(const Duration(days: 15)),
          plannedBudget: 12000.0,
          createdAt: DateTime.now(),
        );
        expect(pastTrip.isPast, isTrue);
        expect(pastTrip.isUpcoming, isFalse);
      },
    );

    test('Budget totals, remaining balance, and overspend detection calculate accurately', () async {
      final trip = await tripProvider.createTrip(
        title: 'Jaipur Heritage Tour',
        destinationName: 'Jaipur',
        startDate: DateTime.now().add(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 8)),
        plannedBudget: 10000.0,
      );

      expect(tripProvider.getTotalSpentForTrip(trip.id), equals(0.0));
      expect(tripProvider.getRemainingBudget(trip.id), equals(10000.0));
      expect(tripProvider.isOverBudget(trip.id), isFalse);

      // Add expense 1
      await tripProvider.addExpense(
        tripId: trip.id,
        title: 'Palace Hotel',
        amount: 6000.0,
        category: 'Accommodation',
        date: DateTime.now(),
      );

      expect(tripProvider.getTotalSpentForTrip(trip.id), equals(6000.0));
      expect(tripProvider.getRemainingBudget(trip.id), equals(4000.0));
      expect(tripProvider.getBudgetUsageFraction(trip.id), equals(0.6));
      expect(tripProvider.isOverBudget(trip.id), isFalse);

      // Add expense 2 exceeding budget
      await tripProvider.addExpense(
        tripId: trip.id,
        title: 'Handicraft Shopping',
        amount: 5000.0,
        category: 'Shopping',
        date: DateTime.now(),
      );

      expect(tripProvider.getTotalSpentForTrip(trip.id), equals(11000.0));
      expect(tripProvider.getRemainingBudget(trip.id), equals(-1000.0));
      expect(tripProvider.isOverBudget(trip.id), isTrue);
    });

    test(
      'Itinerary activity creation and completion toggle work properly',
      () async {
        final trip = await tripProvider.createTrip(
          title: 'Goa Holiday',
          destinationName: 'Goa',
          startDate: DateTime.now().add(const Duration(days: 3)),
          endDate: DateTime.now().add(const Duration(days: 6)),
          plannedBudget: 18000.0,
        );

        await tripProvider.addActivity(
          tripId: trip.id,
          dayNumber: 1,
          date: trip.startDate,
          title: 'Sunset at Anjuna',
          locationName: 'Anjuna Beach',
        );

        final activities = tripProvider.getActivitiesForTrip(trip.id);
        expect(activities.length, equals(1));
        expect(activities.first.title, equals('Sunset at Anjuna'));
        expect(activities.first.isCompleted, isFalse);

        await tripProvider.toggleActivityCompleted(activities.first.id);
        final updated = tripProvider.getActivitiesForTrip(trip.id);
        expect(updated.first.isCompleted, isTrue);
      },
    );
  });
}
