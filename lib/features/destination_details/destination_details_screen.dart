import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/local/shopping_spots_data.dart';
import '../../models/destination.dart';
import '../../models/user_review.dart';
import '../../models/weather.dart';
import '../../providers/auth_provider.dart';
import '../../providers/destination_provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../services/weather_service.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/rating_badge.dart';
import '../trips/create_edit_trip_dialog.dart';

class DestinationDetailsScreen extends StatefulWidget {
  final String destinationId;

  const DestinationDetailsScreen({super.key, required this.destinationId});

  @override
  State<DestinationDetailsScreen> createState() =>
      _DestinationDetailsScreenState();
}

class _DestinationDetailsScreenState extends State<DestinationDetailsScreen> {
  final WeatherService _weatherService = WeatherService();
  WeatherData? _weatherData;
  bool _isLoadingWeather = false;
  String? _weatherError;

  // Rating & Review State
  int _selectedStarRating = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmittingRating = false;
  String? _ratingError;
  bool _hasLoadedExistingReview = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWeather();
      _loadExistingReviewIfNeeded();
    });
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _loadExistingReviewIfNeeded() {
    if (_hasLoadedExistingReview || !mounted) return;
    _hasLoadedExistingReview = true;
    final destProvider = context.read<DestinationProvider>();
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id ?? 'guest';
    final existing = destProvider.getUserReview(widget.destinationId, userId);
    if (existing != null && mounted) {
      setState(() {
        _selectedStarRating = existing.rating.round();
        _reviewController.text = existing.comment;
      });
    }
  }

  Future<void> _loadWeather({bool forceRefresh = false}) async {
    final destProvider = context.read<DestinationProvider>();
    final dest = destProvider.findById(widget.destinationId);
    if (dest == null) return;

    setState(() {
      _isLoadingWeather = true;
      _weatherError = null;
    });

    try {
      final weather = await _weatherService.fetchWeather(
        destinationName: dest.name,
        latitude: dest.latitude,
        longitude: dest.longitude,
        forceRefresh: forceRefresh,
      );
      if (mounted) {
        setState(() {
          _weatherData = weather;
          _isLoadingWeather = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _weatherError = e.toString().replaceAll('Exception: ', '');
          _isLoadingWeather = false;
        });
      }
    }
  }

  void _showAddToTripDialog(BuildContext context, Destination dest) {
    final tripProvider = context.read<TripProvider>();
    final trips = tripProvider.trips;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.creamSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.dividerDark
                        : AppColors.creamBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Add ${dest.name} to a Trip',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Select an existing trip or create a new one for ${dest.name}.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 16),

              // Option 1: Create New Trip with this destination
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.mutedSageLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: isDark ? AppColors.mutedSage : AppColors.forestGreen,
                  ),
                ),
                title: const Text(
                  'Plan a New Trip Here',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Set dates, budget & travelers for ${dest.name}',
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  Navigator.pop(ctx);
                  showDialog(
                    context: context,
                    builder: (dialogCtx) => CreateEditTripDialog(
                      initialDestinationId: dest.id,
                      initialDestinationName: '${dest.name}, ${dest.state}',
                      initialImage: dest.imageUrl,
                      initialBudget:
                          dest.estimatedDailyCost * dest.suggestedDurationDays,
                    ),
                  );
                },
              ),
              const Divider(),

              // Option 2: Add to existing trips
              if (trips.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Or Add to Existing Trips',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: trips.length,
                    itemBuilder: (context, i) {
                      final trip = trips[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.flight_takeoff_rounded,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          trip.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          Formatters.formatDateRange(
                            trip.startDate,
                            trip.endDate,
                          ),
                        ),
                        onTap: () async {
                          // Add an activity for this destination into day 1
                          await tripProvider.addActivity(
                            tripId: trip.id,
                            dayNumber: 1,
                            date: trip.startDate,
                            title: 'Visit ${dest.name}',
                            locationName: '${dest.city}, ${dest.state}',
                            notes:
                                'Explore top attractions and local highlights in ${dest.name}.',
                            latitude: dest.latitude,
                            longitude: dest.longitude,
                          );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Added ${dest.name} to "${trip.title}"!',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _shareDestination(Destination dest) {
    Clipboard.setData(
      ClipboardData(
        text:
            'Discover ${dest.name}, ${dest.state}! Estimated budget: ₹${dest.estimatedDailyCost.toInt()}/day. Best time to visit: ${dest.bestTimeToVisit}. Explore in Travel Explorer App!',
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Destination details copied to clipboard! Ready to share.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final destProvider = context.watch<DestinationProvider>();
    final wishlistProvider = context.watch<WishlistProvider>();

    final dest = destProvider.findById(widget.destinationId);

    if (dest == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Destination')),
        body: const Center(child: Text('Destination not found.')),
      );
    }

    final isSaved = wishlistProvider.isWishlisted(dest.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. Sliver App Bar with Hero Image
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            leading: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.4),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ),
            actions: [
              CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.4),
                child: IconButton(
                  icon: const Icon(
                    Icons.share_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => _shareDestination(dest),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.4),
                child: IconButton(
                  icon: Icon(
                    isSaved
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isSaved ? AppColors.terracotta : Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    wishlistProvider.toggleWishlist(dest.id);
                  },
                ),
              ),
              const SizedBox(width: 14),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  AppNetworkImage(imageUrl: dest.imageUrl, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.35),
                          Colors.transparent,
                          Colors.black.withOpacity(0.75),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: dest.palette.badgeBackground,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm,
                                ),
                                border: Border.all(
                                  color: dest.palette.cardBorder,
                                ),
                              ),
                              child: Text(
                                dest.category.toUpperCase(),
                                style: TextStyle(
                                  color: dest.palette.badgeText,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            RatingBadge(
                              rating: dest.rating,
                              reviewCount: dest.reviewCount,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          dest.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${dest.city}, ${dest.state}, ${dest.country}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Body Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Key Metrics Row (Budget, Duration, Season)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceDark
                          : AppColors.creamSurface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: isDark
                            ? AppColors.dividerDark
                            : AppColors.creamBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricItem(
                          context,
                          icon: Icons.currency_rupee_rounded,
                          iconColor: dest.palette.currentPrimary(isDark),
                          title: 'Est. Daily Cost',
                          value: Formatters.formatCurrency(
                            dest.estimatedDailyCost,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: isDark
                              ? AppColors.dividerDark
                              : AppColors.creamBorder,
                        ),
                        _buildMetricItem(
                          context,
                          icon: Icons.timelapse_rounded,
                          iconColor: dest.palette.currentPrimary(isDark),
                          title: 'Suggested',
                          value: '${dest.suggestedDurationDays} Days',
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: isDark
                              ? AppColors.dividerDark
                              : AppColors.creamBorder,
                        ),
                        _buildMetricItem(
                          context,
                          icon: Icons.wb_sunny_outlined,
                          iconColor: dest.palette.currentPrimary(isDark),
                          title: 'Best Season',
                          value: dest.seasons.first.split(' ').first,
                        ),
                      ],
                    ),
                  ),

                  // Overview Description
                  const SizedBox(height: 24),
                  Text(
                    'About ${dest.name}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dest.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),

                  // Tags / Interests
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: dest.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceDark
                              : AppColors.warmCream,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(
                            color: isDark
                                ? AppColors.dividerDark
                                : AppColors.creamBorder,
                          ),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // ⭐️ Rate This Place & Traveler Reviews Section
                  const SizedBox(height: 28),
                  _buildRatingSubmissionSection(context, dest, isDark),

                  // Live Weather Section
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Live Destination Weather',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, size: 20),
                        tooltip: 'Refresh Weather',
                        onPressed: () => _loadWeather(forceRefresh: true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildWeatherCard(context, isDark),

                  // Key Highlights
                  if (dest.highlights.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Text(
                      'Trip Highlights',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...dest.highlights.map(
                      (h) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: dest.palette.currentPrimary(isDark),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                h,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Popular Attractions
                  if (dest.attractions.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Text(
                      'Top Attractions (${dest.attractions.length})',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...dest.attractions.map(
                      (attr) => Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceDark
                              : AppColors.creamSurface,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color: isDark
                                ? AppColors.dividerDark
                                : AppColors.creamBorder,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppNetworkImage(
                              imageUrl: attr.imageUrl,
                              width: 100,
                              height: 100,
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(AppRadius.lg),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      attr.name,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimaryLight,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      attr.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          attr.entryFee,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: dest.palette.currentPrimary(
                                              isDark,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            context.push(
                                              Uri(
                                                path: '/map',
                                                queryParameters: {
                                                  'destinationId': dest.id,
                                                  'attractionName': attr.name,
                                                  'attractionLat': attr.latitude
                                                      .toString(),
                                                  'attractionLng': attr
                                                      .longitude
                                                      .toString(),
                                                  'parentDestinationName':
                                                      '${dest.name}, ${dest.state}',
                                                  'attractionDesc':
                                                      attr.description,
                                                  'attractionImg':
                                                      attr.imageUrl,
                                                },
                                              ).toString(),
                                            );
                                          },
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.directions_rounded,
                                                size: 14,
                                                color: dest.palette
                                                    .currentPrimary(isDark),
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                'Directions',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: dest.palette
                                                      .currentPrimary(isDark),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Best Time to Visit & Tips
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceDark
                          : dest.palette.backgroundTint,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: dest.palette.currentBorder(isDark),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.tips_and_updates_rounded,
                              color: AppColors.accentAmber,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Traveler Insights & Best Time',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '📅 Best months to visit: ${dest.bestTimeToVisit}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...dest.travelTips.map(
                          (tip) => Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Expanded(
                                  child: Text(
                                    tip,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Local Foods
                  if (dest.localFoods.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Text(
                      'Must-Try Local Foods',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: dest.localFoods.map((food) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceDark
                                : AppColors.creamSurface,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.dividerDark
                                  : AppColors.creamBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.restaurant_menu_rounded,
                                size: 14,
                                color: AppColors.accentAmber,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                food,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  // 🛍️ Local Shopping Spots
                  ..._buildShoppingSpotsSection(context, dest, isDark),

                  // 🌿 Explore Nearby / Regional Itineraries
                  ..._buildNearbyDestinationsSection(
                    context,
                    dest,
                    destProvider.allDestinations,
                    isDark,
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Action Bar
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.warmCream,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.dividerDark : AppColors.creamBorder,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: dest.palette.currentPrimary(isDark),
                  side: BorderSide(color: dest.palette.currentPrimary(isDark)),
                ),
                icon: const Icon(Icons.map_rounded, size: 18),
                label: const Text('Map'),
                onPressed: () {
                  context.push('/map?destinationId=${dest.id}');
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dest.palette.currentPrimary(isDark),
                    foregroundColor: dest.palette.onPrimary,
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.add_location_alt_rounded, size: 18),
                  label: const Text('Add to Trip'),
                  onPressed: () => _showAddToTripDialog(context, dest),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem(
    BuildContext context, {
    required IconData icon,
    Color? iconColor,
    required String title,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Icon(icon, size: 18, color: iconColor ?? AppColors.primaryLight),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSubmissionSection(
    BuildContext context,
    Destination dest,
    bool isDark,
  ) {
    final destProvider = context.watch<DestinationProvider>();
    final authProvider = context.watch<AuthProvider>();
    final localReviews = destProvider.getReviewsForDestination(dest.id);
    final totalReviewCount = dest.reviewCount + localReviews.length;

    double displayRating = dest.rating;
    if (localReviews.isNotEmpty) {
      final localSum = localReviews.fold<double>(
        0.0,
        (acc, r) => acc + r.rating,
      );
      displayRating =
          (dest.rating * dest.reviewCount + localSum) / totalReviewCount;
    }

    final currentUserId = authProvider.currentUser?.id ?? 'guest';
    final existingReview = destProvider.getUserReview(dest.id, currentUserId);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.creamSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.creamBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF173F35).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Overview Rating
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD18A61).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.rate_review_rounded,
                  color: Color(0xFFD18A61),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rate This Place',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.forestGreen,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${displayRating.toStringAsFixed(1)} ★ based on $totalReviewCount verified review(s)',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Interactive Five-Star Control
          Center(
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    final starNumber = index + 1;
                    final isFilled = starNumber <= _selectedStarRating;
                    return InkResponse(
                      radius: 24,
                      onTap: () {
                        setState(() {
                          _selectedStarRating = starNumber;
                          _ratingError = null;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Icon(
                          isFilled
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 38,
                          color: isFilled
                              ? const Color(0xFFD18A61)
                              : (isDark
                                    ? AppColors.mutedSage.withValues(alpha: 0.4)
                                    : AppColors.mutedSage),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 6),
                Text(
                  _getRatingDescriptor(_selectedStarRating),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _selectedStarRating > 0
                        ? const Color(0xFFD18A61)
                        : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Optional Written Review Input
          TextField(
            controller: _reviewController,
            maxLines: 3,
            minLines: 2,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
            decoration: InputDecoration(
              hintText: 'Write your personal review, tips, or highlights (optional)...',
              hintStyle: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.textSecondaryDark.withValues(alpha: 0.7)
                    : AppColors.textSecondaryLight.withValues(alpha: 0.7),
              ),
              filled: true,
              fillColor: isDark ? AppColors.charcoal : AppColors.warmCream,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(
                  color: isDark ? AppColors.dividerDark : AppColors.creamBorder,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(
                  color: isDark ? AppColors.dividerDark : AppColors.creamBorder,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(
                  color: dest.palette.currentPrimary(isDark),
                  width: 1.5,
                ),
              ),
            ),
          ),

          if (_ratingError != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 14,
                  color: AppColors.error,
                ),
                const SizedBox(width: 4),
                Text(
                  _ratingError!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),

          // Authentication note & Submit button
          Row(
            children: [
              Expanded(
                child: authProvider.isAuthenticated
                    ? Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 15,
                            color: AppColors.forestGreen,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Posting as ${authProvider.currentUser?.displayName ?? "Traveler"}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 15,
                            color: isDark
                                ? AppColors.mutedSage
                                : AppColors.forestGreen,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Rating as Guest.',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => context.push('/login'),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: Text(
                                'Sign in',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: dest.palette.currentPrimary(isDark),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: dest.palette.currentPrimary(isDark),
                  foregroundColor: dest.palette.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  elevation: 0,
                ),
                icon: _isSubmittingRating
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 16),
                label: Text(
                  existingReview != null
                      ? 'Update My Rating'
                      : 'Post My Rating',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onPressed: _isSubmittingRating
                    ? null
                    : () async {
                        if (_selectedStarRating == 0) {
                          setState(() {
                            _ratingError = 'Please select a star rating (1-5 stars) before posting.';
                          });
                          return;
                        }

                        setState(() => _isSubmittingRating = true);
                        final userId = authProvider.currentUser?.id ?? 'guest';
                        final userName =
                            authProvider.currentUser?.displayName ?? 'Traveler';

                        await destProvider.submitRating(
                          destinationId: dest.id,
                          rating: _selectedStarRating.toDouble(),
                          comment: _reviewController.text.trim(),
                          userId: userId,
                          userName: userName,
                        );

                        if (mounted) {
                          setState(() {
                            _isSubmittingRating = false;
                            _ratingError = null;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Thank you! Your rating of $_selectedStarRating ★ for ${dest.name} has been posted.',
                              ),
                              backgroundColor: AppColors.forestGreen,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
              ),
            ],
          ),

          // Community / Recent Reviews Display
          if (localReviews.isNotEmpty) ...[
            const SizedBox(height: 18),
            Divider(
              color: isDark ? AppColors.dividerDark : AppColors.creamBorder,
            ),
            const SizedBox(height: 12),
            Text(
              'Community Reviews (${localReviews.length})',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.forestGreen,
              ),
            ),
            const SizedBox(height: 8),
            ...localReviews.map(
              (rev) => _buildReviewCard(
                rev: rev,
                isDark: isDark,
                dest: dest,
                isCurrentUser: rev.userId == currentUserId,
                onEdit: () {
                  setState(() {
                    _selectedStarRating = rev.rating.round();
                    _reviewController.text = rev.comment;
                    _ratingError = null;
                  });
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getRatingDescriptor(int stars) {
    switch (stars) {
      case 1:
        return '★☆☆☆☆ 1 - Poor';
      case 2:
        return '★★☆☆☆ 2 - Fair';
      case 3:
        return '★★★☆☆ 3 - Good';
      case 4:
        return '★★★★☆ 4 - Very Good';
      case 5:
        return '★★★★★ 5 - Excellent!';
      default:
        return 'Tap a star to rate this place';
    }
  }

  Widget _buildReviewCard({
    required UserReview rev,
    required bool isDark,
    required Destination dest,
    required bool isCurrentUser,
    required VoidCallback onEdit,
  }) {
    final dateFormat = DateFormat('MMM d, yyyy');
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.charcoal : AppColors.warmCream,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isCurrentUser
              ? dest.palette.currentPrimary(isDark).withValues(alpha: 0.5)
              : (isDark ? AppColors.dividerDark : AppColors.creamBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: isDark
                        ? AppColors.surfaceDark
                        : AppColors.creamBorder,
                    child: Text(
                      rev.userName.isNotEmpty
                          ? rev.userName[0].toUpperCase()
                          : 'T',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: dest.palette.currentPrimary(isDark),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    rev.userName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  if (isCurrentUser) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: dest.palette
                            .currentPrimary(isDark)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'You',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: dest.palette.currentPrimary(isDark),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Row(
                children: [
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < rev.rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 14,
                        color: const Color(0xFFD18A61),
                      ),
                    ),
                  ),
                  if (isCurrentUser) ...[
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: onEdit,
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          Icons.edit_rounded,
                          size: 14,
                          color: dest.palette.currentPrimary(isDark),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          if (rev.comment.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              rev.comment,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            dateFormat.format(rev.createdAt),
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppColors.textSecondaryDark.withValues(alpha: 0.6)
                  : AppColors.textSecondaryLight.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard(BuildContext context, bool isDark) {
    if (_isLoadingWeather) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(height: 8),
            Text(
              'Fetching live Open-Meteo forecast...',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    }

    if (_weatherError != null || _weatherData == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.warning,
              size: 28,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weather temporarily unavailable',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    _weatherError ??
                        'Connect to the internet to load current weather.',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => _loadWeather(forceRefresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final weather = _weatherData!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E2822), const Color(0xFF141B17)]
              : [AppColors.forestGreen, const Color(0xFF265A4D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Current Weather
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.wb_cloudy_rounded,
                    size: 38,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${weather.temperature.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        weather.condition,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Humidity: ${weather.humidity}%',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    'Wind: ${weather.windSpeed.toStringAsFixed(1)} km/h',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Open-Meteo Live API',
                    style: TextStyle(color: Colors.white54, fontSize: 9),
                  ),
                ],
              ),
            ],
          ),

          // Daily Forecast
          if (weather.dailyForecast.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(height: 1, color: Colors.white.withOpacity(0.18)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weather.dailyForecast.map((day) {
                return Column(
                  children: [
                    Text(
                      day.dayName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Icon(
                      Icons.wb_sunny_rounded,
                      color: AppColors.accentAmber,
                      size: 16,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${day.maxTemp.toInt()}° / ${day.minTemp.toInt()}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  double _haversineDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295; // Pi / 180
    final a =
        0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) *
            math.cos(lat2 * p) *
            (1 - math.cos((lon2 - lon1) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(a));
  }

  List<Widget> _buildShoppingSpotsSection(
    BuildContext context,
    Destination dest,
    bool isDark,
  ) {
    final spots = ShoppingSpotsData.getSpotsForDestination(dest.id);
    if (spots.isEmpty) return const [];

    return [
      const SizedBox(height: 28),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.terracotta.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Text('🛍️', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Local Shopping Spots',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  'Little finds and local treasures worth exploring',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: isDark
                        ? AppColors.mutedSage
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      ...spots.map(
        (spot) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.creamSurface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isDark ? AppColors.dividerDark : AppColors.creamBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          spot.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 13,
                              color: AppColors.mutedSage,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                spot.locality,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.mutedSage,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.terracotta,
                      side: const BorderSide(
                        color: AppColors.terracotta,
                        width: 1.2,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.map_rounded, size: 14),
                    label: const Text(
                      'View on Map',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () {
                      context.push('/map?spotId=${spot.id}');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                spot.knownFor,
                style: TextStyle(
                  fontSize: 12.5,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.charcoal,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: spot.specialities
                    .map(
                      (spec) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.cardDark
                              : AppColors.warmCream.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                          border: Border.all(
                            color: isDark
                                ? AppColors.dividerDark
                                : AppColors.creamBorder,
                          ),
                        ),
                        child: Text(
                          '✨ $spec',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.creamSurface
                                : AppColors.forestGreen,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 13,
                    color: AppColors.terracotta,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    spot.openingHours,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (spot.tips != null) ...[
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.tips_and_updates_outlined,
                      size: 13,
                      color: AppColors.accentAmber,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        spot.tips!,
                        style: const TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: AppColors.mutedSage,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildNearbyDestinationsSection(
    BuildContext context,
    Destination currentDest,
    List<Destination> allDestinations,
    bool isDark,
  ) {
    // Calculate distance for all other destinations and pick the top 3-4 nearest
    final destinationsWithDist = allDestinations
        .where((d) => d.id != currentDest.id)
        .map((d) {
          final dist = _haversineDistanceKm(
            currentDest.latitude,
            currentDest.longitude,
            d.latitude,
            d.longitude,
          );
          return (destination: d, distanceKm: dist);
        })
        .toList();

    destinationsWithDist.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    final nearbyList = destinationsWithDist.take(4).toList();

    if (nearbyList.isEmpty) return const [];

    return [
      const SizedBox(height: 28),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.mutedSage.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Text('🌿', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore Nearby & Regional Circuit',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  'Complementary stops to weave into this journey',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: isDark
                        ? AppColors.mutedSage
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      ...nearbyList.map((item) {
        final dest = item.destination;
        final distKm = item.distanceKm.round();
        final driveHours = (item.distanceKm / 45.0).toStringAsFixed(1);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.creamSurface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isDark ? AppColors.dividerDark : AppColors.creamBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              onTap: () {
                context.push('/destination/${dest.id}');
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Destination Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: AppNetworkImage(
                        imageUrl: dest.imageUrl,
                        width: 76,
                        height: 76,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.forestGreen.withOpacity(
                                    isDark ? 0.3 : 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.xs,
                                  ),
                                ),
                                child: Text(
                                  dest.category.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? AppColors.mutedSage
                                        : AppColors.forestGreen,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              RatingBadge(
                                rating: dest.rating,
                                reviewCount: dest.reviewCount,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dest.name,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dest.state,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.mutedSage,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.directions_car_rounded,
                                size: 13,
                                color: AppColors.terracotta,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '~$distKm km · ~$driveHours hrs scenic travel',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.creamSurface
                                      : AppColors.charcoal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: isDark
                          ? AppColors.mutedSage
                          : AppColors.charcoal.withOpacity(0.4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    ];
  }
}
