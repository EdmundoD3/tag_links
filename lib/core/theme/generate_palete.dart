import 'package:flutter/material.dart';
import 'package:tag_links/core/theme/app_theme.dart';

Map<AppPalette, ThemeData> _palettes = {
  AppPalette.light: AppTheme.lightTheme,
  AppPalette.dark: AppTheme.darkTheme,
  AppPalette.lavender: AppTheme.lavenderTheme,
  AppPalette.rosePastel: AppTheme.rosePastelTheme,
  AppPalette.arcticBlue: AppTheme.arcticBlueTheme,
  AppPalette.lavenderNight: AppTheme.lavenderNightTheme,
};

ThemeData getPalette({required AppPalette palette}) {
  final theme = _palettes[palette];
  return theme ?? _palettes[defaultTheme]!;
}

ThemeData generatePalette({
  required Color primary,
  required Color onPrimary,

  required Color accent,
  required Color highlight,

  required Color background,
  required Color surface,

  required Color text,
}) {
  final secondaryText = text.withValues(alpha: 0.75);
  final tertiaryText = text.withValues(alpha: 0.55);

  final searchInput = accent.withValues(alpha: 0.10);
  final searchBorder = accent.withValues(alpha: 0.35);

  return ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: background,
    canvasColor: background,

    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      onPrimary: onPrimary,
      surface: surface,
      onSurface: text,
    ),

    highlightColor: Colors.transparent,

    appBarTheme: AppBarTheme(
      backgroundColor: primary,
      foregroundColor: onPrimary,
      titleTextStyle: TextStyle(
        color: onPrimary,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),

    textTheme: TextTheme(
      titleLarge: TextStyle(
        color: text,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),

      bodyMedium: TextStyle(color: text),

      titleMedium: TextStyle(color: secondaryText),

      bodySmall: TextStyle(color: secondaryText),

      labelSmall: TextStyle(color: tertiaryText),

      // contenido destacado
      titleSmall: TextStyle(
        color: highlight,
        fontWeight: FontWeight.w600,
      ),

      labelMedium: TextStyle(
        color: highlight,
      ),
    ),

    cardTheme: CardThemeData(
      color: surface,
    ),

    cardColor: surface,

    // UI
    iconTheme: IconThemeData(
      color: accent,
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: accent,
      ),
    ),

    badgeTheme: BadgeThemeData(
      textColor: accent,
    ),

    inputDecorationTheme: InputDecorationThemeData(
      fillColor: searchInput,
    ),

    focusColor: searchBorder,
    hintColor: tertiaryText,

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: background,

      unselectedItemColor: secondaryText,
      unselectedIconTheme: IconThemeData(
        color: secondaryText,
      ),

      selectedItemColor: accent,
      selectedIconTheme: IconThemeData(
        color: accent,
      ),
    ),
  );
}