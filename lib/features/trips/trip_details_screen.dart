import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/expense.dart';
import '../../models/itinerary_activity.dart';
import '../../models/trip.dart';
import '../../providers/destination_provider.dart';
import '../../providers/trip_provider.dart';
import '../../services/maps_service.dart';
import '../../widgets/empty_state_view.dart';
import 'add_edit_activity_dialog.dart';
import 'add_edit_expense_dialog.dart';
import 'create_edit_trip_dialog.dart';
import 'trip_itinerary_map_view.dart';

class TripDetailsScreen extends StatefulWidget {
  final String tripId;

  const TripDetailsScreen({super.key, required this.tripId});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmation(BuildContext context, Trip trip) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Trip?'),
        content: Text(
          'Are you sure you want to delete "${trip.title}" and all its itinerary activities and expenses? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<TripProvider>().deleteTrip(trip.id);
              if (mounted) {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Trip deleted.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tripProvider = context.watch<TripProvider>();
    final trip = tripProvider.getTripById(widget.tripId);

    if (trip == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Trip')),
        body: const Center(child: Text('Trip not found or has been deleted.')),
      );
    }

    final activities = tripProvider.getActivitiesForTrip(trip.id);
    final expenses = tripProvider.getExpensesForTrip(trip.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(trip.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Trip',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => CreateEditTripDialog(tripToEdit: trip),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Delete Trip',
            onPressed: () => _showDeleteConfirmation(context, trip),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          tabs: [
            Tab(
              icon: const Icon(Icons.calendar_today_rounded, size: 18),
              text: 'Itinerary (${activities.length})',
            ),
            Tab(
              icon: const Icon(Icons.account_balance_wallet_rounded, size: 18),
              text: 'Budget (${expenses.length})',
            ),
            const Tab(
              icon: Icon(Icons.map_rounded, size: 18),
              text: 'Trip Map',
            ),
            const Tab(
              icon: Icon(Icons.info_outline_rounded, size: 18),
              text: 'Overview',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Day-by-Day Itinerary
          _buildItineraryTab(context, trip, activities, isDark),

          // Tab 2: Budget & Expenses
          _buildBudgetTab(context, trip, expenses, isDark),

          // Tab 3: Route & Stop Map
          TripItineraryMapView(
            trip: trip,
            activities: activities,
            selectedDayNumber: _selectedDayIndex + 1,
          ),

          // Tab 4: Overview & Notes
          _buildOverviewTab(context, trip, isDark),
        ],
      ),
    );
  }

  // --- TAB 1: ITINERARY ---
  Widget _buildItineraryTab(
    BuildContext context,
    Trip trip,
    List<ItineraryActivity> allActivities,
    bool isDark,
  ) {
    final totalDays = trip.totalDays;
    final currentDayNumber = _selectedDayIndex + 1;
    final dayActivities = allActivities
        .where((a) => a.dayNumber == currentDayNumber)
        .toList();
    final tripProvider = context.read<TripProvider>();

    return Column(
      children: [
        // Day Selector Horizontal Tabs
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.warmCream,
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppColors.dividerDark : AppColors.creamBorder,
              ),
            ),
          ),
          height: 68,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: totalDays,
            itemBuilder: (context, index) {
              final dayNum = index + 1;
              final isSelected = _selectedDayIndex == index;
              final date = trip.startDate.add(Duration(days: index));
              final dayActsCount = allActivities
                  .where((a) => a.dayNumber == dayNum)
                  .length;

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () => setState(() => _selectedDayIndex = index),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                                ? AppColors.mutedSage
                                : AppColors.forestGreen)
                          : (isDark
                                ? AppColors.backgroundDark
                                : AppColors.creamSurface),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: isSelected
                            ? (isDark
                                  ? AppColors.mutedSage
                                  : AppColors.forestGreen)
                            : (isDark
                                  ? AppColors.dividerDark
                                  : AppColors.creamBorder),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Day $dayNum',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight),
                          ),
                        ),
                        Text(
                          '${date.day} ${Formatters.formatShortDate(date).split(' ').last} • $dayActsCount acts',
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected
                                ? Colors.white70
                                : (isDark
                                      ? AppColors.textMutedDark
                                      : AppColors.textMutedLight),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Day Activities List
        Expanded(
          child: dayActivities.isEmpty
              ? EmptyStateView(
                  icon: Icons.event_note_rounded,
                  title: 'No Activities for Day $currentDayNumber',
                  message: 'Plan your day by adding sightseeing, water sports, local dining, or sunset views.',
                  buttonText: 'Add First Activity',
                  onButtonPressed: () =>
                      _openAddActivityDialog(context, trip, currentDayNumber),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: dayActivities.length,
                  itemBuilder: (context, index) {
                    final act = dayActivities[index];
                    return _buildActivityCard(
                      context,
                      trip,
                      act,
                      isDark,
                      tripProvider,
                    );
                  },
                ),
        ),

        // Bottom Add Activity Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.warmCream,
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.dividerDark : AppColors.creamBorder,
              ),
            ),
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded),
                label: Text('Add Activity to Day $currentDayNumber'),
                onPressed: () =>
                    _openAddActivityDialog(context, trip, currentDayNumber),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    Trip trip,
    ItineraryActivity act,
    bool isDark,
    TripProvider tripProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.creamSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.creamBorder,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Checkbox(
          value: act.isCompleted,
          activeColor: isDark ? AppColors.mutedSage : AppColors.forestGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (_) {
            if (trip.isUpcoming) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Activities can only be completed once the trip begins on ${Formatters.formatShortDate(trip.startDate)}',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }
            tripProvider.toggleActivityCompleted(act.id);
          },
        ),
        title: Text(
          act.title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            decoration: act.isCompleted ? TextDecoration.lineThrough : null,
            color: act.isCompleted
                ? (isDark ? AppColors.textMutedDark : AppColors.textMutedLight)
                : (isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Row(
              children: [
                if (act.time != null && act.time!.isNotEmpty) ...[
                  const Icon(
                    Icons.access_time_rounded,
                    size: 12,
                    color: AppColors.primaryLight,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    act.time!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryLight,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (act.locationName.isNotEmpty) ...[
                  Icon(
                    Icons.location_on_outlined,
                    size: 12,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      act.locationName,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            if (act.notes != null && act.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                act.notes!,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (act.locationName.isNotEmpty)
              IconButton(
                icon: const Icon(
                  Icons.directions_rounded,
                  color: AppColors.secondary,
                  size: 20,
                ),
                tooltip: 'Open in Maps',
                onPressed: () {
                  if (act.latitude != null && act.longitude != null) {
                    MapsService.openLocation(
                      latitude: act.latitude!,
                      longitude: act.longitude!,
                      label: act.title,
                    );
                  } else {
                    MapsService.openSearch(act.locationName);
                  }
                },
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              onPressed: () {
                tripProvider.deleteActivity(act.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openAddActivityDialog(
    BuildContext context,
    Trip trip,
    int dayNumber,
  ) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) =>
          AddEditActivityDialog(trip: trip, defaultDay: dayNumber),
    );

    if (result != null && mounted) {
      await context.read<TripProvider>().addActivity(
        tripId: trip.id,
        dayNumber: result['dayNumber'] as int,
        date: result['date'] as DateTime,
        title: result['title'] as String,
        locationName: result['locationName'] as String,
        time: result['time'] as String?,
        notes: result['notes'] as String?,
      );
    }
  }

  // --- TAB 2: BUDGET & EXPENSES ---
  Widget _buildBudgetTab(
    BuildContext context,
    Trip trip,
    List<Expense> expenses,
    bool isDark,
  ) {
    final tripProvider = context.watch<TripProvider>();
    final destProvider = context.watch<DestinationProvider>();
    final dest = trip.destinationId != null
        ? destProvider.findById(trip.destinationId!)
        : null;
    final estimatedTripCost = dest != null
        ? (dest.estimatedDailyCost * trip.durationDays)
        : null;
    final totalSpent = tripProvider.getTotalSpentForTrip(trip.id);
    final remaining = tripProvider.getRemainingBudget(trip.id);
    final usageFraction = tripProvider.getBudgetUsageFraction(trip.id);
    final isOver = tripProvider.isOverBudget(trip.id);
    final categoryTotals = tripProvider.getCategorySpendingForTrip(trip.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Budget Summary Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isOver
                    ? [const Color(0xFFC24D3D), const Color(0xFF8B2B1E)]
                    : [AppColors.forestGreen, const Color(0xFF265A4D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: [
                BoxShadow(
                  color: (isOver ? AppColors.error : AppColors.forestGreen)
                      .withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL SPENT',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Budget: ${Formatters.formatCurrency(trip.plannedBudget)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  Formatters.formatCurrency(totalSpent),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: usageFraction,
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isOver
                          ? 'Over budget by ${Formatters.formatCurrency(totalSpent - trip.plannedBudget)}!'
                          : 'Remaining: ${Formatters.formatCurrency(remaining)}',
                      style: TextStyle(
                        color: isOver ? Colors.amberAccent : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${(usageFraction * 100).toInt()}% Used',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Budget Benchmark vs Actual Breakdown
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.warmCream,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isDark ? AppColors.dividerDark : AppColors.creamBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 16,
                      color:
                          isDark ? AppColors.mutedSage : AppColors.forestGreen,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Cost Breakdown & Spend Integrity',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildSpendingColumn(
                        isDark: isDark,
                        label: 'Estimated Cost',
                        amount: estimatedTripCost != null
                            ? Formatters.formatCurrency(estimatedTripCost)
                            : 'N/A',
                        hint: 'Guide Benchmark',
                        color: isDark
                            ? AppColors.mutedSage
                            : AppColors.mutedSageDark,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 38,
                      color: isDark
                          ? AppColors.dividerDark
                          : AppColors.creamBorder,
                    ),
                    Expanded(
                      child: _buildSpendingColumn(
                        isDark: isDark,
                        label: 'Planned Budget',
                        amount: Formatters.formatCurrency(trip.plannedBudget),
                        hint: 'Target Limit',
                        color: isDark
                            ? AppColors.warmCream
                            : AppColors.forestGreen,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 38,
                      color: isDark
                          ? AppColors.dividerDark
                          : AppColors.creamBorder,
                    ),
                    Expanded(
                      child: _buildSpendingColumn(
                        isDark: isDark,
                        label: 'Actual Spent',
                        amount: Formatters.formatCurrency(totalSpent),
                        hint: 'Logged Expenses',
                        color: isOver ? AppColors.error : AppColors.terracotta,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '💡 Estimated destination costs are reference benchmarks and are never counted as actual spending.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.3,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          // 3. Category Spending Chips
          const SizedBox(height: 24),
          Text(
            'Spending by Category',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2,
            ),
            itemCount: AppConstants.expenseCategories.length,
            itemBuilder: (context, i) {
              final cat = AppConstants.expenseCategories[i];
              final catSpent = categoryTotals[cat] ?? 0.0;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
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
                  children: [
                    Icon(
                      _getCategoryIcon(cat),
                      size: 20,
                      color:
                          isDark ? AppColors.mutedSage : AppColors.forestGreen,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            cat,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            Formatters.formatCurrency(catSpent),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // 3. Expense History
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Expense Log (${expenses.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add Expense'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => _openAddExpenseDialog(context, trip),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (expenses.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: Text(
                'No expenses recorded yet. Tap "Add Expense" to track hotel, food, travel or activities.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final exp = expenses[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
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
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: isDark
                          ? AppColors.surfaceDark
                          : AppColors.mutedSageLight,
                      child: Icon(
                        _getCategoryIcon(exp.category),
                        color: isDark
                            ? AppColors.mutedSage
                            : AppColors.forestGreen,
                        size: 18,
                      ),
                    ),
                    title: Text(
                      exp.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${exp.category} • ${Formatters.formatShortDate(exp.date)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          Formatters.formatCurrency(exp.amount),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                          ),
                          onPressed: () {
                            tripProvider.deleteExpense(exp.id);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _openAddExpenseDialog(BuildContext context, Trip trip) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AddEditExpenseDialog(trip: trip),
    );

    if (result != null && mounted) {
      await context.read<TripProvider>().addExpense(
        tripId: trip.id,
        title: result['title'] as String,
        amount: result['amount'] as double,
        category: result['category'] as String,
        date: result['date'] as DateTime,
        notes: result['notes'] as String?,
      );
    }
  }

  // --- TAB 3: OVERVIEW ---
  Widget _buildOverviewTab(BuildContext context, Trip trip, bool isDark) {
    final destProvider = context.watch<DestinationProvider>();
    final linkedDest = trip.destinationId != null
        ? destProvider.findById(trip.destinationId!)
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Destination Info Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.creamSurface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: isDark ? AppColors.dividerDark : AppColors.creamBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Destination Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.map_rounded, size: 14),
                      label: const Text(
                        'Open Maps',
                        style: TextStyle(fontSize: 11),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.forestGreen,
                        side: BorderSide(
                          color: isDark
                              ? AppColors.dividerDark
                              : AppColors.forestGreen.withOpacity(0.4),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        if (linkedDest != null) {
                          MapsService.openLocation(
                            latitude: linkedDest.latitude,
                            longitude: linkedDest.longitude,
                            label: linkedDest.name,
                          );
                        } else {
                          MapsService.openSearch(trip.destinationName);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: AppColors.forestGreen,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      trip.destinationName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.date_range_rounded,
                      size: 16,
                      color: AppColors.forestGreen,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${Formatters.formatDateRange(trip.startDate, trip.endDate)} (${trip.totalDays} Days)',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.people_alt_rounded,
                      size: 16,
                      color: AppColors.forestGreen,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${trip.numberOfTravelers} Travelers • Style: ${trip.travelStyle}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Trip Notes
          if (trip.notes != null && trip.notes!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.creamSurface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: isDark
                      ? AppColors.dividerDark
                      : AppColors.terracotta.withOpacity(0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.notes_rounded,
                        color: AppColors.terracotta,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Trip Notes & Reminders',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    trip.notes!,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Quick Link to Full Destination Guide if available
          if (linkedDest != null) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.explore_rounded),
              label: Text('View Full Destination Guide for ${linkedDest.name}'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () {
                context.push('/destination/${linkedDest.id}');
              },
            ),
          ],
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case AppConstants.expenseAccommodation:
        return Icons.hotel_rounded;
      case AppConstants.expenseFood:
        return Icons.restaurant_rounded;
      case AppConstants.expenseTransport:
        return Icons.directions_car_rounded;
      case AppConstants.expenseActivities:
        return Icons.local_activity_rounded;
      case AppConstants.expenseShopping:
        return Icons.shopping_bag_rounded;
      case AppConstants.expenseMiscellaneous:
      default:
        return Icons.receipt_long_rounded;
    }
  }

  Widget _buildSpendingColumn({
    required bool isDark,
    required String label,
    required String amount,
    required String hint,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 3),
        Text(
          amount,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          hint,
          style: TextStyle(
            fontSize: 9.5,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
