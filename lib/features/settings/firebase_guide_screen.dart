import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class FirebaseGuideScreen extends StatelessWidget {
  const FirebaseGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Setup Guide')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.creamSurface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: isDark
                      ? AppColors.dividerDark
                      : AppColors.mutedSage.withOpacity(0.4),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.forestGreen,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'The application currently runs in Local Storage & Guest Mode to allow immediate offline evaluation without requiring external cloud credentials.',
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'How to Connect Your Own Firebase Project',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 16),

            _buildStepCard(
              context,
              step: '1',
              title: 'Create a Firebase Project',
              body: 'Go to the Firebase Console (console.firebase.google.com) and click "Add project". Name your project "travel-explorer-gdgc".',
              isDark: isDark,
            ),
            const SizedBox(height: 12),

            _buildStepCard(
              context,
              step: '2',
              title: 'Enable Email/Password Authentication',
              body: 'In the Firebase Console sidebar, navigate to Build > Authentication > Sign-in method, select "Email/Password", and toggle "Enable".',
              isDark: isDark,
            ),
            const SizedBox(height: 12),

            _buildStepCard(
              context,
              step: '3',
              title: 'Register Android App',
              body: '1. Add an Android app with package name:\n   com.gdgc.travelexplorer\n2. Download the generated google-services.json file.\n3. Move google-services.json to android/app/google-services.json in this project.',
              isDark: isDark,
            ),
            const SizedBox(height: 12),

            _buildStepCard(
              context,
              step: '4',
              title: 'Install FlutterFire CLI (Optional for Web)',
              body: 'Run:\n`dart pub global activate flutterfire_cli`\n`flutterfire configure`\nThis automatically configures lib/firebase_options.dart.',
              isDark: isDark,
            ),
            const SizedBox(height: 12),

            _buildStepCard(
              context,
              step: '5',
              title: 'Switching AuthService to Firebase',
              body: 'In lib/services/auth_service.dart, implement the FirebaseAuthService class using FirebaseAuth.instance.signInWithEmailAndPassword and replace LocalAuthService in main.dart.',
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(
    BuildContext context, {
    required String step,
    required String title,
    required String body,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.creamSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.creamBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.forestGreen,
            child: Text(
              step,
              style: const TextStyle(
                color: AppColors.warmCream,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
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
}
