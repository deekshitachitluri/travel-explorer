/// Preferences used exclusively on the Home Screen for personalized recommendations.
///
/// These preferences are intentionally separate from the Explore catalogue filters.
class HomePreferences {
  /// Travel vibes (e.g. Peaceful & Relaxing, Adventure, Nature & Wildlife, etc.)
  final List<String> travelVibes;

  /// Preferred scenery (e.g. Beaches, Mountains, Forests, Lakes, Historic Cities)
  final List<String> preferredScenery;

  /// Budget category preference: 'Any', 'Budget-friendly' (<= 2500), 'Moderate' (2500-4500), 'Flexible' (> 4500)
  final String budgetPreference;

  /// Optional custom maximum daily estimated budget
  final double? customMaxBudget;

  /// Trip duration preference: 'Any', 'Day trip' (1 day), 'Weekend' (2-3 days), '4-7 days', 'Longer vacation' (8+ days)
  final String tripDuration;

  /// Recommendation priority: 'Matching interests', 'Similar to wishlist', 'Popular destinations', 'New places'
  final String recommendationPriority;

  /// Preferred travel seasons: 'All seasons', 'Spring', 'Summer', 'Monsoon', 'Autumn', 'Winter'
  final List<String> preferredSeasons;

  const HomePreferences({
    this.travelVibes = const [],
    this.preferredScenery = const [],
    this.budgetPreference = 'Any',
    this.customMaxBudget,
    this.tripDuration = 'Any',
    this.recommendationPriority = 'Matching interests',
    this.preferredSeasons = const [],
  });

  /// Returns true if any personalized preference filter is active
  bool get isActive =>
      travelVibes.isNotEmpty ||
      preferredScenery.isNotEmpty ||
      budgetPreference != 'Any' ||
      customMaxBudget != null ||
      tripDuration != 'Any' ||
      recommendationPriority != 'Matching interests' ||
      (preferredSeasons.isNotEmpty && !preferredSeasons.contains('All seasons'));

  /// Total count of active preference criteria
  int get activeFiltersCount {
    int count = 0;
    count += travelVibes.length;
    count += preferredScenery.length;
    if (budgetPreference != 'Any' || customMaxBudget != null) count++;
    if (tripDuration != 'Any') count++;
    if (recommendationPriority != 'Matching interests') count++;
    if (preferredSeasons.isNotEmpty && !preferredSeasons.contains('All seasons')) {
      count += preferredSeasons.length;
    }
    return count;
  }

  HomePreferences copyWith({
    List<String>? travelVibes,
    List<String>? preferredScenery,
    String? budgetPreference,
    double? customMaxBudget,
    String? tripDuration,
    String? recommendationPriority,
    List<String>? preferredSeasons,
    bool clearCustomBudget = false,
  }) {
    return HomePreferences(
      travelVibes: travelVibes ?? this.travelVibes,
      preferredScenery: preferredScenery ?? this.preferredScenery,
      budgetPreference: budgetPreference ?? this.budgetPreference,
      customMaxBudget: clearCustomBudget
          ? null
          : (customMaxBudget ?? this.customMaxBudget),
      tripDuration: tripDuration ?? this.tripDuration,
      recommendationPriority:
          recommendationPriority ?? this.recommendationPriority,
      preferredSeasons: preferredSeasons ?? this.preferredSeasons,
    );
  }

  Map<String, dynamic> toJson() => {
    'travelVibes': travelVibes,
    'preferredScenery': preferredScenery,
    'budgetPreference': budgetPreference,
    'customMaxBudget': customMaxBudget,
    'tripDuration': tripDuration,
    'recommendationPriority': recommendationPriority,
    'preferredSeasons': preferredSeasons,
  };

  factory HomePreferences.fromJson(Map<String, dynamic> json) =>
      HomePreferences(
        travelVibes: List<String>.from(json['travelVibes'] ?? []),
        preferredScenery: List<String>.from(json['preferredScenery'] ?? []),
        budgetPreference: json['budgetPreference'] as String? ?? 'Any',
        customMaxBudget: (json['customMaxBudget'] as num?)?.toDouble(),
        tripDuration: json['tripDuration'] as String? ?? 'Any',
        recommendationPriority:
            json['recommendationPriority'] as String? ?? 'Matching interests',
        preferredSeasons: List<String>.from(json['preferredSeasons'] ?? []),
      );

  static const empty = HomePreferences();
}
