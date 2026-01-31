import 'package:flutter/material.dart';

class AppTheme {
  // Getter estático para acceder al tema fácilmente
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Color(0xFFEDE7F6),
      
      // Configuración global del AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
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
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Color(0xFFEDE7F6),
      
      // Configuración global del AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blueGrey,
        // color: Colors.blueGrey,
        foregroundColor: Colors.lightBlue,
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

ThemeData getPalette({required Color principal, required Color secondary}){
  return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Color(0xFFEDE7F6),
      
      // Configuración global del AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
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