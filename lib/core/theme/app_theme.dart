import 'package:flutter/material.dart';

enum AppPalette { dark, light, lavender }

Map<AppPalette, ThemeData> _palettes = {
  AppPalette.light: AppTheme.lightTheme,
  AppPalette.dark: AppTheme.darkTheme,
  AppPalette.lavender: AppTheme.lavenderTheme,
};

ThemeData getPalette({required AppPalette palette}) {
  final theme = _palettes[palette];
  return theme ?? _palettes[AppPalette.light]!;
}

class AppTheme {
  static ThemeData get lavenderTheme{
    return _generatePalette(
      strongBackground: const Color(0xFFBFCBFF),
      strongBackgroundText: Colors.black,
      icon: Colors.deepPurple,
      badge: Colors.indigo,
      lighBackground: Color.fromARGB(153, 191, 203, 255),
      titleColor: Color(0xFF240046),
      textColor: Colors.black,
      secondTextColor: Colors.black,
      thirdTextColor: Colors.deepPurpleAccent,
      cardNoteColor: Color(0xFFF8F7FF),
      subtitleColor: Color(0xFF757575),
      secondSubtitleColor: Colors.grey,
      scaffoldBackgroundColor: Color.fromARGB(255, 239, 245, 255), 
      searchInput: Color.fromARGB(35, 150, 135, 155),
      searchInputBorder: Color.fromARGB(92, 63, 81, 181),
      searchIcon: Colors.grey,
    );
  }
  // Getter estático para acceder al tema fácilmente
  static ThemeData get lightTheme {
    return _generatePalette(
      strongBackground: const Color(0xFFFFFFFF),
      strongBackgroundText: Colors.black,
      icon: Color.fromARGB(255, 93, 95, 102),
      badge: Color(0xFF74777F),
      lighBackground: Color(0xFFFFFFFF),
      titleColor: Color(0xFF1A1C1E),
      textColor: Color(0xFF44474E),
      secondTextColor: Color(0xFF44474E),
      thirdTextColor: Colors.deepPurpleAccent,
      cardNoteColor: Color(0xFFFFFFFF),
      subtitleColor: Color(0xFF757575),
      secondSubtitleColor: Colors.grey,
      scaffoldBackgroundColor: Color(0xFFF8F9FA), 
      searchInput: Color(0xFFEEEEEE),
      searchInputBorder: Color.fromARGB(92, 63, 81, 181),
      searchIcon: Colors.grey,
    );
  }

  static ThemeData get darkTheme {
    return _generatePalette(
      strongBackground: Color(0xFF1B1F24),
      strongBackgroundText: Colors.white,
      icon: Color(0xFF8E9199),
      badge: Color(0xFF8E9199),
      lighBackground: const Color(0xFF22282F), //card theme
      titleColor: Color(0xFFE2E2E6),
      textColor: Color(0xFFC4C6D0),
      secondTextColor: Color(0xFFC4C6D0),
      thirdTextColor: Color(0xFFE2E2E6),
      cardNoteColor: Color(0xFF22282F),
      subtitleColor: Color(0xFF757575),
      secondSubtitleColor: Colors.grey,
      scaffoldBackgroundColor: const Color(0xFF111418),
      searchInput: Color.fromARGB(122, 131, 133, 141),
      searchInputBorder: Color(0xFFEDE7F6),
      searchIcon: Colors.grey,
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
      titleLarge: TextStyle(color: titleColor, fontWeight: FontWeight.bold, fontSize: 16),
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
