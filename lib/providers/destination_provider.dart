import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../data/local/local_storage_service.dart';
import '../models/destination.dart';
import '../models/user_review.dart';

class DestinationProvider extends ChangeNotifier {
  final LocalStorageService _storage;
  List<Destination> _allDestinations = [];

  String _searchQuery = '';
  String _selectedCategory = AppConstants.categoryAll;
  String _selectedSort = AppConstants.sortPopularity;
  double? _maxBudgetFilter;
  int? _maxDurationFilter;

  DestinationProvider(this._storage) {
    _loadDestinations();
  }

  void _loadDestinations() {
    _allDestinations = _storage.getSeedDestinations();
    notifyListeners();
  }

  List<Destination> get allDestinations => _allDestinations;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedSort => _selectedSort;
  double? get maxBudgetFilter => _maxBudgetFilter;
  int? get maxDurationFilter => _maxDurationFilter;

  // Filtered & Sorted destinations list
  List<Destination> get filteredDestinations {
    return _allDestinations.where((dest) {
      // Category filter
      if (!dest.matchesCategory(_selectedCategory)) {
        return false;
      }

      // Budget filter
      if (_maxBudgetFilter != null && _maxBudgetFilter! > 0) {
        if (dest.estimatedDailyCost > _maxBudgetFilter!) {
          return false;
        }
      }

      // Duration filter
      if (_maxDurationFilter != null && _maxDurationFilter! > 0) {
        if (dest.suggestedDurationDays > _maxDurationFilter!) {
          return false;
        }
      }

      // Search query (case-insensitive across name, city, state, tags, description)
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.trim().toLowerCase();
        final matchName = dest.name.toLowerCase().contains(query);
        final matchCity = dest.city.toLowerCase().contains(query);
        final matchState = dest.state.toLowerCase().contains(query);
        final matchCategory = dest.category.toLowerCase().contains(query);
        final matchTags = dest.tags.any((t) => t.toLowerCase().contains(query));
        if (!matchName &&
            !matchCity &&
            !matchState &&
            !matchCategory &&
            !matchTags) {
          return false;
        }
      }

      return true;
    }).toList()..sort((a, b) {
      switch (_selectedSort) {
        case AppConstants.sortName:
          return a.name.compareTo(b.name);
        case AppConstants.sortRating:
          final r = b.rating.compareTo(a.rating);
          if (r != 0) return r;
          return b.reviewCount.compareTo(a.reviewCount);
        case AppConstants.sortBudgetLowHigh:
          return a.estimatedDailyCost.compareTo(b.estimatedDailyCost);
        case AppConstants.sortBudgetHighLow:
          return b.estimatedDailyCost.compareTo(a.estimatedDailyCost);
        case AppConstants.sortPopularity:
        default:
          final r = b.rating.compareTo(a.rating);
          if (r != 0) return r;
          return b.reviewCount.compareTo(a.reviewCount);
      }
    });
  }

  // Pre-filtered discovery sections
  List<Destination> get popularDestinations =>
      _allDestinations.where((d) => d.isPopular).toList();

  List<Destination> get trendingDestinations =>
      _allDestinations.where((d) => d.isTrending).toList();

  List<Destination> get weekendGetaways =>
      _allDestinations.where((d) => d.isWeekendGetaway).toList();

  List<Destination> getDestinationsByCategory(String category) {
    if (AppConstants.normalizeCategory(category) == AppConstants.categoryAll) {
      return _allDestinations;
    }
    return _allDestinations.where((d) => d.matchesCategory(category)).toList();
  }

  List<String> get recentlyViewedIds => _storage.getRecentlyViewedIds();

  List<Destination> get recentlyViewedDestinations {
    final recentIds = _storage.getRecentlyViewedIds();
    final List<Destination> result = [];
    for (final id in recentIds) {
      final match = findById(id);
      if (match != null) result.add(match);
    }
    return result;
  }

  Destination? findById(String id) {
    try {
      return _allDestinations.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  void markAsViewed(String destinationId) {
    _storage.addRecentlyViewed(destinationId);
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSelectedSort(String sort) {
    _selectedSort = sort;
    notifyListeners();
  }

  void setBudgetFilter(double? maxBudget) {
    _maxBudgetFilter = maxBudget;
    notifyListeners();
  }

  void setDurationFilter(int? maxDuration) {
    _maxDurationFilter = maxDuration;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedCategory = AppConstants.categoryAll;
    _selectedSort = AppConstants.sortPopularity;
    _maxBudgetFilter = null;
    _maxDurationFilter = null;
    notifyListeners();
  }

  // --- REVIEWS & RATINGS ---
  List<UserReview> getReviewsForDestination(String destinationId) {
    return _storage.getReviewsForDestination(destinationId);
  }

  UserReview? getUserReview(String destinationId, String userId) {
    return _storage.getUserReviewForDestination(destinationId, userId);
  }

  Future<void> submitRating({
    required String destinationId,
    required double rating,
    String comment = '',
    required String userId,
    required String userName,
  }) async {
    final review = UserReview(
      id: 'rev_${destinationId}_${DateTime.now().millisecondsSinceEpoch}',
      destinationId: destinationId,
      userId: userId,
      userName: userName,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );

    await _storage.saveUserReview(review);
    notifyListeners();
  }
}
