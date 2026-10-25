import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:travel_explorer/data/local/destination_seed_data.dart';
import 'package:travel_explorer/data/local/shopping_spots_data.dart';
import 'package:travel_explorer/models/shopping_spot.dart';

void main() {
  group('Comprehensive Destination Image Audit Tests', () {
    final destinations = DestinationSeedData.destinations;

    test('Catalogue has exactly 126 preserved destinations', () {
      expect(destinations.length, 126);
    });

    test(
      'Zero duplicate imageUrls across the entire 126-destination catalogue',
      () {
        final urlSet = <String>{};
        final duplicates = <String, List<String>>{};

        for (final d in destinations) {
          if (urlSet.contains(d.imageUrl)) {
            duplicates
                .putIfAbsent(d.imageUrl, () => [])
                .add('${d.name} (${d.id})');
          } else {
            urlSet.add(d.imageUrl);
          }
        }

        expect(
          duplicates.isEmpty,
          isTrue,
          reason: 'Found duplicate image URLs: $duplicates',
        );
        expect(urlSet.length, 126);
      },
    );

    test(
      'Taj Mahal is NOT assigned to non-Agra destinations or attractions',
      () {
        const tajMahalUrlFragment = 'photo-1548013146-72479768bada';
        final offendingDestinations = destinations
            .where((d) {
              if (d.id == 'agra') return false;
              final hasInImage = d.imageUrl.contains(tajMahalUrlFragment);
              final hasInGallery = d.galleryUrls.any(
                (u) => u.contains(tajMahalUrlFragment),
              );
              final hasInAttr = d.attractions.any(
                (a) => a.imageUrl.contains(tajMahalUrlFragment),
              );
              return hasInImage || hasInGallery || hasInAttr;
            })
            .map((d) => d.id)
            .toList();

        expect(offendingDestinations, isEmpty);
      },
    );

    test(
      'India Gate is NOT assigned to non-Delhi destinations or attractions',
      () {
        const indiaGateUrlFragment = 'photo-1587474260584-136574528ed5';
        final offendingDestinations = destinations
            .where((d) {
              if (d.id == 'delhi') return false;
              final hasInImage = d.imageUrl.contains(indiaGateUrlFragment);
              final hasInGallery = d.galleryUrls.any(
                (u) => u.contains(indiaGateUrlFragment),
              );
              final hasInAttr = d.attractions.any(
                (a) => a.imageUrl.contains(indiaGateUrlFragment),
              );
              return hasInImage || hasInGallery || hasInAttr;
            })
            .map((d) => d.id)
            .toList();

        expect(offendingDestinations, isEmpty);
      },
    );

    test(
      'Bagalkot (Badami) has cave temple image, not Jaipur or Taj Mahal',
      () {
        final badami = destinations.firstWhere((d) => d.id == 'badami');
        expect(
          badami.imageUrl.contains('photo-1599661046289-e31897846e41'),
          isFalse,
        );
        expect(
          badami.imageUrl.contains('photo-1548013146-72479768bada'),
          isFalse,
        );
        for (final attr in badami.attractions) {
          expect(
            attr.imageUrl.contains('photo-1548013146-72479768bada'),
            isFalse,
          );
        }
      },
    );

    test(
      'Kaziranga has authentic rhinoceros / grassland image, not generic tiger',
      () {
        final kaziranga = destinations.firstWhere((d) => d.id == 'kaziranga');
        const tigerPhotoFragment = 'photo-1561731216-c3a4d99437d5';
        expect(kaziranga.imageUrl.contains(tigerPhotoFragment), isFalse);
      },
    );

    test('Mountains image pairs (Srinagar & Nainital) have distinct authentic photos', () {
      final srinagar = destinations.firstWhere((d) => d.id == 'srinagar');
      final nainital = destinations.firstWhere((d) => d.id == 'nainital');
      expect(srinagar.imageUrl, isNot(equals(nainital.imageUrl)));
    });

    test('Adventure waterfalls (Athirappilly, Cherrapunji, Chitrakote) have distinct images', () {
      final athirappilly = destinations.firstWhere(
        (d) => d.id == 'athirappilly',
      );
      final cherrapunji = destinations.firstWhere((d) => d.id == 'cherrapunji');
      final chitrakote = destinations.firstWhere(
        (d) => d.id == 'chitrakote_falls',
      );

      expect(athirappilly.imageUrl, isNot(equals(cherrapunji.imageUrl)));
      expect(athirappilly.imageUrl, isNot(equals(chitrakote.imageUrl)));
      expect(cherrapunji.imageUrl, isNot(equals(chitrakote.imageUrl)));
    });

    test(
      'Bundled local assets are properly assigned to verified destinations',
      () {
        final jodhpur = destinations.firstWhere((d) => d.id == 'jodhpur');
        final bikaner = destinations.firstWhere((d) => d.id == 'bikaner');
        final chittorgarh = destinations.firstWhere(
          (d) => d.id == 'chittorgarh',
        );
        final somnath = destinations.firstWhere((d) => d.id == 'somnath');
        final dwarka = destinations.firstWhere((d) => d.id == 'dwarka');

        expect(jodhpur.imageUrl, 'assets/images/destinations/jodhpur.jpg');
        expect(bikaner.imageUrl, 'assets/images/destinations/bikaner.jpg');
        expect(
          chittorgarh.imageUrl,
          'assets/images/destinations/chittorgarh.jpg',
        );
        expect(somnath.imageUrl, 'assets/images/destinations/somnath.jpg');
        expect(dwarka.imageUrl, 'assets/images/destinations/dwarka.jpg');
      },
    );

    test('Andaman has Radhanagar beach image', () {
      final andaman = destinations.firstWhere((d) => d.id == 'andaman');
      expect(andaman.imageUrl, 'assets/images/destinations/andaman.jpg');
    });
  });

  group('Shopping Spots and Regional Itinerary Tests', () {
    test('ShoppingSpotsData has rich catalogue of authentic spots', () {
      expect(ShoppingSpotsData.allSpots.isNotEmpty, isTrue);
      expect(ShoppingSpotsData.allSpots.length, greaterThanOrEqualTo(20));

      for (final spot in ShoppingSpotsData.allSpots) {
        expect(spot.id, isNotEmpty);
        expect(spot.destinationId, isNotEmpty);
        expect(spot.name, isNotEmpty);
        expect(spot.locality, isNotEmpty);
        expect(spot.knownFor, isNotEmpty);
        expect(spot.specialities.isNotEmpty, isTrue);
        expect(spot.latitude, isNonZero);
        expect(spot.longitude, isNonZero);
        expect(spot.openingHours, isNotEmpty);
      }
    });

    test('getSpotsForDestination finds spots case-insensitively', () {
      final jaipurSpots = ShoppingSpotsData.getSpotsForDestination('jaipur');
      expect(jaipurSpots.length, greaterThanOrEqualTo(2));
      expect(jaipurSpots.any((s) => s.name.contains('Johari Bazaar')), isTrue);
      expect(jaipurSpots.any((s) => s.name.contains('Bapu Bazaar')), isTrue);

      final upperSpots = ShoppingSpotsData.getSpotsForDestination('JAIPUR');
      expect(upperSpots.length, equals(jaipurSpots.length));
    });

    test('ShoppingSpot serializes to and from JSON correctly', () {
      const spot = ShoppingSpot(
        id: 'test_1',
        destinationId: 'jaipur',
        name: 'Johari Bazaar',
        locality: 'Pink City',
        knownFor: 'Kundan and Meenakari jewellery',
        specialities: ['Kundan', 'Gems'],
        latitude: 26.9205,
        longitude: 75.8276,
        openingHours: '10:00 AM - 8:00 PM',
        bestTimeToVisit: 'Afternoon',
        tips: 'Ask for hallmark certificates',
      );

      final json = spot.toJson();
      final revived = ShoppingSpot.fromJson(json);

      expect(revived.id, spot.id);
      expect(revived.destinationId, spot.destinationId);
      expect(revived.name, spot.name);
      expect(revived.locality, spot.locality);
      expect(revived.knownFor, spot.knownFor);
      expect(revived.specialities, spot.specialities);
      expect(revived.latitude, spot.latitude);
      expect(revived.longitude, spot.longitude);
      expect(revived.openingHours, spot.openingHours);
      expect(revived.bestTimeToVisit, spot.bestTimeToVisit);
      expect(revived.tips, spot.tips);
    });

    test('Haversine distance calculation correctly ranks regional circuit destinations', () {
      double haversineDistanceKm(
        double lat1,
        double lon1,
        double lat2,
        double lon2,
      ) {
        const p = 0.017453292519943295;
        final a =
            0.5 -
            math.cos((lat2 - lat1) * p) / 2 +
            math.cos(lat1 * p) *
                math.cos(lat2 * p) *
                (1 - math.cos((lon2 - lon1) * p)) /
                2;
        return 12742 * math.asin(math.sqrt(a));
      }

      final destinations = DestinationSeedData.destinations;
      final jaipur = destinations.firstWhere((d) => d.id == 'jaipur');

      // Rank other destinations from Jaipur
      final distances = destinations
          .where((d) => d.id != jaipur.id)
          .map(
            (d) => (
              destination: d,
              dist: haversineDistanceKm(
                jaipur.latitude,
                jaipur.longitude,
                d.latitude,
                d.longitude,
              ),
            ),
          )
          .toList();

      distances.sort((a, b) => a.dist.compareTo(b.dist));

      // Nearest to Jaipur in Rajasthan should be Pushkar, Ranthambore, Bharatpur, etc. (< 250 km)
      final nearestNames = distances
          .take(5)
          .map((x) => x.destination.id)
          .toList();
      expect(
        nearestNames.any(
          (id) => [
            'pushkar',
            'ranthambore',
            'bharatpur',
            'delhi',
            'agra',
          ].contains(id),
        ),
        isTrue,
      );
    });
    test(
      'Target spiritual and heritage destinations have unique verified images',
      () {
        final destinations = DestinationSeedData.destinations;
        const targetIds = [
          'tirupati',
          'ayodhya',
          'varanasi',
          'madurai',
          'rameshwaram',
          'murudeshwar',
          'guwahati',
          'bhubaneswar',
          'pushkar',
          'prayagraj',
        ];

        final targetImages = <String>{};
        for (final id in targetIds) {
          final dest = destinations.firstWhere((d) => d.id == id);
          expect(dest.imageUrl.isNotEmpty, isTrue);
          expect(
            targetImages.contains(dest.imageUrl),
            isFalse,
            reason: 'Duplicate image found for target destination: $id',
          );
          targetImages.add(dest.imageUrl);
        }
        expect(targetImages.length, 10);
      },
    );
  });
}
