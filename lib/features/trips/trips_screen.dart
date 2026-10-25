import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/trip.dart';
import '../../providers/trip_provider.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/empty_state_view.dart';
import 'create_edit_trip_dialog.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tripProvider = context.watch<TripProvider>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Trips & Itineraries'),
          bottom: TabBar(
            indicatorColor: isDark
                ? AppColors.mutedSage
                : AppColors.forestGreen,
            labelColor: isDark ? AppColors.mutedSage : AppColors.forestGreen,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700),
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Ongoing'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTripList(
              context,
              tripProvider.upcomingTrips,
              'No upcoming trips planned yet.',
            ),
            _buildTripList(
              context,
              tripProvider.ongoingTrips,
              'No trips currently underway.',
            ),
            _buildTripList(
              context,
              tripProvider.pastTrips,
              'No completed trips in your history.',
            ),
          ],
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton.small(
              heroTag: 'trips_travel_buddy_fab',
              tooltip: 'Ask Travel Buddy',
              backgroundColor: isDark
                  ? AppColors.mutedSage
                  : AppColors.forestGreen,
              foregroundColor: isDark
                  ? AppColors.charcoal
                  : AppColors.warmCream,
              onPressed: () => context.push('/travel-buddy'),
              child: const Text('🌿', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 12),
            FloatingActionButton.extended(
              heroTag: 'trips_plan_trip_fab',
              backgroundColor: isDark
                  ? AppColors.mutedSage
                  : AppColors.forestGreen,
              foregroundColor: isDark
                  ? AppColors.charcoal
                  : AppColors.warmCream,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Plan Trip'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => const CreateEditTripDialog(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripList(
    BuildContext context,
    List<Trip> trips,
    String emptySubtitle,
  ) {
    if (trips.isEmpty) {
      return EmptyStateView(
        icon: Icons.luggage_rounded,
        title: 'No Trips Found',
        message: emptySubtitle,
        buttonText: 'Create a Trip',
        onButtonPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => const CreateEditTripDialog(),
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        return _buildTripCard(context, trip);
      },
    );
  }

  Widget _buildTripCard(BuildContext context, Trip trip) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tripProvider = context.watch<TripProvider>();

    final totalSpent = tripProvider.getTotalSpentForTrip(trip.id);
    final usageFraction = tripProvider.getBudgetUsageFraction(trip.id);
    final isOver = tripProvider.isOverBudget(trip.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.creamSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.creamBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            context.push('/trip/${trip.id}');
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner with Trip Name
              Stack(
                children: [
                  AppNetworkImage(
                    imageUrl: trip.destinationImage ?? 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?auto=format&fit=crop&w=800&q=80',
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        '${trip.totalDays} DAYS',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 14,
                    right: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 13,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                trip.destinationName,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Details & Budget Progress
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 13,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              Formatters.formatDateRange(
                                trip.startDate,
                                trip.endDate,
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.person_rounded,
                              size: 14,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${trip.numberOfTravelers} ${trip.numberOfTravelers == 1 ? 'Traveler' : 'Travelers'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Budget Bar - Distinct Planned Budget vs Actual Expenses
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Spent: ${Formatters.formatCurrency(totalSpent)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isOver
                                ? AppColors.error
                                : AppColors.terracotta,
                          ),
                        ),
                        Text(
                          'Planned Budget: ${Formatters.formatCurrency(trip.plannedBudget)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.mutedSage
                                : AppColors.forestGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: usageFraction.clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: isDark
                            ? AppColors.backgroundDark
                            : AppColors.mutedSageLight,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isOver
                              ? AppColors.error
                              : (usageFraction > 0.8
                                    ? AppColors.terracotta
                                    : AppColors.forestGreen),
                        ),
                      ),
                    ),
                    if (isOver) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Over budget by ${Formatters.formatCurrency(totalSpent - trip.plannedBudget)}!',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
