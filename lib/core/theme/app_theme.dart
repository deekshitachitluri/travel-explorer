import 'package:flutter/material.dart';

class CategoryPalette {
  final String categoryName;
  final Color backgroundTint;
  final Color surfaceVariant;
  final Color primary;
  final Color secondary;
  final Color onPrimary;
  final Color cardBorder;
  final Color badgeBackground;
  final Color badgeText;

  // Dark mode specific colors
  final Color darkSurface;
  final Color darkPrimary;
  final Color darkAccent;

  const CategoryPalette({
    required this.categoryName,
    required this.backgroundTint,
    required this.surfaceVariant,
    required this.primary,
    required this.secondary,
    this.onPrimary = Colors.white,
    required this.cardBorder,
    required this.badgeBackground,
    required this.badgeText,
    required this.darkSurface,
    required this.darkPrimary,
    required this.darkAccent,
  });

  static const beaches = CategoryPalette(
    categoryName: 'Beaches',
    backgroundTint: Color(0xFFFAF5EC), // Ivory Sand
    surfaceVariant: Color(0xFFE5DAC7), // Warm Sand
    primary: Color(0xFF1B4E41), // Coastal Pine / Forest
    secondary: Color(0xFFD18A61), // Terracotta Accent
    onPrimary: Colors.white,
    cardBorder: Color(0xFFE5DBC7),
    badgeBackground: Color(0xFFF1E7D5),
    badgeText: Color(0xFF173F35),
    darkSurface: Color(0xFF16221D),
    darkPrimary: Color(0xFF75BBAA),
    darkAccent: Color(0xFFD18A61),
  );

  static const mountains = CategoryPalette(
    categoryName: 'Mountains',
    backgroundTint: Color(0xFFF2F5ED), // Alpine Mist Cream
    surfaceVariant: Color(0xFFD6E0CF), // Soft Pine Sage
    primary: Color(0xFF173F35), // Forest Green
    secondary: Color(0xFFA9B99A), // Muted Sage
    onPrimary: Colors.white,
    cardBorder: Color(0xFFD7E2D0),
    badgeBackground: Color(0xFFE3EDE0),
    badgeText: Color(0xFF173F35),
    darkSurface: Color(0xFF14201A),
    darkPrimary: Color(0xFF6FBA94),
    darkAccent: Color(0xFFA9B99A),
  );

  static const heritage = CategoryPalette(
    categoryName: 'Heritage',
    backgroundTint: Color(0xFFFAF3EC), // Warm Sandstone
    surfaceVariant: Color(0xFFEAD8C7), // Baked Earth
    primary: Color(0xFFD18A61), // Terracotta
    secondary: Color(0xFF173F35), // Forest Green
    onPrimary: Colors.white,
    cardBorder: Color(0xFFE8D3C0),
    badgeBackground: Color(0xFFF4E3D4),
    badgeText: Color(0xFF884926),
    darkSurface: Color(0xFF261D1A),
    darkPrimary: Color(0xFFE29E77),
    darkAccent: Color(0xFFE8BCA0),
  );

  static const adventure = CategoryPalette(
    categoryName: 'Adventure',
    backgroundTint: Color(0xFFEFF5F1), // Forest Stream
    surfaceVariant: Color(0xFFCEE0D5), // River Stone
    primary: Color(0xFF1D5447), // Wild Forest
    secondary: Color(0xFFA9B99A), // Muted Sage
    onPrimary: Colors.white,
    cardBorder: Color(0xFFD0E1D5),
    badgeBackground: Color(0xFFDFEDE4),
    badgeText: Color(0xFF173F35),
    darkSurface: Color(0xFF15231E),
    darkPrimary: Color(0xFF5AB69D),
    darkAccent: Color(0xFFA9B99A),
  );

  static const spiritual = CategoryPalette(
    categoryName: 'Spiritual',
    backgroundTint: Color(0xFFFAF6EC), // Sacred Sandalwood Cream
    surfaceVariant: Color(0xFFF3E7D3), // Golden Ochre Tint
    primary: Color(0xFFC07A3E), // Sacred Ochre / Amber
    secondary: Color(0xFF173F35), // Forest Green
    onPrimary: Colors.white,
    cardBorder: Color(0xFFE9DCBA),
    badgeBackground: Color(0xFFF8ECD8),
    badgeText: Color(0xFF8C5222),
    darkSurface: Color(0xFF231F1A),
    darkPrimary: Color(0xFFE8AB73),
    darkAccent: Color(0xFFD18A61),
  );

  static const neutral = CategoryPalette(
    categoryName: 'All',
    backgroundTint: Color(0xFFF7F3E9), // Warm Cream
    surfaceVariant: Color(0xFFE8E0D2), // Cream Neutral
    primary: Color(0xFF173F35), // Forest Green
    secondary: Color(0xFFA9B99A), // Muted Sage
    onPrimary: Colors.white,
    cardBorder: Color(0xFFE2DACE),
    badgeBackground: Color(0xFFEDE5D8),
    badgeText: Color(0xFF173F35),
    darkSurface: Color(0xFF19231E),
    darkPrimary: Color(0xFF75B29B),
    darkAccent: Color(0xFFA9B99A),
  );

  static CategoryPalette forCategory(String? category) {
    if (category == null) return neutral;
    switch (category.toLowerCase()) {
      case 'beaches':
        return beaches;
      case 'mountains':
        return mountains;
      case 'heritage':
        return heritage;
      case 'adventure':
        return adventure;
      case 'spiritual':
        return spiritual;
      default:
        return neutral;
    }
  }

  Color currentPrimary(bool isDark) => isDark ? darkPrimary : primary;
  Color currentSurface(bool isDark) => isDark ? darkSurface : backgroundTint;
  Color currentBorder(bool isDark) =>
      isDark ? darkAccent.withValues(alpha: 0.3) : cardBorder;
}

class AppColors {
  // Signature Forest & Cream Palette (Master Requirements)
  static const Color forestGreen = Color(0xFF173F35);
  static const Color forestGreenLight = Color(0xFF265A4D);
  static const Color forestGreenDark = Color(0xFF0F2B24);

  static const Color warmCream = Color(0xFFF7F3E9);
  static const Color creamSurface = Color(
    0xFFFCFAF5,
  ); // Crisp warm card surface
  static const Color creamBorder = Color(0xFFE5DFD3);

  static const Color mutedSage = Color(0xFFA9B99A);
  static const Color mutedSageLight = Color(0xFFDDE5D5);
  static const Color mutedSageDark = Color(0xFF6E7E60);

  static const Color terracotta = Color(0xFFD18A61);
  static const Color terracottaLight = Color(0xFFF4D8C7);
  static const Color terracottaDark = Color(0xFF9E542D);

  static const Color charcoal = Color(0xFF252923);
  static const Color charcoalMuted = Color(0xFF5D6559);
  static const Color charcoalLight = Color(0xFF8B9487);

  // Core Functional Aliases
  static const Color primary = forestGreen;
  static const Color primaryLight = forestGreenLight;
  static const Color primaryDark = forestGreenDark;
  static const Color secondary = mutedSage;
  static const Color secondaryLight = mutedSageLight;
  static const Color sageGreen = mutedSage;
  static const Color darkBorder = dividerDark;
  static const Color borderDark = dividerDark;

  // Soft Warm Foundations
  static const Color backgroundLight = warmCream;
  static const Color surfaceLight = creamSurface;
  static const Color cardLight = creamSurface;
  static const Color dividerLight = creamBorder;

  // Dark Neutrals (Grounded forest night)
  static const Color backgroundDark = Color(0xFF131A16);
  static const Color surfaceDark = Color(0xFF1C2520);
  static const Color cardDark = Color(0xFF212C26);
  static const Color dividerDark = Color(0xFF2F3C34);

  // Typography - High legibility charcoal & cream
  static const Color textPrimaryLight = charcoal;
  static const Color textSecondaryLight = charcoalMuted;
  static const Color textMutedLight = charcoalLight;

  static const Color textPrimaryDark = warmCream;
  static const Color textSecondaryDark = Color(0xFFC7D0C2);
  static const Color textMutedDark = Color(0xFF889582);

  // Semantic Status Colors
  static const Color success = Color(0xFF2E7D5D);
  static const Color warning = terracotta;
  static const Color error = Color(0xFFC24D3D);
  static const Color info = Color(0xFF2C6B61);

  // Rating Stars, Badges & Highlights
  static const Color accentAmber = terracotta;
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 999.0;
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.forestGreen,
      scaffoldBackgroundColor: AppColors.warmCream,
      colorScheme: const ColorScheme.light(
        primary: AppColors.forestGreen,
        onPrimary: AppColors.warmCream,
        secondary: AppColors.mutedSage,
        onSecondary: AppColors.charcoal,
        tertiary: AppColors.terracotta,
        surface: AppColors.creamSurface,
        onSurface: AppColors.charcoal,
        error: AppColors.error,
        onError: Colors.white,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.warmCream,
        foregroundColor: AppColors.charcoal,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.charcoal,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.creamSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.creamBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.forestGreen,
          foregroundColor: AppColors.warmCream,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.forestGreen,
          side: const BorderSide(color: AppColors.forestGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.forestGreen,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.creamSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.creamBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.creamBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(
            color: AppColors.forestGreen,
            width: 1.8,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: const TextStyle(
          color: AppColors.charcoalLight,
          fontSize: 14,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.warmCream,
        selectedItemColor: AppColors.forestGreen,
        unselectedItemColor: AppColors.charcoalMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        indicatorColor: AppColors.forestGreen,
        labelColor: AppColors.forestGreen,
        unselectedLabelColor: AppColors.charcoalMuted,
        labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.warmCream,
        disabledColor: AppColors.creamBorder,
        selectedColor: AppColors.mutedSageLight,
        secondarySelectedColor: AppColors.forestGreen,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        labelStyle: const TextStyle(fontSize: 12, color: AppColors.charcoal),
        secondaryLabelStyle: const TextStyle(
          fontSize: 12,
          color: AppColors.warmCream,
        ),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          side: const BorderSide(color: AppColors.creamBorder),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.forestGreen,
        foregroundColor: AppColors.warmCream,
        elevation: 4,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.mutedSage,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.mutedSage,
        onPrimary: AppColors.charcoal,
        secondary: Color(0xFF6FBA94),
        onSecondary: Colors.black,
        tertiary: AppColors.terracotta,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.warmCream,
        error: AppColors.error,
        onError: Colors.black,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.dividerDark, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mutedSage,
          foregroundColor: AppColors.charcoal,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.dividerDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.dividerDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.mutedSage, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: const TextStyle(
          color: AppColors.textMutedDark,
          fontSize: 14,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.mutedSage,
        unselectedItemColor: AppColors.textMutedDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        indicatorColor: AppColors.mutedSage,
        labelColor: AppColors.mutedSage,
        unselectedLabelColor: AppColors.textMutedDark,
        labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceDark,
        disabledColor: AppColors.dividerDark,
        selectedColor: AppColors.forestGreenDark,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        labelStyle: const TextStyle(fontSize: 12, color: AppColors.warmCream),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          side: const BorderSide(color: AppColors.dividerDark),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.mutedSage,
        foregroundColor: AppColors.charcoal,
        elevation: 4,
      ),
    );
  }
}
