class AppConstants {
  static const String appName = 'Travel Explorer';
  static const String appTagline =
      'Discover India\'s most inspiring destinations';

  // Categories
  static const String categoryAll = 'All';
  static const String categoryBeaches = 'Beaches';
  static const String categoryMountains = 'Mountains';
  static const String categoryHeritage = 'Heritage';
  static const String categoryAdventure = 'Adventure';
  static const String categorySpiritual = 'Spiritual';

  static const List<String> categories = [
    categoryAll,
    categoryBeaches,
    categoryMountains,
    categoryHeritage,
    categoryAdventure,
    categorySpiritual,
  ];

  /// Normalizes category strings, handling singular/plural and case variations.
  static String normalizeCategory(String? category) {
    if (category == null) return categoryAll;
    final lower = category.trim().toLowerCase();
    if (lower.isEmpty || lower == 'all') return categoryAll;
    if (lower == 'beach' || lower == 'beaches') return categoryBeaches;
    if (lower == 'mountain' ||
        lower == 'mountains' ||
        lower == 'hill' ||
        lower == 'hills' ||
        lower == 'hill station' ||
        lower == 'hill stations') {
      return categoryMountains;
    }
    if (lower == 'heritage' ||
        lower == 'historical' ||
        lower == 'history' ||
        lower == 'culture') {
      return categoryHeritage;
    }
    if (lower == 'adventure' || lower == 'adventures' || lower == 'trekking') {
      return categoryAdventure;
    }
    if (lower == 'spiritual' ||
        lower == 'spirituality' ||
        lower == 'pilgrimage' ||
        lower == 'religious' ||
        lower == 'temple' ||
        lower == 'temples' ||
        lower == 'holy') {
      return categorySpiritual;
    }
    return category;
  }

  /// Checks if a destination category matches a filter category.
  /// Supports comma-separated multi-category strings (e.g. "Heritage, Spiritual").
  static bool matchesCategory(
    String destinationCategory,
    String filterCategory,
  ) {
    final normFilter = normalizeCategory(filterCategory);
    if (normFilter == categoryAll) return true;
    final parts = destinationCategory
        .split(',')
        .map((p) => normalizeCategory(p.trim()))
        .toList();
    return parts.contains(normFilter);
  }

  // Expense Categories
  static const String expenseAccommodation = 'Accommodation';
  static const String expenseFood = 'Food';
  static const String expenseTransport = 'Transport';
  static const String expenseActivities = 'Activities';
  static const String expenseShopping = 'Shopping';
  static const String expenseMiscellaneous = 'Miscellaneous';

  static const List<String> expenseCategories = [
    expenseAccommodation,
    expenseFood,
    expenseTransport,
    expenseActivities,
    expenseShopping,
    expenseMiscellaneous,
  ];

  // Sort Options
  static const String sortPopularity = 'Popularity';
  static const String sortRating = 'Rating: High to Low';
  static const String sortName = 'Name (A to Z)';
  static const String sortBudgetLowHigh = 'Budget: Low to High';
  static const String sortBudgetHighLow = 'Budget: High to Low';

  static const List<String> sortOptions = [
    sortPopularity,
    sortRating,
    sortName,
    sortBudgetLowHigh,
    sortBudgetHighLow,
  ];

  // Travel Styles / Interests
  static const List<String> travelInterests = [
    'Nature & Wildlife',
    'Beaches & Coastal',
    'Mountains & Trekking',
    'Heritage & History',
    'Adventure & Sports',
    'Spirituality & Temples',
    'Food & Culinary',
    'Relaxation & Wellness',
  ];

  // Seasons
  static const List<String> travelSeasons = [
    'Winter (Oct - Mar)',
    'Summer (Apr - Jun)',
    'Monsoon (Jul - Sep)',
    'Year-round',
  ];
}
