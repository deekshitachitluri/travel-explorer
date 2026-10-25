import 'package:flutter_test/flutter_test.dart';
import 'package:travel_explorer/data/local/destination_seed_data.dart';
import 'package:travel_explorer/services/recommendation_service.dart';

void main() {
  final allDests = DestinationSeedData.destinations;

  group('Smart Recommendation / Matcher Algorithm Tests', () {
    test('Mountain preference with budget ranks hill stations on top', () {
      const criteria = MatchCriteria(
        preferredCategory: 'Mountains',
        maxDailyBudget: 3500.0,
        preferredDurationDays: 4,
        interests: ['Snow', 'Trekking'],
      );

      final matches = RecommendationService.matchDestinations(
        allDestinations: allDests,
        criteria: criteria,
      );

      expect(matches.isNotEmpty, isTrue);
      // Top match should be a mountain destination like Manali or Munnar
      expect(matches.first.destination.category, equals('Mountains'));
      expect(matches.first.score, greaterThanOrEqualTo(70));
      expect(matches.first.matchReasons.isNotEmpty, isTrue);
    });

    test('Beach preference ranks coastal destinations highest', () {
      const criteria = MatchCriteria(
        preferredCategory: 'Beaches',
        maxDailyBudget: 4000.0,
        interests: ['Beach', 'Water Sports'],
      );

      final matches = RecommendationService.matchDestinations(
        allDestinations: allDests,
        criteria: criteria,
      );

      expect(matches.first.destination.category, equals('Beaches'));
      expect(
        ['goa', 'andaman', 'alleppey'].contains(matches.first.destination.id),
        isTrue,
      );
    });

    test('Gracefully handles empty criteria without throwing exceptions', () {
      const criteria = MatchCriteria();
      final matches = RecommendationService.matchDestinations(
        allDestinations: allDests,
        criteria: criteria,
      );

      expect(matches.length, equals(allDests.length));
      for (final m in matches) {
        expect(m.score, inInclusiveRange(0, 100));
        expect(m.matchReasons.isNotEmpty, isTrue);
      }
    });
  });
}
