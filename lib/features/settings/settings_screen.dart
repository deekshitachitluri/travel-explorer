import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Appearance Section
          _buildSectionTitle(context, 'Appearance', isDark),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.creamSurface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: isDark ? AppColors.dividerDark : AppColors.creamBorder,
              ),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    themeProvider.isDarkMode
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: AppColors.forestGreen,
                  ),
                  title: const Text(
                    'Dark Mode',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    themeProvider.isDarkMode
                        ? 'Dark theme enabled'
                        : 'Forest & Cream theme enabled',
                  ),
                  value: themeProvider.isDarkMode,
                  onChanged: (val) {
                    themeProvider.toggleTheme();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Regional & Units
          _buildSectionTitle(context, 'Preferences & Units', isDark),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.creamSurface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: isDark ? AppColors.dividerDark : AppColors.creamBorder,
              ),
            ),
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.currency_rupee_rounded,
                    color: AppColors.forestGreen,
                  ),
                  title: Text(
                    'Currency',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: Text(
                    'INR (₹)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.thermostat_rounded,
                    color: AppColors.forestGreen,
                  ),
                  title: Text(
                    'Temperature Unit',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: Text(
                    'Celsius (°C)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // External Services & Integration
          _buildSectionTitle(context, 'Services & Integrations', isDark),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.creamSurface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: isDark ? AppColors.dividerDark : AppColors.creamBorder,
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.wb_sunny_rounded,
                    color: AppColors.terracotta,
                  ),
                  title: const Text(
                    'Live Weather Provider',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Open-Meteo Weather API (Real-time forecasts)',
                  ),
                  trailing: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.forestGreen,
                    size: 20,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.map_rounded,
                    color: AppColors.forestGreen,
                  ),
                  title: const Text(
                    'Maps Integration',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Embedded Interactive Maps (OSM) & Navigation',
                  ),
                  trailing: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.forestGreen,
                    size: 20,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.cloud_queue_rounded,
                    color: AppColors.mutedSage,
                  ),
                  title: const Text(
                    'Firebase Authentication',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'View configuration guide & setup steps',
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                  ),
                  onTap: () => context.push('/firebase-guide'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // About App
          _buildSectionTitle(context, 'About App', isDark),
          const SizedBox(height: 8),
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
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Version 1.0.0 (GDGC VNRVJIET App Development Assignment)',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  'A full-featured, photography-first travel discovery and itinerary planning application for India built with Flutter, Provider, GoRouter, SharedPreferences, and Open-Meteo.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
        letterSpacing: 0.5,
      ),
    );
  }
}
