import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_explorer/data/local/destination_seed_data.dart';
import 'package:travel_explorer/data/local/local_storage_service.dart';
import 'package:travel_explorer/models/user_review.dart';
import 'package:travel_explorer/providers/destination_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Destination Rating & Review System Unit Tests', () {
    late LocalStorageService storage;
    late DestinationProvider destProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storage = LocalStorageService(prefs);
      destProvider = DestinationProvider(storage);
    });

    test('UserReview serializes and deserializes to JSON correctly', () {
      final now = DateTime(2026, 10, 25, 20, 30);
      final review = UserReview(
        id: 'rev_1',
        destinationId: 'munnar',
        userId: 'usr_123',
        userName: 'Aarav Sharma',
        rating: 5.0,
        comment: 'Stunning tea plantations and cool mist morning walks!',
        createdAt: now,
      );

      final json = review.toJson();
      expect(json['id'], equals('rev_1'));
      expect(json['destinationId'], equals('munnar'));
      expect(json['userId'], equals('usr_123'));
      expect(json['userName'], equals('Aarav Sharma'));
      expect(json['rating'], equals(5.0));
      expect(json['comment'], contains('tea plantations'));

      final parsed = UserReview.fromJson(json);
      expect(parsed.id, equals(review.id));
      expect(parsed.destinationId, equals(review.destinationId));
      expect(parsed.rating, equals(review.rating));
      expect(parsed.comment, equals(review.comment));
    });

    test(
      'Submitting a rating stores review and associates with destination ID',
      () async {
        final initialReviews = destProvider.getReviewsForDestination('munnar');
        expect(initialReviews, isEmpty);

        await destProvider.submitRating(
          destinationId: 'munnar',
          rating: 5.0,
          comment: 'Loved the tea estate tour and Mattupetty dam.',
          userId: 'traveler_1',
          userName: 'Priya Patel',
        );

        final munnarReviews = destProvider.getReviewsForDestination('munnar');
        expect(munnarReviews.length, equals(1));
        final rev = munnarReviews.first;
        expect(rev.destinationId, equals('munnar'));
        expect(rev.userId, equals('traveler_1'));
        expect(rev.userName, equals('Priya Patel'));
        expect(rev.rating, equals(5.0));
        expect(rev.comment, contains('tea estate tour'));

        // Check isolation: other destinations have 0 reviews
        expect(destProvider.getReviewsForDestination('goa'), isEmpty);
      },
    );

    test(
      'Resubmitting updates existing rating rather than creating duplicate',
      () async {
        await destProvider.submitRating(
          destinationId: 'goa',
          rating: 4.0,
          comment: 'Nice beach sunset.',
          userId: 'user_goa',
          userName: 'Rohan',
        );

        var goaReviews = destProvider.getReviewsForDestination('goa');
        expect(goaReviews.length, equals(1));
        expect(goaReviews.first.rating, equals(4.0));

        // User updates their rating to 5 stars with new comment
        await destProvider.submitRating(
          destinationId: 'goa',
          rating: 5.0,
          comment: 'Updated: absolutely incredible water sports at Palolem!',
          userId: 'user_goa',
          userName: 'Rohan',
        );

        goaReviews = destProvider.getReviewsForDestination('goa');
        expect(
          goaReviews.length,
          equals(1),
          reason: 'Should replace rather than duplicate',
        );
        expect(goaReviews.first.rating, equals(5.0));
        expect(
          goaReviews.first.comment,
          contains('Updated: absolutely incredible'),
        );
      },
    );

    test(
      'Computes combined aggregate rating and review count correctly',
      () async {
        final dest = DestinationSeedData.destinations.firstWhere(
          (d) => d.id == 'jaipur',
        );
        final baseRating = dest.rating; // e.g. 4.8
        final baseReviews = dest.reviewCount; // e.g. 4120

        // Add 2 user reviews
        await destProvider.submitRating(
          destinationId: 'jaipur',
          rating: 5.0,
          comment: 'Hawa Mahal was majestic!',
          userId: 'user_1',
          userName: 'User 1',
        );
        await destProvider.submitRating(
          destinationId: 'jaipur',
          rating: 5.0,
          comment: 'Amber fort light show is unmissable.',
          userId: 'user_2',
          userName: 'User 2',
        );

        final localReviews = destProvider.getReviewsForDestination('jaipur');
        expect(localReviews.length, equals(2));

        final totalReviews = baseReviews + localReviews.length;
        final localSum = localReviews.fold<double>(
          0.0,
          (acc, r) => acc + r.rating,
        );
        final aggregateRating =
            (baseRating * baseReviews + localSum) / totalReviews;

        expect(totalReviews, equals(baseReviews + 2));
        expect(aggregateRating, greaterThanOrEqualTo(baseRating));
      },
    );

    test(
      'Guest rating can be posted with fallback guest user credentials',
      () async {
        await destProvider.submitRating(
          destinationId: 'varanasi',
          rating: 5.0,
          comment: 'Magical Ganga Aarti experience at dusk.',
          userId: 'guest',
          userName: 'Guest Traveler',
        );

        final rev = destProvider.getUserReview('varanasi', 'guest');
        expect(rev, isNotNull);
        expect(rev!.userId, equals('guest'));
        expect(rev.userName, equals('Guest Traveler'));
        expect(rev.rating, equals(5.0));
      },
    );
  });
}
