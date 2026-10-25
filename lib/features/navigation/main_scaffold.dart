import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/wishlist_provider.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/explore')) return 1;
    if (location.startsWith('/trips')) return 2;
    if (location.startsWith('/wishlist')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/explore');
        break;
      case 2:
        context.go('/trips');
        break;
      case 3:
        context.go('/wishlist');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wishlistProvider = context.watch<WishlistProvider>();
    final wishlistCount = wishlistProvider.count;
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      // Hide outer Travel Buddy FAB on Trips tab (index 2) where TripsScreen provides stacked actions
      floatingActionButton: selectedIndex == 2
          ? null
          : FloatingActionButton(
              heroTag: 'travel_buddy_fab',
              onPressed: () => context.push('/travel-buddy'),
              tooltip: 'Ask Travel Buddy',
              backgroundColor: isDark
                  ? AppColors.mutedSage
                  : AppColors.forestGreen,
              foregroundColor: isDark
                  ? AppColors.charcoal
                  : AppColors.warmCream,
              child: const Text('🌿', style: TextStyle(fontSize: 22)),
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.warmCream,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.dividerDark : AppColors.creamBorder,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF173F35).withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) => _onItemTapped(index, context),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore_rounded),
              label: 'Explore',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.luggage_outlined),
              activeIcon: Icon(Icons.luggage_rounded),
              label: 'My Trips',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: wishlistCount > 0,
                backgroundColor: AppColors.terracotta,
                textColor: Colors.white,
                label: Text(
                  '$wishlistCount',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Icon(Icons.favorite_outline_rounded),
              ),
              activeIcon: Badge(
                isLabelVisible: wishlistCount > 0,
                backgroundColor: AppColors.terracotta,
                textColor: Colors.white,
                label: Text(
                  '$wishlistCount',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Icon(Icons.favorite_rounded),
              ),
              label: 'Wishlist',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
