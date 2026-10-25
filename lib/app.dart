import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/local/local_storage_service.dart';
import 'providers/auth_provider.dart';
import 'providers/destination_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/trip_provider.dart';
import 'providers/wishlist_provider.dart';
import 'services/auth_service.dart';

class TravelExplorerApp extends StatelessWidget {
  final LocalStorageService storageService;
  final AuthService authService;

  const TravelExplorerApp({
    super.key,
    required this.storageService,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(storageService)),
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProvider(
          create: (_) => DestinationProvider(storageService),
        ),
        ChangeNotifierProvider(create: (_) => WishlistProvider(storageService)),
        ChangeNotifierProvider(create: (_) => TripProvider(storageService)),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
