import 'package:flutter/material.dart';

enum AppPalette { dark, light, lavender, rosePastel }

Map<AppPalette, ThemeData> _palettes = {
  AppPalette.light: AppTheme.lightTheme,
  AppPalette.dark: AppTheme.darkTheme,
  AppPalette.lavender: AppTheme.lavenderTheme,
  AppPalette.rosePastel: AppTheme.rosePastelTheme,
};

ThemeData getPalette({required AppPalette palette}) {
  final theme = _palettes[palette];
  return theme ?? _palettes[AppPalette.light]!;
}

class AppTheme {
  // Getter estático para acceder al tema fácilmente
  static ThemeData get lightTheme {
    return _generatePalette(
      strongBackground: const Color(0xFFFFFFFF),
      strongBackgroundText: Color(0xFF1A1C1E),
      icon: Color.fromARGB(255, 93, 95, 102),
      badge: Color.fromARGB(255, 93, 95, 102),
      lighBackground: Color(0xFFFFFFFF),
      titleColor: Color(0xFF1A1C1E),
      textColor: Color(0xFF44474E),
      secondTextColor: Color(0xFF44474E),
      thirdTextColor: Color(0xFF7E57C2),
      cardNoteColor: Color(0xFFFFFFFF),
      subtitleColor: Color(0xFF757575),
      secondSubtitleColor: Colors.grey,
      scaffoldBackgroundColor: Color(0xFFF8F9FA),
      searchInput: Color(0xFFEEEEEE),
      searchInputBorder: Colors.grey,
      searchIcon: Colors.grey,
    );
  }

  static ThemeData get darkTheme {
    return _generatePalette(
      strongBackground: Color(0xFF1B1F24),
      strongBackgroundText: Color(0xFFF8F9FA),
      icon: Color(0xFF8E9199),
      badge: Color(0xFF8E9199),
      lighBackground: const Color(0xFF22282F), //card theme
      titleColor: Color(0xFFE2E2E6),
      textColor: Color(0xFFC4C6D0),
      secondTextColor: Color(0xFFC4C6D0),
      thirdTextColor: Color(0xFF7E57C2),
      cardNoteColor: Color(0xFF22282F),
      subtitleColor: Color(0xFF757575),
      secondSubtitleColor: Colors.grey,
      scaffoldBackgroundColor: const Color(0xFF111418),
      searchInput: Color.fromARGB(122, 131, 133, 141),
      searchInputBorder: Color(0xFFEDE7F6),
      searchIcon: Colors.grey,
    );
  }

  static ThemeData get lavenderTheme {
    return _generatePalette(
      strongBackground: const Color(0xFFBFCBFF),
      strongBackgroundText: Color(0xFF1A1C1E),
      icon: Colors.deepPurple,
      badge: Colors.deepPurple,
      lighBackground: Color.fromARGB(255, 200, 210, 255),
      titleColor: Color(0xFF240046),
      textColor: Color(0xFF1A1C1E),
      secondTextColor: Color(0xFF1A1C1E),
      thirdTextColor: Color(0xFF7E57C2),
      cardNoteColor: Color(0xFFF8F7FF),
      subtitleColor: Color(0xFFF8F7FF),
      secondSubtitleColor: Color(0xFF757575),
      scaffoldBackgroundColor: Color.fromARGB(255, 239, 245, 255),
      searchInput: Color.fromARGB(34, 135, 149, 155),
      searchInputBorder: Color.fromARGB(92, 63, 81, 181),
      searchIcon: Colors.grey,
    );
  }

  static ThemeData get rosePastelTheme {
    return _generatePalette(
      strongBackground: const Color(0xFFFF92C2),
      strongBackgroundText: const Color(0xFFF8F7FF),
      icon: const Color(0xFFFFE4F3),
      badge: const Color(0xFFF8517F),
      lighBackground: const Color(0xFFFFC2D1),
      titleColor: const Color(0xFF590D22),
      textColor: const Color(0xFF3A2A30),
      secondTextColor: const Color(0xFF5C4A52),
      thirdTextColor: const Color(0xFFFF92C2),
      cardNoteColor: const Color(0xFFFDFBF9),
      subtitleColor: const Color(0xFFFDFBF9),
      secondSubtitleColor: const Color(0xFF8A7A80),
      scaffoldBackgroundColor: const Color(0xFFFFEEF2),
      searchInput: const Color(0x33FF95B5), // rosa transparente
      searchInputBorder: const Color(0x66FF92C2),
      searchIcon: const Color(0x66FF92C2),
    );
  }
}

ThemeData _generatePalette({
  required Color strongBackground,
  required Color strongBackgroundText,
  required Color icon,
  required Color badge,
  required Color lighBackground,
  required Color textColor,
  required Color scaffoldBackgroundColor,
  required Color titleColor,
  required Color searchInput,
  required Color searchInputBorder,
  required Color searchIcon,
  required Color secondTextColor,
  required Color thirdTextColor,
  required Color subtitleColor,
  required Color cardNoteColor,
  required Color secondSubtitleColor,
}) {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    highlightColor: Colors.transparent,
    // Configuración global del AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: strongBackground,
      foregroundColor: strongBackgroundText,
      titleTextStyle: TextStyle(
        color: titleColor,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(color: textColor),
      titleLarge: TextStyle(
        color: titleColor,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      bodySmall: TextStyle(color: subtitleColor),
      titleSmall: TextStyle(color: thirdTextColor),
      titleMedium: TextStyle(color: secondTextColor),
      labelSmall: TextStyle(color: secondSubtitleColor),
    ),

    // Configuración global de Cards
    cardTheme: CardThemeData(color: lighBackground),
    cardColor: cardNoteColor,

    //icon
    iconTheme: IconThemeData(color: icon),
    badgeTheme: BadgeThemeData(textColor: badge),
    chipTheme: ChipThemeData(),
    //search bar
    inputDecorationTheme: InputDecorationThemeData(fillColor: searchInput),
    focusColor: searchInputBorder,
    hintColor: searchIcon,
  );
}
