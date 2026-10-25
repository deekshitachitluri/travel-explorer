import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  group('Expanded India-Wide Catalogue Integrity Tests', () {
    test('Catalogue contains at least 100 distinct destinations (126 total)', () {
      final allDests = provider.allDestinations;
      expect(allDests.length, greaterThanOrEqualTo(100));
      expect(allDests.length, equals(126));
    });

    test('Zero duplicate IDs across all 126 destinations', () {
      final allDests = provider.allDestinations;
      final ids = <String>{};
      for (final dest in allDests) {
        expect(
          ids.contains(dest.id),
          isFalse,
          reason: 'Duplicate destination ID detected: ${dest.id}',
        );
        ids.add(dest.id);
      }
      expect(ids.length, equals(allDests.length));
    });

    test('Preserves all 14 baseline destinations and their exact IDs', () {
      const original14 = [
        'goa',
        'manali',
        'jaipur',
        'munnar',
        'shimla',
        'udaipur',
        'rishikesh',
        'varanasi',
        'andaman',
        'coorg',
        'ooty',
        'hampi',
        'ladakh',
        'alleppey',
      ];

      for (final id in original14) {
        final dest = provider.findById(id);
        expect(dest, isNotNull, reason: 'Missing original destination: $id');
        expect(dest!.id, equals(id));
      }
    });

    test('Every destination conforms to valid standard categories', () {
      const allowedCategories = [
        'Beaches',
        'Mountains',
        'Heritage',
        'Adventure',
        'Spiritual',
      ];
      for (final dest in provider.allDestinations) {
        expect(
          allowedCategories.contains(dest.category),
          isTrue,
          reason: '${dest.name} has invalid category: ${dest.category}',
        );
      }
    });

    test('Every destination has valid coordinates within Indian geography', () {
      for (final dest in provider.allDestinations) {
        expect(
          dest.latitude,
          inInclusiveRange(8.0, 36.0),
          reason: '${dest.name} (${dest.id}) latitude ${dest.latitude} out of India range',
        );
        expect(
          dest.longitude,
          inInclusiveRange(68.0, 98.0),
          reason: '${dest.name} (${dest.id}) longitude ${dest.longitude} out of India range',
        );
      }
    });

    test('Covers broad geographic representation across Indian states & UTs', () {
      final states = provider.allDestinations.map((d) => d.state).toSet();
      // Should cover at least 25 different Indian states and Union Territories
      expect(states.length, greaterThanOrEqualTo(25));
      expect(states, contains('Jammu & Kashmir'));
      expect(states, contains('Himachal Pradesh'));
      expect(states, contains('Uttarakhand'));
      expect(states, contains('Rajasthan'));
      expect(states, contains('Gujarat'));
      expect(states, contains('Maharashtra'));
      expect(states, contains('Madhya Pradesh'));
      expect(states, contains('Kerala'));
      expect(states, contains('Karnataka'));
      expect(states, contains('Tamil Nadu'));
      expect(states, contains('Andhra Pradesh'));
      expect(states, contains('Telangana'));
      expect(states, contains('West Bengal'));
      expect(states, contains('Odisha'));
      expect(states, contains('Sikkim'));
      expect(states, contains('Meghalaya'));
      expect(states, contains('Assam'));
      expect(states, contains('Arunachal Pradesh'));
      expect(states, contains('Nagaland'));
      expect(states, contains('Manipur'));
      expect(states, contains('Mizoram'));
      expect(states, contains('Tripura'));
    });

    test('Search query matches newly added destinations by state, city, and tag', () {
      // 1. Search by state 'Meghalaya'
      provider.setSearchQuery('Meghalaya');
      final meghalayaDests = provider.filteredDestinations;
      expect(meghalayaDests.length, greaterThanOrEqualTo(4));
      expect(meghalayaDests.any((d) => d.id == 'shillong'), isTrue);
      expect(meghalayaDests.any((d) => d.id == 'cherrapunji'), isTrue);
      expect(meghalayaDests.any((d) => d.id == 'dawki'), isTrue);
      expect(meghalayaDests.any((d) => d.id == 'mawlynnong'), isTrue);

      // 2. Search by tag 'Tiger Safari'
      provider.setSearchQuery('Tiger');
      final tigerDests = provider.filteredDestinations;
      expect(tigerDests.any((d) => d.id == 'ranthambore'), isTrue);
      expect(tigerDests.any((d) => d.id == 'jim_corbett'), isTrue);
      expect(tigerDests.any((d) => d.id == 'bandhavgarh'), isTrue);
      expect(tigerDests.any((d) => d.id == 'tadoba'), isTrue);

      // 3. Search by city 'Amritsar'
      provider.setSearchQuery('Amritsar');
      expect(provider.filteredDestinations.length, equals(1));
      expect(provider.filteredDestinations.first.name, equals('Amritsar'));
    });
  });
}
