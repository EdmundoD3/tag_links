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
      lighBackground: Colors.white,
      textColor: Colors.black,
    );
  }

  static ThemeData get darkTheme {
    return _generatePalette(
      strongBackground: const Color.fromARGB(92, 50, 21, 78),
      strongBackgroundText: Colors.black,
      lighBackground: Colors.white,
      textColor: Colors.black,
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
  required Color lighBackground,
  required Color textColor,
}) {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.indigo[50],
    highlightColor: Colors.transparent,
    // Configuración global del AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: strongBackground,
      foregroundColor: strongBackgroundText,
      titleTextStyle: TextStyle(
        color: Colors.black,
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
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color.fromARGB(92, 63, 81, 181),
      shape: const CircleBorder(),
      elevation: 0,
      foregroundColor: Colors.purple[900],
    ),
    //icon
    iconTheme: IconThemeData(color: Colors.purple[900]),
    chipTheme: ChipThemeData(),
  );
}
