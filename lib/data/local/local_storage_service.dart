import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/destination.dart';
import '../../models/expense.dart';
import '../../models/itinerary_activity.dart';
import '../../models/trip.dart';
import '../../models/user_profile.dart';
import '../../models/user_review.dart';
import 'destination_seed_data.dart';

class LocalStorageService {
  static const String _keyWishlist = 'travel_wishlist_ids';
  static const String _keyRecentViews = 'travel_recent_view_ids';
  static const String _keyTrips = 'travel_trips_data';
  static const String _keyActivities = 'travel_activities_data';
  static const String _keyExpenses = 'travel_expenses_data';
  static const String _keyUserProfile = 'travel_user_profile';
  static const String _keyThemeMode = 'travel_theme_mode';
  static const String _keyUserReviews = 'travel_destination_user_reviews';
  static const String _keySeedInitialized = 'travel_seed_initialized_v1';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    final service = LocalStorageService(prefs);
    await service._initSeedIfNeeded();
    return service;
  }

  Future<void> _initSeedIfNeeded() async {
    final initialized = _prefs.getBool(_keySeedInitialized) ?? false;
    if (!initialized) {
      // Default wishlist: Goa & Manali
      await saveWishlistIds({'goa', 'manali'});

      // Default sample trip: Goa Beach Escapade
      final sampleTrip = Trip(
        id: 'trip_goa_sample',
        title: 'Goa Coastal Getaway',
        destinationId: 'goa',
        destinationName: 'Goa, India',
        destinationImage: 'assets/images/destinations/goa.jpg',
        startDate: DateTime.now().add(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 11)),
        numberOfTravelers: 2,
        plannedBudget: 28000.0,
        travelStyle: 'Leisure',
        notes: 'Explore South Goa beaches, relax at beach shacks, and visit Old Goa churches.',
        createdAt: DateTime.now(),
      );
      await saveTrips([sampleTrip]);

      // Sample activities
      final sampleActivities = [
        ItineraryActivity(
          id: 'act_1',
          tripId: 'trip_goa_sample',
          dayNumber: 1,
          date: DateTime.now().add(const Duration(days: 7)),
          title: 'Arrival & Sunset at Palolem Beach',
          locationName: 'Palolem Beach, South Goa',
          time: '04:30 PM',
          notes: 'Check-in to resort, stroll along the shore, and dinner at Dropadi restaurant.',
          isCompleted: false,
          latitude: 15.0100,
          longitude: 74.0231,
        ),
        ItineraryActivity(
          id: 'act_2',
          tripId: 'trip_goa_sample',
          dayNumber: 2,
          date: DateTime.now().add(const Duration(days: 8)),
          title: 'Heritage Tour: Basilica of Bom Jesus',
          locationName: 'Old Goa',
          time: '10:00 AM',
          notes:
              'Explore UNESCO heritage churches and Portuguese art galleries.',
          isCompleted: false,
          latitude: 15.5009,
          longitude: 73.9116,
        ),
        ItineraryActivity(
          id: 'act_3',
          tripId: 'trip_goa_sample',
          dayNumber: 3,
          date: DateTime.now().add(const Duration(days: 9)),
          title: 'Aguada Fort Sunset Walk',
          locationName: 'Sinquerim, Candolim',
          time: '05:00 PM',
          notes: 'Lighthouse photography and sea views.',
          isCompleted: false,
          latitude: 15.4923,
          longitude: 73.7737,
        ),
      ];
      await saveActivities(sampleActivities);

      // Sample expenses
      final sampleExpenses = [
        Expense(
          id: 'exp_1',
          tripId: 'trip_goa_sample',
          title: 'Boutique Beach Resort (3 nights)',
          amount: 12000.0,
          category: 'Accommodation',
          date: DateTime.now(),
          notes: 'Pre-booked beach resort',
        ),
        Expense(
          id: 'exp_2',
          tripId: 'trip_goa_sample',
          title: 'Flight tickets advance',
          amount: 8500.0,
          category: 'Transport',
          date: DateTime.now(),
          notes: 'Round-trip airfare',
        ),
      ];
      await saveExpenses(sampleExpenses);

      // Default guest profile
      await saveUserProfile(UserProfile.guest());

      await _prefs.setBool(_keySeedInitialized, true);
    }
  }

  // --- WISHLIST ---
  Set<String> getWishlistIds() {
    final list = _prefs.getStringList(_keyWishlist) ?? [];
    return list.toSet();
  }

  Future<void> saveWishlistIds(Set<String> ids) async {
    await _prefs.setStringList(_keyWishlist, ids.toList());
  }

  // --- RECENTLY VIEWED ---
  List<String> getRecentlyViewedIds() {
    return _prefs.getStringList(_keyRecentViews) ?? [];
  }

  Future<void> addRecentlyViewed(String destinationId) async {
    final list = getRecentlyViewedIds();
    list.remove(destinationId);
    list.insert(0, destinationId);
    if (list.length > 10) list.removeLast();
    await _prefs.setStringList(_keyRecentViews, list);
  }

  // --- TRIPS ---
  List<Trip> getTrips() {
    final raw = _prefs.getString(_keyTrips);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list
          .map((item) => Trip.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTrips(List<Trip> trips) async {
    final raw = jsonEncode(trips.map((t) => t.toJson()).toList());
    await _prefs.setString(_keyTrips, raw);
  }

  // --- ITINERARY ACTIVITIES ---
  List<ItineraryActivity> getActivities(String tripId) {
    final raw = _prefs.getString(_keyActivities);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list
          .map(
            (item) =>
                ItineraryActivity.fromJson(Map<String, dynamic>.from(item)),
          )
          .where((act) => act.tripId == tripId)
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<ItineraryActivity> getAllActivities() {
    final raw = _prefs.getString(_keyActivities);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list
          .map(
            (item) =>
                ItineraryActivity.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveActivities(List<ItineraryActivity> activities) async {
    final raw = jsonEncode(activities.map((a) => a.toJson()).toList());
    await _prefs.setString(_keyActivities, raw);
  }

  // --- EXPENSES ---
  List<Expense> getExpenses(String tripId) {
    final raw = _prefs.getString(_keyExpenses);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list
          .map((item) => Expense.fromJson(Map<String, dynamic>.from(item)))
          .where((e) => e.tripId == tripId)
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<Expense> getAllExpenses() {
    final raw = _prefs.getString(_keyExpenses);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list
          .map((item) => Expense.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveExpenses(List<Expense> expenses) async {
    final raw = jsonEncode(expenses.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyExpenses, raw);
  }

  // --- USER PROFILE ---
  UserProfile? getUserProfile() {
    final raw = _prefs.getString(_keyUserProfile);
    if (raw == null || raw.isEmpty) return null;
    try {
      return UserProfile.fromJson(Map<String, dynamic>.from(jsonDecode(raw)));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUserProfile(UserProfile? profile) async {
    if (profile == null) {
      await _prefs.remove(_keyUserProfile);
    } else {
      await _prefs.setString(_keyUserProfile, jsonEncode(profile.toJson()));
    }
  }

  // --- THEME ---
  ThemeMode getThemeMode() {
    final mode = _prefs.getString(_keyThemeMode);
    if (mode == 'dark') return ThemeMode.dark;
    if (mode == 'light') return ThemeMode.light;
    return ThemeMode.light; // light theme default
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    await _prefs.setString(
      _keyThemeMode,
      mode == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  // Helper for seed destinations
  List<Destination> getSeedDestinations() {
    return DestinationSeedData.destinations;
  }

  // --- USER REVIEWS & RATINGS ---
  List<UserReview> getAllUserReviews() {
    final raw = _prefs.getString(_keyUserReviews);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list
          .map((item) => UserReview.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<UserReview> getReviewsForDestination(String destinationId) {
    return getAllUserReviews()
        .where(
          (r) => r.destinationId.toLowerCase() == destinationId.toLowerCase(),
        )
        .toList();
  }

  UserReview? getUserReviewForDestination(String destinationId, String userId) {
    final list = getReviewsForDestination(destinationId);
    try {
      return list.firstWhere((r) => r.userId == userId);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUserReview(UserReview review) async {
    final all = getAllUserReviews();
    // Replace if user already reviewed this destination, else insert at top
    all.removeWhere(
      (r) =>
          r.destinationId.toLowerCase() == review.destinationId.toLowerCase() &&
          r.userId == review.userId,
    );
    all.insert(0, review);
    final raw = jsonEncode(all.map((r) => r.toJson()).toList());
    await _prefs.setString(_keyUserReviews, raw);
  }
}
