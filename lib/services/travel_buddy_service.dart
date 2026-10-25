import 'package:flutter/material.dart';

import '../data/local/destination_seed_data.dart';
import '../data/local/shopping_spots_data.dart';
import '../models/destination.dart';
import '../models/trip.dart';

/// Interactive navigation pill action displayed in a Travel Buddy message.
class ChatActionButton {
  final String label;
  final String route;
  final IconData? icon;

  const ChatActionButton({required this.label, required this.route, this.icon});
}

/// A single message in the Travel Buddy conversation.
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<Destination> destinations;
  final List<ChatActionButton> actionButtons;
  final bool isError;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.destinations = const [],
    this.actionButtons = const [],
    this.isError = false,
  });

  ChatMessage copyWith({
    String? text,
    List<Destination>? destinations,
    List<ChatActionButton>? actionButtons,
    bool? isError,
  }) {
    return ChatMessage(
      id: id,
      text: text ?? this.text,
      isUser: isUser,
      timestamp: timestamp,
      destinations: destinations ?? this.destinations,
      actionButtons: actionButtons ?? this.actionButtons,
      isError: isError ?? this.isError,
    );
  }
}

/// Remembers active conversation context across turns.
class ChatContext {
  String? positiveCategory;
  String? negativeCategory;
  double? maxBudget;
  int? maxDuration;
  String? lastVibe;
  String? lastIntent;
  String? lastDestinationId;
  final Set<String> shownDestinationIds = <String>{};

  ChatContext({
    this.positiveCategory,
    this.negativeCategory,
    this.maxBudget,
    this.maxDuration,
    this.lastVibe,
    this.lastIntent,
    this.lastDestinationId,
  });

  void reset() {
    positiveCategory = null;
    negativeCategory = null;
    maxBudget = null;
    maxDuration = null;
    lastVibe = null;
    lastIntent = null;
    lastDestinationId = null;
    shownDestinationIds.clear();
  }

  void resetForNewSearch() {
    shownDestinationIds.clear();
  }
}

/// Service driving the in-app interactive AI travel companion Travel Buddy.
class TravelBuddyService {
  final List<ChatMessage> _messages = [];
  final ChatContext _context = ChatContext();

  static const String welcomeText =
      "Hey, I'm Travel Buddy! 🌍 I can help you discover destinations, plan trips, understand your budget, and find your way around Travel Explorer. Where would you like to go?";

  static const List<String> defaultSuggestedPrompts = [
    'Find peaceful places under ₹5,000',
    'I want mountains, not beaches',
    'Plan a two-day trip',
    'Show me my wishlist',
    'Where can I check my budget?',
    'Help me create a trip',
  ];

  TravelBuddyService() {
    _initWelcome();
  }

  void _initWelcome() {
    _messages.clear();
    _context.reset();
    _messages.add(
      ChatMessage(
        id: 'welcome_msg',
        text: welcomeText,
        isUser: false,
        timestamp: DateTime.now(),
        actionButtons: const [
          ChatActionButton(
            label: 'Explore All Destinations',
            route: '/explore',
            icon: Icons.explore_rounded,
          ),
          ChatActionButton(
            label: 'Open Interactive Map',
            route: '/map',
            icon: Icons.map_rounded,
          ),
        ],
      ),
    );
  }

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  ChatContext get context => _context;

  void clearConversation() {
    _initWelcome();
  }

  /// Processes user text input and yields a structured assistant response.
  Future<ChatMessage> processUserMessage({
    required String userText,
    required List<Destination> allDestinations,
    required List<Destination> wishlistDestinations,
    required List<Trip> trips,
    double totalActualExpenses = 0.0,
  }) async {
    final cleanInput = userText.trim();
    if (cleanInput.isEmpty) {
      return ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: "Please type a destination, budget, or question about Travel Explorer!",
        isUser: false,
        timestamp: DateTime.now(),
      );
    }

    // Record user message
    final userMsg = ChatMessage(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      text: cleanInput,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);

    // Simulated short response generation delay for natural feel
    await Future.delayed(const Duration(milliseconds: 350));

    final reply = _generateReply(
      input: cleanInput,
      allDestinations: allDestinations.isNotEmpty
          ? allDestinations
          : DestinationSeedData.destinations,
      wishlistDestinations: wishlistDestinations,
      trips: trips,
      totalActualExpenses: totalActualExpenses,
    );

    _messages.add(reply);
    return reply;
  }

  ChatMessage _generateReply({
    required String input,
    required List<Destination> allDestinations,
    required List<Destination> wishlistDestinations,
    required List<Trip> trips,
    double totalActualExpenses = 0.0,
  }) {
    final lower = input.toLowerCase();
    final nowId = 'ast_${DateTime.now().millisecondsSinceEpoch}';

    // 1. App Navigation / Help Queries
    if (_isNavigationWishlistQuery(lower)) {
      _context.lastIntent = 'nav_wishlist';
      return ChatMessage(
        id: nowId,
        text: "Your saved destinations are stored in your Wishlist. You can access it anytime from the bottom navigation bar or directly with the button below.",
        isUser: false,
        timestamp: DateTime.now(),
        actionButtons: const [
          ChatActionButton(
            label: 'Go to Wishlist',
            route: '/wishlist',
            icon: Icons.favorite_rounded,
          ),
        ],
      );
    }

    if (_isNavigationTripQuery(lower)) {
      _context.lastIntent = 'nav_trips';
      return ChatMessage(
        id: nowId,
        text: "You can manage trip plans, day-by-day itineraries, and budget tracking under 'My Trips'. You can create new trips or view upcoming itineraries.",
        isUser: false,
        timestamp: DateTime.now(),
        actionButtons: const [
          ChatActionButton(
            label: 'Open My Trips',
            route: '/trips',
            icon: Icons.luggage_rounded,
          ),
          ChatActionButton(
            label: 'Explore Destinations',
            route: '/explore',
            icon: Icons.explore_rounded,
          ),
        ],
      );
    }

    if (_isNavigationBudgetQuery(lower)) {
      _context.lastIntent = 'budget_overview';
      return _buildBudgetOverviewReply(
        nowId: nowId,
        trips: trips,
        totalSpent: totalActualExpenses,
      );
    }

    if (_isNavigationMapQuery(lower)) {
      _context.lastIntent = 'nav_map';
      return ChatMessage(
        id: nowId,
        text: "Travel Explorer includes a full-screen Interactive Map powered by OpenStreetMap. You can browse destination markers, zoom in, and inspect attraction directions.",
        isUser: false,
        timestamp: DateTime.now(),
        actionButtons: const [
          ChatActionButton(
            label: 'Open Interactive Map',
            route: '/map',
            icon: Icons.map_rounded,
          ),
        ],
      );
    }

    if (_isNavigationExploreQuery(lower)) {
      _context.lastIntent = 'nav_explore';
      return ChatMessage(
        id: nowId,
        text: "The Explore screen contains our complete catalogue of destinations across India with sorting, budget sliders, and category filters.",
        isUser: false,
        timestamp: DateTime.now(),
        actionButtons: const [
          ChatActionButton(
            label: 'Explore All Destinations',
            route: '/explore',
            icon: Icons.explore_rounded,
          ),
        ],
      );
    }

    // 2. Wishlist Contents Query
    if (lower.contains('my wishlist') ||
        lower.contains('show wishlist') ||
        lower.contains('saved places') ||
        lower.contains('saved destinations') ||
        lower == 'wishlist') {
      _context.lastIntent = 'show_wishlist';
      if (wishlistDestinations.isEmpty) {
        return ChatMessage(
          id: nowId,
          text: "Your Wishlist is currently empty! Tap the heart icon on any destination card or page to save spots you'd love to visit.",
          isUser: false,
          timestamp: DateTime.now(),
          actionButtons: const [
            ChatActionButton(
              label: 'Explore Destinations',
              route: '/explore',
              icon: Icons.explore_rounded,
            ),
          ],
        );
      } else {
        return ChatMessage(
          id: nowId,
          text:
              "You have saved ${wishlistDestinations.length} destination(s) in your Wishlist. Here they are:",
          isUser: false,
          timestamp: DateTime.now(),
          destinations: wishlistDestinations,
          actionButtons: const [
            ChatActionButton(
              label: 'View Wishlist Screen',
              route: '/wishlist',
              icon: Icons.favorite_rounded,
            ),
          ],
        );
      }
    }

    // 3. Greetings & Identity Queries
    if (lower == 'hi' ||
        lower == 'hello' ||
        lower == 'hey' ||
        lower.startsWith('who are you') ||
        lower.contains('what can you do')) {
      _context.lastIntent = 'greeting';
      return ChatMessage(
        id: nowId,
        text: "I'm your Travel Buddy! 🌍 I can suggest personalized places, respect strict budget limits, help you plan itineraries, and track your travel spending. Try one of the suggested prompts below or ask me about any Indian destination!",
        isUser: false,
        timestamp: DateTime.now(),
        actionButtons: const [
          ChatActionButton(
            label: 'Show Mountains',
            route: '/explore',
            icon: Icons.terrain_rounded,
          ),
          ChatActionButton(
            label: 'Show Beaches',
            route: '/explore',
            icon: Icons.beach_access_rounded,
          ),
        ],
      );
    }

    // 4. Comparison Queries (e.g. "compare Munnar and Coorg", "Jaipur vs Udaipur")
    if (lower.contains('compare ') ||
        lower.contains('comparison') ||
        lower.contains(' vs ') ||
        lower.contains(' versus ')) {
      final compReply = _handleComparisonQuery(
        input: lower,
        nowId: nowId,
        allDestinations: allDestinations,
      );
      if (compReply != null) return compReply;
    }

    // 5. Unknown Real-time / Live Operational Queries
    if (_isUnknownRealtimeQuery(lower)) {
      _context.lastIntent = 'unknown_live';
      final referencedDest = _findReferencedDestination(
        input,
        allDestinations,
      );
      final venue = referencedDest != null
          ? referencedDest.name
          : 'that market or venue';
      return ChatMessage(
        id: nowId,
        text:
            "I don't have verified current opening hours or live operational status for $venue. Please check the official listing or local notice before visiting.",
        isUser: false,
        timestamp: DateTime.now(),
        destinations: const [],
        actionButtons: const [
          ChatActionButton(
            label: 'Open Interactive Map',
            route: '/map',
            icon: Icons.map_rounded,
          ),
        ],
      );
    }

    // 6. Irrelevant / Non-Travel Queries
    if (_isIrrelevantQuery(input, allDestinations)) {
      _context.lastIntent = 'irrelevant';
      final isGeneralGeography =
          lower.contains('capital of') ||
          lower.contains('country of') ||
          lower.contains('president of') ||
          lower.contains('prime minister of');

      final text = isGeneralGeography
          ? "I focus specifically on travel within India—helping you discover destinations, regional food, shopping spots, and itineraries. Would you like suggestions for places in India instead?"
          : "I'm mainly here to help with travel planning, destinations, local food, shopping spots, and itineraries. Want help planning a trip instead?";

      return ChatMessage(
        id: nowId,
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
        destinations: const [],
        actionButtons: const [
          ChatActionButton(
            label: 'Explore Destinations',
            route: '/explore',
            icon: Icons.explore_rounded,
          ),
          ChatActionButton(
            label: 'Interactive Map',
            route: '/map',
            icon: Icons.map_rounded,
          ),
        ],
      );
    }

    // 7. Ambiguous Queries requiring short clarification
    if (_isAmbiguousQuery(lower)) {
      _context.lastIntent = 'ambiguous';
      return ChatMessage(
        id: nowId,
        text: "Could you tell me which destination or region in India you'd like to explore, or your preferred travel vibe (like mountains, beaches, or heritage)?",
        isUser: false,
        timestamp: DateTime.now(),
        destinations: const [],
        actionButtons: const [
          ChatActionButton(
            label: 'Show Mountains',
            route: '/explore',
            icon: Icons.terrain_rounded,
          ),
          ChatActionButton(
            label: 'Show Beaches',
            route: '/explore',
            icon: Icons.beach_access_rounded,
          ),
        ],
      );
    }

    // 8. Local Food & Cuisine Queries
    if (_isLocalFoodQuery(lower)) {
      final foodReply = _handleFoodQuery(
        input: input,
        nowId: nowId,
        allDestinations: allDestinations,
      );
      if (foodReply != null) return foodReply;
    }

    // 9. Shopping Spots Queries
    if (_isShoppingQuery(lower)) {
      final shopReply = _handleShoppingQuery(
        input: input,
        nowId: nowId,
        allDestinations: allDestinations,
      );
      if (shopReply != null) return shopReply;
    }

    // 10. Natural Language Recommendations & Filters
    return _handleRecommendationQuery(
      input: lower,
      nowId: nowId,
      allDestinations: allDestinations,
      trips: trips,
      wishlistDestinations: wishlistDestinations,
    );
  }

  ChatMessage _buildBudgetOverviewReply({
    required String nowId,
    required List<Trip> trips,
    required double totalSpent,
  }) {
    if (trips.isEmpty) {
      return ChatMessage(
        id: nowId,
        text: "You don't have any trips planned yet! When you create a trip in 'My Trips', you can allocate a planned budget and track actual expenses as you travel.",
        isUser: false,
        timestamp: DateTime.now(),
        actionButtons: const [
          ChatActionButton(
            label: 'Create Your First Trip',
            route: '/trips',
            icon: Icons.add_circle_outline_rounded,
          ),
        ],
      );
    }

    double totalPlanned = 0;
    int upcomingCount = 0;

    for (final trip in trips) {
      totalPlanned += trip.plannedBudget;
      if (trip.isUpcoming) upcomingCount++;
    }

    final remaining = totalPlanned - totalSpent;

    final buffer = StringBuffer();
    buffer.writeln("Here is your travel budget summary across all trips:");
    buffer.writeln(
      "• Planned Budget: ₹${totalPlanned.toInt()} (${trips.length} trip(s), $upcomingCount upcoming)",
    );
    buffer.writeln(
      "• Actual Spending: ₹${totalSpent.toInt()} logged in expenses",
    );
    buffer.writeln("• Remaining Balance: ₹${remaining.toInt()}");
    buffer.writeln(
      "\nNote: Destination daily rates in the app are estimates; they are only counted as expenses when you log them in your trip!",
    );

    return ChatMessage(
      id: nowId,
      text: buffer.toString(),
      isUser: false,
      timestamp: DateTime.now(),
      actionButtons: const [
        ChatActionButton(
          label: 'Open My Trips',
          route: '/trips',
          icon: Icons.account_balance_wallet_rounded,
        ),
      ],
    );
  }

  ChatMessage? _handleComparisonQuery({
    required String input,
    required String nowId,
    required List<Destination> allDestinations,
  }) {
    // Look for matching destinations in allDestinations
    final matchedDestinations = <Destination>[];
    for (final dest in allDestinations) {
      final nameLower = dest.name.toLowerCase();
      final idLower = dest.id.toLowerCase();
      final primaryWord = nameLower.split(' ').first;
      if (input.contains(nameLower) ||
          input.contains(idLower) ||
          (primaryWord.length >= 4 && input.contains(primaryWord))) {
        if (!matchedDestinations.any((d) => d.id == dest.id)) {
          matchedDestinations.add(dest);
        }
      }
    }

    if (matchedDestinations.length >= 2) {
      final d1 = matchedDestinations[0];
      final d2 = matchedDestinations[1];

      final buffer = StringBuffer();
      buffer.writeln(
        "Here is a side-by-side comparison between **${d1.name}** and **${d2.name}**:\n",
      );
      buffer.writeln(
        "• **Category & Location:** ${d1.name} (${d1.category}, ${d1.state}) vs ${d2.name} (${d2.category}, ${d2.state}).",
      );
      buffer.writeln(
        "• **Estimated Daily Cost:** ₹${d1.estimatedDailyCost.toInt()}/day (${d1.name}) vs ₹${d2.estimatedDailyCost.toInt()}/day (${d2.name}).",
      );
      buffer.writeln(
        "• **Best Time to Visit:** ${d1.bestTimeToVisit} vs ${d2.bestTimeToVisit}.",
      );
      buffer.writeln(
        "• **Suggested Duration:** ${d1.suggestedDurationDays} days (${d1.name}) vs ${d2.suggestedDurationDays} days (${d2.name}).",
      );
      buffer.writeln(
        "• **Traveler Rating:** ${d1.rating}★ (${d1.reviewCount} reviews) vs ${d2.rating}★ (${d2.reviewCount} reviews).",
      );
      buffer.writeln("• **Key Highlights:**");
      buffer.writeln("  - **${d1.name}:** ${d1.highlights.take(2).join('; ')}");
      buffer.writeln("  - **${d2.name}:** ${d2.highlights.take(2).join('; ')}");
      buffer.writeln(
        "\nYou can view details or add either place to your wishlist below:",
      );

      return ChatMessage(
        id: nowId,
        text: buffer.toString(),
        isUser: false,
        timestamp: DateTime.now(),
        destinations: [d1, d2],
        actionButtons: const [
          ChatActionButton(
            label: 'Open Interactive Map',
            route: '/map',
            icon: Icons.map_rounded,
          ),
          ChatActionButton(
            label: 'Explore Destinations',
            route: '/explore',
            icon: Icons.explore_rounded,
          ),
        ],
      );
    }
    return null;
  }

  bool _isStateInRegion(String state, String region) {
    final s = state.toLowerCase();
    final r = region.toLowerCase();
    if (r.contains('south')) {
      return s.contains('kerala') ||
          s.contains('karnataka') ||
          s.contains('tamil nadu') ||
          s.contains('andhra') ||
          s.contains('telangana') ||
          s.contains('goa') ||
          s.contains('puducherry') ||
          s.contains('lakshadweep');
    } else if (r.contains('northeast') || r.contains('north east')) {
      return s.contains('assam') ||
          s.contains('meghalaya') ||
          s.contains('arunachal') ||
          s.contains('nagaland') ||
          s.contains('manipur') ||
          s.contains('mizoram') ||
          s.contains('tripura') ||
          s.contains('sikkim');
    } else if (r.contains('north')) {
      return s.contains('jammu') ||
          s.contains('kashmir') ||
          s.contains('ladakh') ||
          s.contains('himachal') ||
          s.contains('uttarakhand') ||
          s.contains('punjab') ||
          s.contains('chandigarh') ||
          s.contains('delhi') ||
          s.contains('uttar pradesh') ||
          s.contains('haryana');
    } else if (r.contains('west')) {
      return s.contains('rajasthan') ||
          s.contains('gujarat') ||
          s.contains('maharashtra') ||
          s.contains('goa');
    } else if (r.contains('central')) {
      return s.contains('madhya pradesh') || s.contains('chhattisgarh');
    } else if (r.contains('east')) {
      return s.contains('bengal') ||
          s.contains('odisha') ||
          s.contains('bihar') ||
          s.contains('jharkhand');
    }
    return false;
  }

  ChatMessage _handleRecommendationQuery({
    required String input,
    required String nowId,
    required List<Destination> allDestinations,
    required List<Trip> trips,
    required List<Destination> wishlistDestinations,
  }) {
    // A. Parse Negations (e.g. "not beaches", "no mountains", "not beach")
    String? negativeCat;
    if (input.contains('not beach') ||
        input.contains('no beach') ||
        input.contains('without beach')) {
      negativeCat = 'Beaches';
    } else if (input.contains('not mountain') ||
        input.contains('no mountain') ||
        input.contains('without mountain')) {
      negativeCat = 'Mountains';
    } else if (input.contains('not spiritual') ||
        input.contains('no spiritual') ||
        input.contains('not temple')) {
      negativeCat = 'Spiritual';
    } else if (input.contains('not heritage') ||
        input.contains('no heritage')) {
      negativeCat = 'Heritage';
    }

    // B. Parse Positive Category
    String? positiveCat;
    if (input.contains('mountain') ||
        input.contains('hill') ||
        input.contains('snow')) {
      positiveCat = 'Mountains';
    } else if (input.contains('beach') ||
        input.contains('coastal') ||
        input.contains('island')) {
      positiveCat = 'Beaches';
    } else if (input.contains('spiritual') ||
        input.contains('pilgrimage') ||
        input.contains('sacred') ||
        input.contains('holy') ||
        input.contains('temple')) {
      positiveCat = 'Spiritual';
    } else if (input.contains('heritage') ||
        input.contains('history') ||
        input.contains('palace') ||
        input.contains('fort')) {
      positiveCat = 'Heritage';
    } else if (input.contains('adventure') ||
        input.contains('rafting') ||
        input.contains('trekking')) {
      positiveCat = 'Adventure';
    }

    // Continuation intent: "more", "show more", "show me more", "next", "what else", "more mountains", "action_show_more"
    final isExplicitContinuation = input == 'more' ||
        input.startsWith('more ') ||
        input.contains('show more') ||
        input.contains('show me more') ||
        input.contains('give me more') ||
        input.contains('tell me more') ||
        input == 'next' ||
        input.contains('what else') ||
        input.contains('other places') ||
        input.contains('more places') ||
        input.contains('more options') ||
        input == 'action_show_more';

    // C. Context continuation: if user just gives budget like "under 3000" or continuation, retain previous positive category
    if (positiveCat == null && _context.positiveCategory != null) {
      if (isExplicitContinuation ||
          input.contains('under') ||
          input.contains('budget') ||
          input.contains('cheap') ||
          input.contains('day')) {
        positiveCat = _context.positiveCategory;
      }
    }

    // D. Parse Budget
    double? budgetLimit;
    final budgetMatch = RegExp(
      r'(?:under|below|less than|within|<=?)\s*(?:₹|rs\.?|inr)?\s*(\d+[\d,]*)',
    ).firstMatch(input);
    if (budgetMatch != null) {
      final numStr = budgetMatch.group(1)!.replaceAll(',', '');
      budgetLimit = double.tryParse(numStr);
    } else if (input.contains('5000') || input.contains('5,000')) {
      budgetLimit = 5000;
    } else if (input.contains('3000') || input.contains('3,000')) {
      budgetLimit = 3000;
    } else if (input.contains('2500') || input.contains('2,500')) {
      budgetLimit = 2500;
    } else if (input.contains('budget-friendly') ||
        input.contains('cheap') ||
        input.contains('low cost')) {
      budgetLimit = 2800;
    }

    // E. Parse Duration
    int? durationDays;
    if (input.contains('two-day') ||
        input.contains('2-day') ||
        input.contains('2 day') ||
        input.contains('weekend')) {
      durationDays = 3;
    } else if (input.contains('3-day') || input.contains('3 day')) {
      durationDays = 3;
    } else if (input.contains('day trip') || input.contains('1 day')) {
      durationDays = 1;
    } else if (input.contains('4 day') ||
        input.contains('5 day') ||
        input.contains('week')) {
      durationDays = 7;
    }

    // F. Parse Geographic Region & State Filters
    String? requiredRegion;
    String? requiredState;
    String? excludedDestination;

    if (input.contains('south india') ||
        input.contains('in the south') ||
        input.contains('southern india')) {
      requiredRegion = 'South India';
    } else if (input.contains('north india') ||
        input.contains('in the north') ||
        input.contains('northern india')) {
      requiredRegion = 'North India';
    } else if (input.contains('northeast') ||
        input.contains('north east') ||
        input.contains('seven sisters')) {
      requiredRegion = 'Northeast India';
    } else if (input.contains('west india') ||
        input.contains('western india')) {
      requiredRegion = 'West India';
    } else if (input.contains('central india')) {
      requiredRegion = 'Central India';
    } else if (input.contains('east india') ||
        input.contains('eastern india')) {
      requiredRegion = 'East India';
    }

    if (input.contains('rajasthan')) {
      requiredState = 'Rajasthan';
    } else if (input.contains('kerala')) {
      requiredState = 'Kerala';
    } else if (input.contains('karnataka')) {
      requiredState = 'Karnataka';
    } else if (input.contains('himachal')) {
      requiredState = 'Himachal Pradesh';
    } else if (input.contains('uttarakhand')) {
      requiredState = 'Uttarakhand';
    } else if (input.contains('goa') &&
        !input.contains('outside goa') &&
        !input.contains('not goa') &&
        !input.contains('other than goa') &&
        !input.contains('beyond goa') &&
        !input.contains('not in goa')) {
      requiredState = 'Goa';
    } else if (input.contains('tamil nadu')) {
      requiredState = 'Tamil Nadu';
    } else if (input.contains('ladakh')) {
      requiredState = 'Ladakh';
    } else if (input.contains('sikkim')) {
      requiredState = 'Sikkim';
    } else if (input.contains('meghalaya')) {
      requiredState = 'Meghalaya';
    }

    // Specific exclusion check (e.g. "outside goa", "other than goa", "not in goa")
    if (input.contains('outside goa') ||
        input.contains('not goa') ||
        input.contains('other than goa') ||
        input.contains('beyond goa') ||
        input.contains('not in goa')) {
      excludedDestination = 'goa';
    }

    // Determine if user switched categories or initiated a new criteria search
    final isCategoryChanged =
        positiveCat != null &&
        _context.positiveCategory != null &&
        positiveCat.toLowerCase() != _context.positiveCategory!.toLowerCase();

    final isNewSearch =
        !isExplicitContinuation &&
        (isCategoryChanged ||
            (_context.positiveCategory == null && positiveCat != null) ||
            requiredRegion != null ||
            requiredState != null ||
            budgetLimit != null);

    if (isNewSearch) {
      _context.resetForNewSearch();
    }

    // Update Context
    if (positiveCat != null) _context.positiveCategory = positiveCat;
    if (negativeCat != null) _context.negativeCategory = negativeCat;
    if (budgetLimit != null) _context.maxBudget = budgetLimit;
    if (durationDays != null) _context.maxDuration = durationDays;
    if (input.contains('peaceful') || input.contains('relax')) {
      _context.lastVibe = 'peaceful';
    } else if (isNewSearch) {
      _context.lastVibe = null;
    }

    final effectivePositiveCat = positiveCat ?? _context.positiveCategory;
    final effectiveNegativeCat = negativeCat ?? _context.negativeCategory;
    final effectiveBudget = budgetLimit ?? _context.maxBudget;
    final effectiveDuration = durationDays ?? _context.maxDuration;

    final hasRecommendationIntent =
        isExplicitContinuation ||
        positiveCat != null ||
        negativeCat != null ||
        budgetLimit != null ||
        durationDays != null ||
        requiredRegion != null ||
        requiredState != null ||
        excludedDestination != null ||
        input.contains('suggest') ||
        input.contains('recommend') ||
        input.contains('place') ||
        input.contains('destination') ||
        input.contains('where can i go') ||
        input.contains('where should i go') ||
        input.contains('where to go') ||
        input.contains('hill station') ||
        input.contains('lesser-known') ||
        input.contains('offbeat') ||
        input.contains('weekend') ||
        input.contains('peaceful') ||
        input.contains('adventure') ||
        input.contains('beach') ||
        input.contains('mountain') ||
        input.contains('heritage') ||
        input.contains('spiritual') ||
        input.contains('snow') ||
        input.contains('trek');

    if (!hasRecommendationIntent) {
      return ChatMessage(
        id: nowId,
        text: "Could you tell me what kind of trip you're planning? For example, ask me for peaceful mountain getaways, heritage forts in Rajasthan, beaches under ₹3,000, or local food in any city!",
        isUser: false,
        timestamp: DateTime.now(),
        destinations: const [],
        actionButtons: const [
          ChatActionButton(
            label: 'Show Mountains',
            route: '/explore',
            icon: Icons.terrain_rounded,
          ),
          ChatActionButton(
            label: 'Show Beaches',
            route: '/explore',
            icon: Icons.beach_access_rounded,
          ),
          ChatActionButton(
            label: 'Interactive Map',
            route: '/map',
            icon: Icons.map_rounded,
          ),
        ],
      );
    }

    // Filter candidate destinations
    List<Destination> candidates = allDestinations.where((d) {
      // Exclude negative category
      if (effectiveNegativeCat != null &&
          (d.category.toLowerCase() == effectiveNegativeCat.toLowerCase() ||
              d.matchesCategory(effectiveNegativeCat))) {
        return false;
      }

      // Check positive category
      if (effectivePositiveCat != null) {
        final posLower = effectivePositiveCat.toLowerCase();
        if (posLower == 'spiritual') {
          if (!d.matchesCategory('Spiritual')) return false;
        } else {
          if (d.category.toLowerCase() != posLower) return false;
        }
      }

      // Excluded destination / state (e.g., "beaches outside goa")
      if (excludedDestination != null) {
        if (d.id == excludedDestination ||
            d.state.toLowerCase() == excludedDestination) {
          return false;
        }
      }

      // Check required Region
      if (requiredRegion != null) {
        final regionLower = requiredRegion.toLowerCase();
        final matchesRegion =
            d.tags.any((t) => t.toLowerCase() == regionLower) ||
            _isStateInRegion(d.state, requiredRegion);
        if (!matchesRegion) return false;
      }

      // Check required State
      if (requiredState != null) {
        if (d.state.toLowerCase() != requiredState.toLowerCase()) {
          return false;
        }
      }

      // Check budget
      if (effectiveBudget != null && d.estimatedDailyCost > effectiveBudget) {
        return false;
      }

      // Check duration
      if (effectiveDuration != null &&
          d.suggestedDurationDays > effectiveDuration) {
        return false;
      }

      // Check hill stations
      if (input.contains('hill station') || input.contains('hill stations')) {
        final isHill =
            d.category == 'Mountains' ||
            d.tags.any(
              (t) =>
                  t.toLowerCase().contains('hill station') ||
                  t.toLowerCase().contains('hills') ||
                  t.toLowerCase().contains('hill'),
            );
        if (!isHill) return false;
      }

      // Check lesser-known / offbeat / unexplored
      if (input.contains('lesser-known') ||
          input.contains('lesser known') ||
          input.contains('offbeat') ||
          input.contains('hidden gem') ||
          input.contains('unexplored')) {
        final isOffbeat =
            !d.isPopular ||
            d.tags.any(
              (t) =>
                  t.toLowerCase().contains('offbeat') ||
                  t.toLowerCase().contains('peaceful'),
            );
        if (!isOffbeat) return false;
      }

      // Check weekend suitability
      if (input.contains('weekend')) {
        final isWeekend = d.isWeekendGetaway || d.suggestedDurationDays <= 3;
        if (!isWeekend) return false;
      }

      // Check peaceful vibe if requested
      final isPeacefulRequested = input.contains('peaceful') ||
          input.contains('relax') ||
          (isExplicitContinuation && _context.lastVibe == 'peaceful');
      if (isPeacefulRequested) {
        final tags = d.tags.map((t) => t.toLowerCase()).toList();
        final hasPeace = tags.any(
          (t) =>
              t.contains('peace') ||
              t.contains('calm') ||
              t.contains('serene') ||
              t.contains('nature') ||
              t.contains('relax') ||
              t.contains('ayurveda'),
        );
        if (!hasPeace && d.category != 'Mountains' && d.category != 'Beaches') {
          return false;
        }
      }

      return true;
    }).toList();

    // If matches found, return them with helpful explanation & pagination
    if (candidates.isNotEmpty) {
      // Sort candidates by rating descending
      candidates.sort((a, b) => b.rating.compareTo(a.rating));

      final remaining = candidates
          .where((d) => !_context.shownDestinationIds.contains(d.id))
          .toList();

      if (remaining.isEmpty && _context.shownDestinationIds.isNotEmpty) {
        final catLabel = effectivePositiveCat ?? 'matching';
        return ChatMessage(
          id: nowId,
          text:
              "You've explored all ${candidates.length} verified $catLabel destination(s) in our catalogue! 🌟 Would you like to check out another category or explore on the Interactive Map?",
          isUser: false,
          timestamp: DateTime.now(),
          destinations: const [],
          actionButtons: const [
            ChatActionButton(
              label: 'Interactive Map',
              route: '/map',
              icon: Icons.map_rounded,
            ),
            ChatActionButton(
              label: 'Explore Catalogue',
              route: '/explore',
              icon: Icons.explore_rounded,
            ),
          ],
        );
      }

      final batch = remaining.isNotEmpty
          ? remaining.take(4).toList()
          : candidates.take(4).toList();

      _context.shownDestinationIds.addAll(batch.map((d) => d.id));
      final remainingAfterBatch =
          candidates.length - _context.shownDestinationIds.length;

      final explanation = _buildMatchExplanation(
        totalCount: candidates.length,
        batchCount: batch.length,
        shownCount: _context.shownDestinationIds.length,
        isContinuation: isExplicitContinuation && remaining.isNotEmpty,
        category: effectivePositiveCat,
        negativeCategory: effectiveNegativeCat,
        region: requiredRegion,
        state: requiredState,
        excluded: excludedDestination,
        budget: effectiveBudget,
        duration: effectiveDuration,
        isPeaceful: input.contains('peaceful') || input.contains('relax'),
        isLesserKnown:
            input.contains('lesser-known') ||
            input.contains('lesser known') ||
            input.contains('offbeat'),
      );

      final actionButtons = <ChatActionButton>[];
      if (remainingAfterBatch > 0) {
        final moreLabel = effectivePositiveCat != null
            ? 'Show More $effectivePositiveCat'
            : 'Show More Places';
        actionButtons.add(
          ChatActionButton(
            label: moreLabel,
            route: 'action_show_more',
            icon: Icons.arrow_forward_rounded,
          ),
        );
      }
      actionButtons.add(
        const ChatActionButton(
          label: 'View in Interactive Map',
          route: '/map',
          icon: Icons.map_rounded,
        ),
      );
      actionButtons.add(
        const ChatActionButton(
          label: 'Explore All',
          route: '/explore',
          icon: Icons.explore_rounded,
        ),
      );

      return ChatMessage(
        id: nowId,
        text: explanation,
        isUser: false,
        timestamp: DateTime.now(),
        destinations: batch,
        actionButtons: actionButtons,
      );
    }

    // If NO exact matches found, explain why and offer closest alternative
    final closest = _findClosestAlternatives(
      allDestinations: allDestinations,
      positiveCat: effectivePositiveCat,
      negativeCat: effectiveNegativeCat,
      budget: effectiveBudget,
    );

    final failureExplanation = _buildNoMatchExplanation(
      category: effectivePositiveCat,
      negativeCategory: effectiveNegativeCat,
      budget: effectiveBudget,
      duration: effectiveDuration,
    );

    return ChatMessage(
      id: nowId,
      text: failureExplanation,
      isUser: false,
      timestamp: DateTime.now(),
      destinations: closest.take(3).toList(),
      actionButtons: const [
        ChatActionButton(
          label: 'Explore Catalogue',
          route: '/explore',
          icon: Icons.explore_rounded,
        ),
      ],
    );
  }

  String _buildMatchExplanation({
    required int totalCount,
    required int batchCount,
    required int shownCount,
    bool isContinuation = false,
    String? category,
    String? negativeCategory,
    String? region,
    String? state,
    String? excluded,
    double? budget,
    int? duration,
    bool isPeaceful = false,
    bool isLesserKnown = false,
  }) {
    final buffer = StringBuffer();
    if (isContinuation) {
      buffer.write("Here are the next $batchCount destination(s)");
      if (category != null) buffer.write(" in $category");
      buffer.write(" ($shownCount of $totalCount shown)");
    } else {
      buffer.write("I found $totalCount verified destination(s)");
      if (category != null) {
        buffer.write(" in $category");
      }
      if (negativeCategory != null) {
        buffer.write(" (excluding $negativeCategory)");
      }
      if (excluded != null) {
        buffer.write(" outside ${excluded.toUpperCase()}");
      }
      if (state != null) {
        buffer.write(" in $state");
      } else if (region != null) {
        buffer.write(" in $region");
      }
      if (isPeaceful) {
        buffer.write(" known for peaceful surroundings");
      }
      if (isLesserKnown) {
        buffer.write(" featuring lesser-known offbeat gems");
      }
      if (budget != null) {
        buffer.write(" with estimated daily costs under ₹${budget.toInt()}");
      }
      if (duration != null) {
        buffer.write(" suitable for $duration days");
      }
      if (totalCount > batchCount) {
        buffer.write(" (showing top $batchCount of $totalCount)");
      }
    }
    buffer.write(":");
    return buffer.toString();
  }

  String _buildNoMatchExplanation({
    String? category,
    String? negativeCategory,
    double? budget,
    int? duration,
  }) {
    final buffer = StringBuffer();
    buffer.write(
      "No exact destinations in our dataset match all your constraints",
    );

    if (category != null) buffer.write(" for $category");
    if (budget != null) buffer.write(" under ₹${budget.toInt()}/day");
    if (duration != null) buffer.write(" within $duration days");

    buffer.write(
      ".\n\nHere are the closest verified alternatives available in Travel Explorer:",
    );
    return buffer.toString();
  }

  List<Destination> _findClosestAlternatives({
    required List<Destination> allDestinations,
    String? positiveCat,
    String? negativeCat,
    double? budget,
  }) {
    var pool = allDestinations;
    if (negativeCat != null) {
      pool = pool
          .where((d) => d.category.toLowerCase() != negativeCat.toLowerCase())
          .toList();
    }
    if (positiveCat != null) {
      final catPool = pool
          .where((d) => d.category.toLowerCase() == positiveCat.toLowerCase())
          .toList();
      if (catPool.isNotEmpty) pool = catPool;
    }

    // Sort by price ascending to find closest budget
    final list = List<Destination>.from(pool);
    list.sort((a, b) => a.estimatedDailyCost.compareTo(b.estimatedDailyCost));
    return list.take(3).toList();
  }

  bool _isNavigationWishlistQuery(String input) {
    return input.contains('where can i find my wishlist') ||
        input.contains('where is my wishlist') ||
        input.contains('how do i see saved') ||
        input.contains('how can i remove a saved destination');
  }

  bool _isNavigationTripQuery(String input) {
    return input.contains('how do i add a place to my trip') ||
        input.contains('where can i see my itinerary') ||
        input.contains('how to plan a trip') ||
        input.contains('where are my trips') ||
        input.contains('plan a trip') ||
        input.contains('create a trip');
  }

  bool _isNavigationBudgetQuery(String input) {
    return input.contains('where can i check my budget') ||
        input.contains('how do i check my budget') ||
        input.contains('budget tracker') ||
        input.contains('planned vs actual') ||
        input.contains('how much have i spent');
  }

  bool _isNavigationMapQuery(String input) {
    return input.contains('where is the map') ||
        input.contains('interactive map') ||
        input.contains('where can i see the map');
  }

  bool _isNavigationExploreQuery(String input) {
    return input.contains('how do i explore all destinations') ||
        input.contains('where can i see all destinations') ||
        input.contains('complete catalogue') ||
        input.contains('all places');
  }

  // --- INTENT CLASSIFICATION & SPECIALIZED HANDLERS ---

  ChatMessage? _handleFoodQuery({
    required String input,
    required String nowId,
    required List<Destination> allDestinations,
  }) {
    _context.lastIntent = 'local_food';
    final dest = _findReferencedDestination(input, allDestinations);
    if (dest != null) {
      _context.lastDestinationId = dest.id;
      final buffer = StringBuffer();
      if (dest.localFoods.isNotEmpty) {
        buffer.writeln(
          "Here are must-try authentic local foods in **${dest.name}** (${dest.state}):\n",
        );
        for (final food in dest.localFoods) {
          buffer.writeln("• **$food**");
        }
        buffer.writeln(
          "\n💡 **Traveler Tip:** Look out for heritage eateries and traditional street bazaars for the most genuine regional flavours.",
        );
      } else {
        buffer.writeln(
          "We don't currently have a curated signature dishes list for **${dest.name}**, but regional dining spots in ${dest.city} serve authentic regional specialties!",
        );
      }

      return ChatMessage(
        id: nowId,
        text: buffer.toString().trim(),
        isUser: false,
        timestamp: DateTime.now(),
        destinations: const [],
        actionButtons: [
          ChatActionButton(
            label: 'Explore ${dest.name}',
            route: '/destination/${dest.id}',
            icon: Icons.place_rounded,
          ),
          ChatActionButton(
            label: 'View on Map',
            route: '/map?destinationId=${dest.id}',
            icon: Icons.map_rounded,
          ),
        ],
      );
    } else {
      return ChatMessage(
        id: nowId,
        text: "Which destination's local food would you like to explore? For example, ask me 'What should I eat in Madurai?' or 'Local food in Goa'.",
        isUser: false,
        timestamp: DateTime.now(),
        destinations: const [],
        actionButtons: const [
          ChatActionButton(
            label: 'Explore Catalogue',
            route: '/explore',
            icon: Icons.explore_rounded,
          ),
        ],
      );
    }
  }

  ChatMessage? _handleShoppingQuery({
    required String input,
    required String nowId,
    required List<Destination> allDestinations,
  }) {
    _context.lastIntent = 'shopping';
    final dest = _findReferencedDestination(input, allDestinations);
    if (dest != null) {
      _context.lastDestinationId = dest.id;
      final spots = ShoppingSpotsData.getSpotsForDestination(dest.id);
      final buffer = StringBuffer();
      if (spots.isNotEmpty) {
        buffer.writeln(
          "Here are verified local shopping spots in **${dest.name}**:\n",
        );
        for (final spot in spots) {
          buffer.writeln("• **${spot.name}** (${spot.locality})");
          buffer.writeln("  - Known for: ${spot.knownFor}");
          if (spot.specialities.isNotEmpty) {
            buffer.writeln("  - Specialties: ${spot.specialities.join(', ')}");
          }
          if (spot.tips != null && spot.tips!.isNotEmpty) {
            buffer.writeln("  - Tip: ${spot.tips}");
          }
          buffer.writeln();
        }
      } else {
        buffer.writeln(
          "We don't currently have curated shopping bazaar listings for **${dest.name}** in our database. You can explore regional craft centers or check the Interactive Map for local spots.",
        );
      }

      return ChatMessage(
        id: nowId,
        text: buffer.toString().trim(),
        isUser: false,
        timestamp: DateTime.now(),
        destinations: const [],
        actionButtons: [
          ChatActionButton(
            label: 'Open Map for ${dest.name}',
            route: '/map?destinationId=${dest.id}',
            icon: Icons.shopping_bag_rounded,
          ),
          ChatActionButton(
            label: 'Explore ${dest.name}',
            route: '/destination/${dest.id}',
            icon: Icons.place_rounded,
          ),
        ],
      );
    } else {
      return ChatMessage(
        id: nowId,
        text: "Which destination are you looking to shop in? For example, ask 'Where can I shop in Munnar?' or 'Shopping in Jaipur'.",
        isUser: false,
        timestamp: DateTime.now(),
        destinations: const [],
        actionButtons: const [
          ChatActionButton(
            label: 'Interactive Map',
            route: '/map',
            icon: Icons.map_rounded,
          ),
        ],
      );
    }
  }

  Destination? _findReferencedDestination(
    String input,
    List<Destination> allDestinations,
  ) {
    final lower = input.toLowerCase();

    // Check context lastDestinationId if user says "there", "in that place", "in that city"
    if (lower.contains('there') ||
        lower.contains('that place') ||
        lower.contains('that city') ||
        lower.contains('this place') ||
        lower.contains('this city')) {
      if (_context.lastDestinationId != null) {
        try {
          return allDestinations.firstWhere(
            (d) => d.id == _context.lastDestinationId,
          );
        } catch (_) {}
      }
      if (_context.shownDestinationIds.isNotEmpty) {
        try {
          final lastId = _context.shownDestinationIds.last;
          return allDestinations.firstWhere((d) => d.id == lastId);
        } catch (_) {}
      }
    }

    // Sort destinations by name length descending so multi-word names match first
    final sorted = List<Destination>.from(allDestinations)
      ..sort((a, b) => b.name.length.compareTo(a.name.length));

    for (final dest in sorted) {
      final nameLower = dest.name.toLowerCase();
      final idLower = dest.id.toLowerCase();
      final cityLower = dest.city.toLowerCase();

      // Word boundary match or containment for name/id
      if (lower.contains(nameLower) ||
          lower.contains(idLower) ||
          (cityLower.length >= 4 && lower.contains(cityLower))) {
        return dest;
      }

      // Check first distinctive word of multi-word destination names
      final firstWord = nameLower.split(' ').first;
      if (firstWord.length >= 4 &&
          !['lake', 'fort', 'park', 'hill', 'valley'].contains(firstWord) &&
          lower.contains(firstWord)) {
        return dest;
      }
    }
    return null;
  }

  bool _isUnknownRealtimeQuery(String lower) {
    const patterns = [
      'open right now',
      'open now',
      'currently open',
      'closed right now',
      'closed now',
      'is it open today',
      'opening hours right now',
      'is this particular local market open',
      'live crowd',
      'crowded right now',
      'is there a crowd today',
      'live train status',
      'train running status',
      'live flight status',
      'ticket price today',
      'ticket availability right now',
      'current traffic',
      'traffic right now',
    ];
    return patterns.any((p) => lower.contains(p));
  }

  bool _isIrrelevantQuery(String input, List<Destination> allDestinations) {
    final lower = input.toLowerCase();

    // Specific non-travel educational and technical topics
    const nonTravelTopics = [
      'binary search',
      'algorithm',
      'python',
      'javascript',
      'java',
      'c++',
      'programming',
      'coding',
      'recursion',
      'data structure',
      'linked list',
      'bubble sort',
      'machine learning',
      'neural network',
      'photosynthesis',
      'mitochondria',
      'calculus',
      'derivative',
      'integral',
      'quantum physics',
      'periodic table',
      'capital of france',
      'capital of germany',
      'capital of japan',
      'capital of england',
      'capital of usa',
      'capital of canada',
      'who is the president',
      'prime minister of the uk',
      'cryptocurrency',
      'bitcoin',
      'ethereum',
      'stock market',
      'write an essay',
      'solve for x',
      'recipe for cake',
      'physics',
      'chemistry',
      'biology',
    ];

    for (final topic in nonTravelTopics) {
      if (lower.contains(topic)) return true;
    }

    // If query mentions a recognized destination, it is NOT irrelevant
    final dest = _findReferencedDestination(input, allDestinations);
    if (dest != null) return false;

    // Check if it has any travel intent keywords
    final hasTravel = _hasTravelKeywords(lower);
    if (!hasTravel) {
      final words = lower
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .toList();
      if (words.length >= 3) {
        return true;
      }
    }

    return false;
  }

  bool _hasTravelKeywords(String lower) {
    const travelKeywords = [
      'travel',
      'trip',
      'trips',
      'visit',
      'destination',
      'destinations',
      'holiday',
      'vacation',
      'tour',
      'tourist',
      'explore',
      'journey',
      'itinerary',
      'budget',
      'cost',
      'hotel',
      'resort',
      'stay',
      'flight',
      'train',
      'bus',
      'route',
      'ticket',
      'mountain',
      'mountains',
      'hill',
      'hills',
      'beach',
      'beaches',
      'coast',
      'coastal',
      'heritage',
      'fort',
      'forts',
      'palace',
      'palaces',
      'temple',
      'temples',
      'spiritual',
      'pilgrimage',
      'adventure',
      'trek',
      'trekking',
      'hike',
      'hiking',
      'nature',
      'weather',
      'season',
      'places',
      'place',
      'spots',
      'spot',
      'lake',
      'river',
      'waterfall',
      'waterfalls',
      'valley',
      'sanctuary',
      'national park',
      'wildlife',
      'safari',
      'island',
      'islands',
      'getaway',
      'weekend',
      'peaceful',
      'calm',
      'relax',
      'offbeat',
      'food',
      'eat',
      'cuisine',
      'dishes',
      'shop',
      'shopping',
      'bazaar',
      'market',
      'guide',
      'suggest',
      'recommend',
      'under',
      'cheap',
      'inexpensive',
      'days',
      'day',
      'north',
      'south',
      'east',
      'west',
      'india',
      'indian',
      'wishlist',
      'pack',
      'attraction',
      'attractions',
      'sightseeing',
      'sights',
      'monument',
      'monuments',
      'more',
      'next',
      'vibe',
      'scenic',
    ];
    return travelKeywords.any((kw) => lower.contains(kw));
  }

  bool _isLocalFoodQuery(String lower) {
    return lower.contains('food') ||
        lower.contains('eat') ||
        lower.contains('cuisine') ||
        lower.contains('dishes') ||
        lower.contains('dish') ||
        lower.contains('delicacies') ||
        lower.contains('delicacy') ||
        lower.contains('culinary') ||
        lower.contains('breakfast') ||
        lower.contains('dinner') ||
        lower.contains('lunch') ||
        lower.contains('street food') ||
        lower.contains('famous to eat') ||
        lower.contains('what should i eat');
  }

  bool _isShoppingQuery(String lower) {
    return lower.contains('shop') ||
        lower.contains('shopping') ||
        lower.contains('bazaar') ||
        lower.contains('bazaars') ||
        lower.contains('market') ||
        lower.contains('markets') ||
        lower.contains('souvenir') ||
        lower.contains('souvenirs') ||
        lower.contains('handicraft') ||
        lower.contains('handicrafts') ||
        lower.contains('what to buy') ||
        lower.contains('where to buy') ||
        lower.contains('where can i shop');
  }

  bool _isAmbiguousQuery(String lower) {
    final clean = lower.trim().replaceAll(RegExp(r'[^\w\s]'), '');
    const ambiguousWords = {
      'places',
      'place',
      'travel',
      'trip',
      'destination',
      'destinations',
      'help',
      'suggest',
      'recommend',
      'plan',
      'go',
      'tour',
      'explore',
      'tell me',
      'hello there',
      'show',
      'find',
      'somewhere',
      'anywhere',
    };
    return ambiguousWords.contains(clean);
  }
}
