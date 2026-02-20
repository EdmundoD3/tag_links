import 'package:flutter/material.dart';

enum AppPalette { dark, light }

ThemeData getPalette({required AppPalette palette}) {
  final theme = _palettes[palette];
  return theme ?? _palettes[AppPalette.light]!;
}

class AppTheme {
  // Getter estático para acceder al tema fácilmente
  static ThemeData get lightTheme {
    return _generatePalette(
      strongBackground: const Color.fromARGB(92, 63, 81, 181),
      strongBackgroundText: Colors.black,
      icon: Colors.deepPurple,
      badge: Colors.indigo,
      lighBackground: Colors.white,
      titleColor: Colors.black,
      textColor: Colors.black,
      secondTextColor: Colors.black,
      thirdTextColor: Colors.deepPurpleAccent,
      invertedColor: Colors.white,
      scaffoldBackgroundColor: Color(0xFFE8EAF6), //indigo[50] 
      searchInput: Color.fromARGB(35, 150, 135, 155),
      searchInputBorder: Color.fromARGB(92, 63, 81, 181),
      searchIcon: Colors.grey,
      
    );
  }

  static ThemeData get darkTheme {
    return _generatePalette(
      strongBackground: Colors.deepPurpleAccent,
      strongBackgroundText: Colors.white,
      icon: Colors.white70,
      badge: Color(0xFFBBDEFB),
      lighBackground: Color.fromARGB(255, 240, 241, 248),
      titleColor: Colors.white,
      textColor: Colors.white,
      secondTextColor: Colors.black,
      thirdTextColor: Colors.deepPurpleAccent,
      invertedColor: Colors.black,
      scaffoldBackgroundColor: Colors.black,
      searchInput: Color.fromARGB(96, 199, 179, 206),
      searchInputBorder: Color(0xFFEDE7F6),
      searchIcon: Colors.grey,
    );
  }
}

Map<AppPalette, ThemeData> _palettes = {
  AppPalette.light: AppTheme.lightTheme,
  AppPalette.dark: AppTheme.darkTheme,
};

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
  // required Color subtitleColor,
  required Color invertedColor,

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
      titleLarge: TextStyle(color: textColor),
      bodySmall: TextStyle(color: searchIcon),
      titleSmall: TextStyle(color: thirdTextColor),
      titleMedium: TextStyle(color: secondTextColor),
    ),

    // Configuración global de Cards
    cardTheme: CardThemeData(color: lighBackground),
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
