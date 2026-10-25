import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../features/trips/create_edit_trip_dialog.dart';
import '../../models/destination.dart';
import '../../providers/trip_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../app_network_image.dart';
import '../rating_badge.dart';

/// Floating bottom preview card displayed when a user selects a destination marker.
class DestinationMapPreviewCard extends StatelessWidget {
  final Destination destination;
  final VoidCallback onClose;

  const DestinationMapPreviewCard({
    super.key,
    required this.destination,
    required this.onClose,
  });

  void _showAddToTripSheet(BuildContext context) {
    final tripProvider = context.read<TripProvider>();
    final trips = tripProvider.trips;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
                      : AppColors.dividerLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add "${destination.name}" to Trip',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: destination.palette.badgeBackground,
                child: Icon(
                  Icons.add_circle_outline_rounded,
                  color: destination.palette.primary,
                ),
              ),
              title: const Text(
                'Create New Trip',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                'Plan a new vacation to ${destination.name}',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () {
                Navigator.pop(ctx);
                showDialog(
                  context: context,
                  builder: (dialogCtx) => CreateEditTripDialog(
                    initialDestinationId: destination.id,
                    initialDestinationName:
                        '${destination.name}, ${destination.state}',
                    initialImage: destination.imageUrl,
                    initialBudget:
                        destination.estimatedDailyCost *
                        destination.suggestedDurationDays,
                  ),
                );
              },
            ),
            if (trips.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 6),
              const Text(
                'Or Add to Existing Trip Itinerary',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 180),
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
                        style: const TextStyle(fontSize: 11),
                      ),
                      onTap: () async {
                        await tripProvider.addActivity(
                          tripId: trip.id,
                          dayNumber: 1,
                          date: trip.startDate,
                          title: 'Visit ${destination.name}',
                          locationName:
                              '${destination.city}, ${destination.state}',
                          notes: 'Discovered via Travel Explorer Map.',
                          latitude: destination.latitude,
                          longitude: destination.longitude,
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Added ${destination.name} to "${trip.title}"!',
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wishlistProvider = context.watch<WishlistProvider>();
    final isWishlisted = wishlistProvider.isWishlisted(destination.id);
    final palette = destination.palette;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.creamSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: palette.currentBorder(isDark), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Content Row
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail image with category badge
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Stack(
                    children: [
                      AppNetworkImage(
                        imageUrl: destination.imageUrl,
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 6,
                        left: 6,
                        child: RatingBadge(
                          rating: destination.rating,
                          compact: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Title, location, category & budget
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: palette.badgeBackground,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(
                                color: palette.cardBorder,
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              destination.category.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: palette.badgeText,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          // Close button
                          InkWell(
                            onTap: onClose,
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: isDark
                                    ? AppColors.textMutedDark
                                    : AppColors.textMutedLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        destination.name,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              '${destination.city}, ${destination.state}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'From ${Formatters.formatCurrency(destination.estimatedDailyCost)} / day',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: palette.currentPrimary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Actions Row
          Container(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                // Wishlist Toggle Button
                IconButton.filledTonal(
                  icon: Icon(
                    isWishlisted
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isWishlisted ? AppColors.terracotta : null,
                    size: 20,
                  ),
                  tooltip: isWishlisted
                      ? 'Remove from Wishlist'
                      : 'Save to Wishlist',
                  onPressed: () {
                    wishlistProvider.toggleWishlist(destination.id);
                  },
                ),
                const SizedBox(width: 8),
                // Add to Trip Button
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add_location_alt_rounded, size: 16),
                    label: const Text(
                      'Add to Trip',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: palette.currentPrimary(isDark),
                      side: BorderSide(color: palette.currentPrimary(isDark)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () => _showAddToTripSheet(context),
                  ),
                ),
                const SizedBox(width: 8),
                // View Details Button
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: const Text(
                      'Details',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.currentPrimary(isDark),
                      foregroundColor: palette.onPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () {
                      context.push('/destination/${destination.id}');
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
