import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import 'attraction.dart';

class Destination {
  final String id;
  final String name;
  final String city;
  final String state;
  final String country;
  final String category; // Primary category: Beaches, Mountains, Heritage, Adventure, Spiritual
  final List<String> categories; // Additional relevant categories
  final String description;
  final String imageUrl;
  final List<String> galleryUrls;
  final String bestTimeToVisit;
  final List<String> seasons;
  final double estimatedDailyCost; // in INR
  final int suggestedDurationDays;
  final double latitude;
  final double longitude;
  final double rating;
  final int reviewCount;
  final List<String> tags;
  final List<String> highlights;
  final List<String> localFoods;
  final List<String> travelTips;
  final List<Attraction> attractions;
  final bool isPopular;
  final bool isTrending;
  final bool isWeekendGetaway;

  const Destination({
    required this.id,
    required this.name,
    required this.city,
    required this.state,
    this.country = 'India',
    required this.category,
    this.categories = const [],
    required this.description,
    required this.imageUrl,
    required this.galleryUrls,
    required this.bestTimeToVisit,
    required this.seasons,
    required this.estimatedDailyCost,
    required this.suggestedDurationDays,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.reviewCount,
    required this.tags,
    required this.highlights,
    required this.localFoods,
    required this.travelTips,
    required this.attractions,
    this.isPopular = false,
    this.isTrending = false,
    this.isWeekendGetaway = false,
  });

  /// All categories associated with this destination.
  List<String> get allCategories {
    final list = <String>[];
    for (final c in category.split(',')) {
      final trimmed = c.trim();
      if (trimmed.isNotEmpty && !list.contains(trimmed)) {
        list.add(trimmed);
      }
    }
    for (final c in categories) {
      final trimmed = c.trim();
      if (trimmed.isNotEmpty && !list.contains(trimmed)) {
        list.add(trimmed);
      }
    }
    return list;
  }

  /// Checks if this destination belongs to the specified category filter.
  bool matchesCategory(String filterCategory) {
    final normFilter = AppConstants.normalizeCategory(filterCategory);
    if (normFilter == AppConstants.categoryAll) return true;
    for (final cat in allCategories) {
      if (AppConstants.normalizeCategory(cat) == normFilter) return true;
    }
    return false;
  }

  CategoryPalette get palette => CategoryPalette.forCategory(category);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'city': city,
    'state': state,
    'country': country,
    'category': category,
    'categories': allCategories,
    'description': description,
    'imageUrl': imageUrl,
    'galleryUrls': galleryUrls,
    'bestTimeToVisit': bestTimeToVisit,
    'seasons': seasons,
    'estimatedDailyCost': estimatedDailyCost,
    'suggestedDurationDays': suggestedDurationDays,
    'latitude': latitude,
    'longitude': longitude,
    'rating': rating,
    'reviewCount': reviewCount,
    'tags': tags,
    'highlights': highlights,
    'localFoods': localFoods,
    'travelTips': travelTips,
    'attractions': attractions.map((a) => a.toJson()).toList(),
    'isPopular': isPopular,
    'isTrending': isTrending,
    'isWeekendGetaway': isWeekendGetaway,
  };

  factory Destination.fromJson(Map<String, dynamic> json) => Destination(
    id: json['id'] as String,
    name: json['name'] as String,
    city: json['city'] as String,
    state: json['state'] as String,
    country: json['country'] as String? ?? 'India',
    category: json['category'] as String,
    categories: List<String>.from(json['categories'] ?? []),
    description: json['description'] as String,
    imageUrl: json['imageUrl'] as String,
    galleryUrls: List<String>.from(json['galleryUrls'] ?? []),
    bestTimeToVisit: json['bestTimeToVisit'] as String,
    seasons: List<String>.from(json['seasons'] ?? []),
    estimatedDailyCost: (json['estimatedDailyCost'] as num).toDouble(),
    suggestedDurationDays: (json['suggestedDurationDays'] as num).toInt(),
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    rating: (json['rating'] as num).toDouble(),
    reviewCount: (json['reviewCount'] as num).toInt(),
    tags: List<String>.from(json['tags'] ?? []),
    highlights: List<String>.from(json['highlights'] ?? []),
    localFoods: List<String>.from(json['localFoods'] ?? []),
    travelTips: List<String>.from(json['travelTips'] ?? []),
    attractions: (json['attractions'] as List? ?? [])
        .map((a) => Attraction.fromJson(Map<String, dynamic>.from(a)))
        .toList(),
    isPopular: json['isPopular'] as bool? ?? false,
    isTrending: json['isTrending'] as bool? ?? false,
    isWeekendGetaway: json['isWeekendGetaway'] as bool? ?? false,
  );
}
