import 'package:flutter/material.dart';

class AppTheme {
  // Getter estático para acceder al tema fácilmente
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Color(0xFFEDE7F6),
      highlightColor: Colors.transparent,

      // Configuración global del AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: const Color.fromARGB(92, 63, 81, 181),
        foregroundColor: Colors.black,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Configuración global de Cards
      cardTheme: CardThemeData(),
      //button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: const Color.fromARGB(92, 63, 81, 181),
        shape: const CircleBorder(),
        elevation: 0,
        foregroundColor: Colors.purple[900],
      ),
      chipTheme: ChipThemeData(),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Color(0xFFEDE7F6),
      highlightColor: Color.fromARGB(92, 155, 39, 176),

      // Configuración global del AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blueGrey,
        // color: Colors.blueGrey,
        foregroundColor: Colors.lightBlue,
      ),

      // Configuración global de Cards
      cardTheme: CardThemeData(),
      //button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(),
      chipTheme: ChipThemeData(),
    );
  }
}

ThemeData getPalette({required Color principal, required Color secondary}) {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Color(0xFFEDE7F6),

    // Configuración global del AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.amber,
      foregroundColor: Colors.black,
    ),

    // Configuración global de Cards
    cardTheme: CardThemeData(),
    //button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(),
    chipTheme: ChipThemeData(),
  );
}
