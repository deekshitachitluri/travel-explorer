import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../features/assistant/travel_buddy_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/destination_details/destination_details_screen.dart';
import '../../features/explore/explore_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/map/explore_map_screen.dart';
import '../../features/matcher/travel_matcher_screen.dart';
import '../../features/navigation/main_scaffold.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/settings/firebase_guide_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/trips/trip_details_screen.dart';
import '../../features/trips/trips_screen.dart';
import '../../features/wishlist/wishlist_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  errorBuilder: (context, state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.charcoal : AppColors.warmCream,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.explore_off_outlined,
                size: 72,
                color: isDark ? AppColors.mutedSage : AppColors.forestGreen,
              ),
              const SizedBox(height: 16),
              Text(
                'Page Not Found',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.creamSurface
                      : AppColors.forestGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The requested journey could not be located.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark
                      ? AppColors.creamSurface.withValues(alpha: 0.7)
                      : AppColors.charcoal.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.mutedSage
                      : AppColors.forestGreen,
                  foregroundColor: isDark
                      ? AppColors.charcoal
                      : AppColors.warmCream,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Back to Home'),
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ),
    );
  },
  routes: [
    // Root route redirect to /home
    GoRoute(path: '/', redirect: (context, state) => '/home'),

    // Plural alias redirect to singular destination route
    GoRoute(
      path: '/destinations/:id',
      redirect: (context, state) =>
          '/destination/${state.pathParameters['id']}',
    ),

    // ShellRoute with persistent bottom navigation
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: '/explore',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ExploreScreen()),
        ),
        GoRoute(
          path: '/trips',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: TripsScreen()),
        ),
        GoRoute(
          path: '/wishlist',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: WishlistScreen()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ProfileScreen()),
        ),
      ],
    ),

    // Sub-routes outside shell
    GoRoute(
      path: '/destination/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return DestinationDetailsScreen(destinationId: id);
      },
    ),
    GoRoute(
      path: '/trip/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return TripDetailsScreen(tripId: id);
      },
    ),
    GoRoute(
      path: '/travel-buddy',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const TravelBuddyScreen(),
    ),
    GoRoute(
      path: '/matcher',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const TravelMatcherScreen(),
    ),
    GoRoute(
      path: '/map',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final destId = state.uri.queryParameters['destinationId'];
        final spotId = state.uri.queryParameters['spotId'];
        final attractionName = state.uri.queryParameters['attractionName'];
        final attractionLat = double.tryParse(
          state.uri.queryParameters['attractionLat'] ?? '',
        );
        final attractionLng = double.tryParse(
          state.uri.queryParameters['attractionLng'] ?? '',
        );
        final parentDestName =
            state.uri.queryParameters['parentDestinationName'];
        final attractionDesc = state.uri.queryParameters['attractionDesc'];
        final attractionImg = state.uri.queryParameters['attractionImg'];

        return ExploreMapScreen(
          initialDestinationId: destId,
          initialSpotId: spotId,
          attractionName: attractionName,
          attractionLatitude: attractionLat,
          attractionLongitude: attractionLng,
          parentDestinationName: parentDestName,
          attractionDescription: attractionDesc,
          attractionImageUrl: attractionImg,
        );
      },
    ),
    GoRoute(
      path: '/login',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/firebase-guide',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const FirebaseGuideScreen(),
    ),
  ],
);
