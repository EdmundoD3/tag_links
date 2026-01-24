import 'package:flutter/material.dart';

class AppTheme {
  // Getter estático para acceder al tema fácilmente
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // Configuración global del AppBar
      appBarTheme: const AppBarTheme(
      ),

      // Configuración global de Cards
      cardTheme: CardThemeData(
      ),
      //button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
      ),
      chipTheme: ChipThemeData(),
      
    );
  }
}
