import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/local/local_storage_service.dart';
import '../models/expense.dart';
import '../models/itinerary_activity.dart';
import '../models/trip.dart';

class TripProvider extends ChangeNotifier {
  final LocalStorageService _storage;
  final _uuid = const Uuid();

  List<Trip> _trips = [];
  List<ItineraryActivity> _allActivities = [];
  List<Expense> _allExpenses = [];

  TripProvider(this._storage) {
    _loadAll();
  }

  void _loadAll() {
    _trips = _storage.getTrips();
    _allActivities = _storage.getAllActivities();
    _allExpenses = _storage.getAllExpenses();
    notifyListeners();
  }

  // --- TRIPS ---
  List<Trip> get trips => _trips;

  List<Trip> get upcomingTrips =>
      _trips.where((t) => t.isUpcoming).toList()
        ..sort((a, b) => a.startDate.compareTo(b.startDate));

  List<Trip> get ongoingTrips =>
      _trips.where((t) => t.isOngoing).toList()
        ..sort((a, b) => a.startDate.compareTo(b.startDate));

  List<Trip> get pastTrips =>
      _trips.where((t) => t.isPast).toList()
        ..sort((a, b) => b.endDate.compareTo(a.endDate));

  Trip? getTripById(String id) {
    try {
      return _trips.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Trip? get nextUpcomingTrip {
    final upcoming = upcomingTrips;
    if (upcoming.isNotEmpty) return upcoming.first;
    final ongoing = ongoingTrips;
    if (ongoing.isNotEmpty) return ongoing.first;
    return null;
  }

  Future<Trip> createTrip({
    required String title,
    String? destinationId,
    required String destinationName,
    String? destinationImage,
    required DateTime startDate,
    required DateTime endDate,
    int numberOfTravelers = 1,
    required double plannedBudget,
    String travelStyle = 'Leisure',
    String? notes,
  }) async {
    final newTrip = Trip(
      id: _uuid.v4(),
      title: title.trim(),
      destinationId: destinationId,
      destinationName: destinationName.trim(),
      destinationImage: destinationImage,
      startDate: startDate,
      endDate: endDate,
      numberOfTravelers: numberOfTravelers,
      plannedBudget: plannedBudget,
      travelStyle: travelStyle,
      notes: notes?.trim(),
      createdAt: DateTime.now(),
    );

    _trips.insert(0, newTrip);
    await _storage.saveTrips(_trips);
    notifyListeners();
    return newTrip;
  }

  Future<void> updateTrip(Trip updatedTrip) async {
    final index = _trips.indexWhere((t) => t.id == updatedTrip.id);
    if (index != -1) {
      _trips[index] = updatedTrip;
      await _storage.saveTrips(_trips);
      notifyListeners();
    }
  }

  Future<void> deleteTrip(String tripId) async {
    _trips.removeWhere((t) => t.id == tripId);
    _allActivities.removeWhere((a) => a.tripId == tripId);
    _allExpenses.removeWhere((e) => e.tripId == tripId);

    await _storage.saveTrips(_trips);
    await _storage.saveActivities(_allActivities);
    await _storage.saveExpenses(_allExpenses);
    notifyListeners();
  }

  // --- ITINERARY ACTIVITIES ---
  List<ItineraryActivity> getActivitiesForTrip(String tripId) {
    return _allActivities.where((a) => a.tripId == tripId).toList()
      ..sort((a, b) {
        final dayComp = a.dayNumber.compareTo(b.dayNumber);
        if (dayComp != 0) return dayComp;
        return (a.time ?? '').compareTo(b.time ?? '');
      });
  }

  List<ItineraryActivity> getActivitiesForDay(String tripId, int dayNumber) {
    return _allActivities
        .where((a) => a.tripId == tripId && a.dayNumber == dayNumber)
        .toList()
      ..sort((a, b) => (a.time ?? '').compareTo(b.time ?? ''));
  }

  Future<void> addActivity({
    required String tripId,
    required int dayNumber,
    required DateTime date,
    required String title,
    required String locationName,
    String? time,
    String? notes,
    double? latitude,
    double? longitude,
  }) async {
    final newActivity = ItineraryActivity(
      id: _uuid.v4(),
      tripId: tripId,
      dayNumber: dayNumber,
      date: date,
      title: title.trim(),
      locationName: locationName.trim(),
      time: time?.trim(),
      notes: notes?.trim(),
      isCompleted: false,
      latitude: latitude,
      longitude: longitude,
    );

    _allActivities.add(newActivity);
    await _storage.saveActivities(_allActivities);
    notifyListeners();
  }

  Future<void> updateActivity(ItineraryActivity updated) async {
    final index = _allActivities.indexWhere((a) => a.id == updated.id);
    if (index != -1) {
      _allActivities[index] = updated;
      await _storage.saveActivities(_allActivities);
      notifyListeners();
    }
  }

  Future<void> toggleActivityCompleted(String activityId) async {
    final index = _allActivities.indexWhere((a) => a.id == activityId);
    if (index != -1) {
      final item = _allActivities[index];
      _allActivities[index] = item.copyWith(isCompleted: !item.isCompleted);
      await _storage.saveActivities(_allActivities);
      notifyListeners();
    }
  }

  Future<void> deleteActivity(String activityId) async {
    _allActivities.removeWhere((a) => a.id == activityId);
    await _storage.saveActivities(_allActivities);
    notifyListeners();
  }

  // --- EXPENSES & BUDGET TRACKER ---
  List<Expense> getExpensesForTrip(String tripId) {
    return _allExpenses.where((e) => e.tripId == tripId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addExpense({
    required String tripId,
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    String? notes,
  }) async {
    final newExpense = Expense(
      id: _uuid.v4(),
      tripId: tripId,
      title: title.trim(),
      amount: amount,
      category: category,
      date: date,
      notes: notes?.trim(),
    );

    _allExpenses.insert(0, newExpense);
    await _storage.saveExpenses(_allExpenses);
    notifyListeners();
  }

  Future<void> updateExpense(Expense updated) async {
    final index = _allExpenses.indexWhere((e) => e.id == updated.id);
    if (index != -1) {
      _allExpenses[index] = updated;
      await _storage.saveExpenses(_allExpenses);
      notifyListeners();
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    _allExpenses.removeWhere((e) => e.id == expenseId);
    await _storage.saveExpenses(_allExpenses);
    notifyListeners();
  }

  // Budget calculations
  double getTotalSpentForTrip(String tripId) {
    return _allExpenses
        .where((e) => e.tripId == tripId)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double getRemainingBudget(String tripId) {
    final trip = getTripById(tripId);
    if (trip == null) return 0.0;
    return trip.plannedBudget - getTotalSpentForTrip(tripId);
  }

  double getBudgetUsageFraction(String tripId) {
    final trip = getTripById(tripId);
    if (trip == null || trip.plannedBudget <= 0) return 0.0;
    final fraction = getTotalSpentForTrip(tripId) / trip.plannedBudget;
    return fraction.clamp(0.0, 1.0);
  }

  bool isOverBudget(String tripId) {
    final trip = getTripById(tripId);
    if (trip == null) return false;
    return getTotalSpentForTrip(tripId) > trip.plannedBudget;
  }

  Map<String, double> getCategorySpendingForTrip(String tripId) {
    final expenses = _allExpenses.where((e) => e.tripId == tripId);
    final Map<String, double> totals = {};
    for (final exp in expenses) {
      totals[exp.category] = (totals[exp.category] ?? 0.0) + exp.amount;
    }
    return totals;
  }
}
