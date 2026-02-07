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
      lighBackground: Color.fromARGB(200, 255, 255, 255),
      titleColor: Colors.white,
      textColor: Colors.white,
      scaffoldBackgroundColor: Colors.black,
      searchInput: Color.fromARGB(96, 199, 179, 206),
      searchInputBorder: Colors.white,
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
    ),

    // Configuración global de Cards
    cardTheme: CardThemeData(color: lighBackground),
    //button
    // floatingActionButtonTheme: FloatingActionButtonThemeData(
    //   backgroundColor: const Color.fromARGB(92, 63, 81, 181),
    //   shape: const CircleBorder(),
    //   elevation: 0,
    //   foregroundColor: Colors.purple[900],
    // ),
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
