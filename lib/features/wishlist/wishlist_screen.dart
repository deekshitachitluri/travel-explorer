import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/destination.dart';
import '../../providers/destination_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/rating_badge.dart';
import '../trips/create_edit_trip_dialog.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wishlistProvider = context.watch<WishlistProvider>();
    final destProvider = context.watch<DestinationProvider>();

    final savedDestinations = wishlistProvider.getWishlistedDestinations(
      destProvider.allDestinations,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('My Wishlist (${savedDestinations.length})'),
        actions: [
          if (savedDestinations.isNotEmpty)
            TextButton(
              onPressed: () {
                _showClearConfirmation(context, wishlistProvider);
              },
              child: const Text('Clear All'),
            ),
        ],
      ),
      body: savedDestinations.isEmpty
          ? EmptyStateView(
              icon: Icons.favorite_border_rounded,
              title: 'Your Wishlist is Empty',
              message: 'Discover breathtaking beaches, misty mountains, and historical forts across India and tap the heart icon to save them here.',
              buttonText: 'Explore Destinations',
              onButtonPressed: () => context.go('/explore'),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: savedDestinations.length,
              itemBuilder: (context, index) {
                final dest = savedDestinations[index];
                return _buildWishlistItem(
                  context,
                  dest,
                  isDark,
                  wishlistProvider,
                );
              },
            ),
    );
  }

  Widget _buildWishlistItem(
    BuildContext context,
    Destination dest,
    bool isDark,
    WishlistProvider wishlistProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.creamSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.creamBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            context.push('/destination/${dest.id}');
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image with rating overlay
              Stack(
                children: [
                  AppNetworkImage(
                    imageUrl: dest.imageUrl,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: RatingBadge(rating: dest.rating, compact: true),
                  ),
                ],
              ),

              // Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: dest.palette.badgeBackground,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(
                                color: dest.palette.cardBorder,
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              dest.category.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: dest.palette.badgeText,
                              ),
                            ),
                          ),
                          // Quick Remove heart
                          InkWell(
                            onTap: () {
                              wishlistProvider.removeFromWishlist(dest.id);
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Removed ${dest.name} from Wishlist',
                                  ),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.favorite_rounded,
                                color: AppColors.terracotta,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dest.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${dest.city}, ${dest.state}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${Formatters.formatCurrency(dest.estimatedDailyCost)}/day',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: dest.palette.currentPrimary(isDark),
                            ),
                          ),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.add_rounded, size: 14),
                            label: const Text(
                              'Add to Trip',
                              style: TextStyle(fontSize: 11),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: dest.palette.currentPrimary(
                                isDark,
                              ),
                              side: BorderSide(
                                color: dest.palette.currentPrimary(isDark),
                                width: 1,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (dialogCtx) => CreateEditTripDialog(
                                  initialDestinationId: dest.id,
                                  initialDestinationName:
                                      '${dest.name}, ${dest.state}',
                                  initialImage: dest.imageUrl,
                                  initialBudget:
                                      dest.estimatedDailyCost *
                                      dest.suggestedDurationDays,
                                ),
                              );
                            },
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
    );
  }

  void _showClearConfirmation(BuildContext context, WishlistProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Wishlist?'),
        content: const Text(
          'Are you sure you want to remove all destinations from your wishlist?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              for (final id in provider.wishlistIds.toList()) {
                provider.removeFromWishlist(id);
              }
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
