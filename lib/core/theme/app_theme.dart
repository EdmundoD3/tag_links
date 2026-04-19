import 'package:flutter/material.dart';

const defaultTheme = AppPalette.lavender;

enum AppPalette { dark, light, lavender, rosePastel, arcticBlue, lavenderNight }

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

class AppTheme {
  // Getter estático para acceder al tema fácilmente
  static ThemeData get lightTheme {
    return _generatePalette(
      strongBackground: const Color(0xFFF2F3F5),
      strongBackgroundText: const Color(0xFF1A1C1E),
      icon: const Color(0xFF5D5F66),
      badge: const Color(0xFF5D5F66),
      lighBackground: const Color(0xFFF1F3F4),
      titleColor: const Color(0xFF1A1C1E),
      textColor: const Color(0xFF44474E),
      secondTextColor: const Color(0xFF5C5F66),
      thirdTextColor: const Color(0xFF44474E),
      cardNoteColor: const Color(0xFFF6F7F9),
      subtitleColor: const Color(0xFF6F7278),
      secondSubtitleColor: const Color(0xFF8A8D93),
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      searchInput: const Color(0xFFEDEFF1),
      searchInputBorder: const Color(0xFFD1D5DB),
      searchIcon: const Color(0xFF8A8D93),
      tags: const Color(0xFF1A1C1E),
    );
  }

  static ThemeData get darkTheme {
    return _generatePalette(
      strongBackground: Color(0xFF1B1F24),
      strongBackgroundText: Color(0xFFF8F9FA),
      icon: Color(0xFF8E9199),
      badge: Color(0xFF8E9199),
      lighBackground: const Color(0xFF22282F),
      titleColor: Color(0xFFE2E2E6),
      textColor: Color(0xFFC4C6D0),
      secondTextColor: Color(0xFFC4C6D0),
      thirdTextColor: Color(0xFFF8F9FA),
      cardNoteColor: Color(0xFF22282F),
      subtitleColor: Color(0xFF757575),
      secondSubtitleColor: Colors.grey,
      scaffoldBackgroundColor: const Color(0xFF111418),
      searchInput: Color.fromARGB(122, 131, 133, 141),
      searchInputBorder: Color(0xFFEDE7F6),
      searchIcon: Colors.grey,
      tags: Color(0xFFE2E2E6),
    );
  }

  static ThemeData get lavenderTheme {
    return _generatePalette(
      strongBackground: const Color(0xFFBFCBFF),
      strongBackgroundText: Color(0xFF1A1C1E),
      icon: Colors.deepPurple,
      badge: Color(0xFF9E80D1),
      lighBackground: Color(0xFFC8D2FF),
      titleColor: Color(0xFF240046),
      textColor: Color(0xFF1A1C1E),
      secondTextColor: Color(0xFF1A1C1E),
      thirdTextColor: Color(0xFF7E57C2),
      cardNoteColor: Color(0xFFF8F7FF),
      subtitleColor: Color(0xFFF8F7FF),
      secondSubtitleColor: Color(0xFF757575),
      scaffoldBackgroundColor: Color.fromARGB(255, 239, 245, 255),
      searchInput: const Color(0x33AAA1C8),
      searchInputBorder: Color.fromARGB(92, 63, 81, 181),
      searchIcon: Colors.grey,
      tags: Colors.deepPurpleAccent,
    );
  }

  static ThemeData get rosePastelTheme {
  const mentaBlanco = Color.fromARGB(255, 245, 255, 251);
  const strongRose = Color(0xFFFF92C2);
  return _generatePalette(
    strongBackground: strongRose,
    strongBackgroundText: mentaBlanco,
    icon: mentaBlanco,
    badge: const Color(0xFFFF8FAB), 
    lighBackground: const Color(0xFFFFE5EC), 
    titleColor: const Color(0xFF590D22), 
    textColor: const Color(0xFF2B1B1F), 
    secondTextColor: const Color(0xFF1B4332), 
    thirdTextColor: const Color.fromARGB(255, 223, 56, 98), 
    cardNoteColor: mentaBlanco,
    subtitleColor: mentaBlanco,
    secondSubtitleColor: const Color(0xFF9D8189), 
    scaffoldBackgroundColor: const Color.fromARGB(255, 252, 240, 243),
    searchInput: strongRose.withValues(alpha: 0.1), 
    searchInputBorder: strongRose.withValues(alpha: 0.4),
    searchIcon: const Color(0xFF805B65), 
    tags: const Color.fromARGB(255, 120, 194, 174), 
  );
}

  static ThemeData get arcticBlueTheme {
    const cafeClaro = Color.fromARGB(255, 255, 251, 245);
    return _generatePalette(
      strongBackground: const Color(0xFF507DBC),
      strongBackgroundText: cafeClaro,
      icon: cafeClaro,
      badge: const Color(0xFF779ACB),
      lighBackground: const Color(0xFFBBD1EA),
      titleColor: const Color(0xFF04080F),
      textColor: const Color(0xFF04080F),
      secondTextColor: const Color(0xFF2F3E46),
      thirdTextColor: const Color(0xFF507DBC),
      cardNoteColor: cafeClaro,
      subtitleColor: cafeClaro,
      secondSubtitleColor: const Color(0xFF6C7A80),
      scaffoldBackgroundColor: const Color(0xFFDAE3E5),
      searchInput: const Color(0x33A1C6EA),
      searchInputBorder: const Color(0x88507DBC),
      searchIcon: const Color(0xFF6C7A80),
      tags: Colors.blueAccent,
    );
  }

  static ThemeData get lavenderNightTheme {
    const verdeClaro = Color.fromARGB(255, 250, 255, 247);
    return _generatePalette(
      strongBackground: const Color(0xFF967AA1),
      strongBackgroundText: verdeClaro,
      icon: verdeClaro,
      badge: const Color(0xFF967AA1),
      lighBackground: const Color(0xFFD5C6E0),
      titleColor: const Color(0xFF192A51),
      textColor: const Color(0xFF192A51),
      secondTextColor: const Color(0xFF3A3F5C),
      thirdTextColor: const Color(0xFF675E85),
      cardNoteColor: verdeClaro,
      subtitleColor: verdeClaro,
      secondSubtitleColor: const Color(0xFF6E6A86),
      scaffoldBackgroundColor: const Color(0xFFF5E6E8),
      searchInput: const Color(0x33AAA1C8),
      searchInputBorder: const Color(0x88967AA1),
      searchIcon: const Color(0xFF6E6A86),
      tags: Color.fromARGB(211, 0, 139, 139),
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
  required Color tags,

}) {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: strongBackground,
      primary: strongBackground,
      onSurface: textColor, 
    ),
    canvasColor:
        scaffoldBackgroundColor, //Agrega esto para evitar el flash blanco
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
      labelMedium: TextStyle(color: tags),
    ),

    // ------------ Configuración global de Cards
    cardTheme: CardThemeData(color: lighBackground),
    cardColor: cardNoteColor,

    // ------------ icon --------------------------
    iconTheme: IconThemeData(color: icon),
    iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(foregroundColor: icon)),
    badgeTheme: BadgeThemeData(textColor: badge),
    chipTheme: ChipThemeData(),

    // ------------ search bar ------------------------
    inputDecorationTheme: InputDecorationThemeData(fillColor: searchInput),
    focusColor: searchInputBorder,
    hintColor: searchIcon,
    // ------------ Switch folder - note  ------------------
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: scaffoldBackgroundColor,

      unselectedItemColor: badge,
      unselectedIconTheme: IconThemeData(color: badge),

      selectedItemColor: thirdTextColor,

      selectedIconTheme: IconThemeData(color: thirdTextColor),
    ),


  );
}


