import 'package:flutter/material.dart';
import 'package:tag_links/core/theme/generate_palete.dart';

const defaultTheme = AppPalette.lavender;

enum AppPalette { dark, light, lavender, rosePastel, arcticBlue, lavenderNight }

class AppTheme {
  // Getter estático para acceder al tema fácilmente
static ThemeData get lightTheme {
  return generatePalette(
    primary: const Color(0xFFF2F3F5),
    onPrimary: const Color(0xFF1A1C1E),

    accent: const Color(0xFF5E6C84),
    highlight: const Color(0xFF2962FF),

    background: const Color(0xFFF8F9FA),
    surface: const Color(0xFFF6F7F9),

    text: const Color(0xFF44474E),
  );
}

static ThemeData get darkTheme {
  return generatePalette(
    primary: const Color(0xFF1B1F24),
    onPrimary: const Color(0xFFF8F9FA),

    accent: const Color(0xFF9AA5CE),
    highlight: const Color(0xFF7CC4FF),

    background: const Color(0xFF111418),
    surface: const Color(0xFF22282F),

    text: const Color(0xFFC4C6D0),
  );
}

static ThemeData get lavenderTheme {
  return generatePalette(
    primary: const Color(0xFFBFCBFF),
    onPrimary: const Color(0xFF1A1C1E),

    accent: const Color(0xFF7E57C2),
    highlight: Colors.deepPurpleAccent,

    background: const Color(0xFFEFF5FF),
    surface: const Color(0xFFF8F7FF),

    text: const Color(0xFF240046),
  );
}

static ThemeData get rosePastelTheme {
  return generatePalette(
    primary: const Color(0xFFFF92C2),
    onPrimary: const Color(0xFFF5FFFB),

    accent: const Color(0xFFFF8FAB),
    highlight: const Color(0xFF78C2AE),

    background: const Color(0xFFFCF0F3),
    surface: const Color(0xFFF5FFFB),

    text: const Color(0xFF590D22),
  );
}

static ThemeData get arcticBlueTheme {
  return generatePalette(
    primary: const Color(0xFF507DBC),
    onPrimary: const Color(0xFFFFFBF5),

    accent: const Color(0xFF779ACB),
    highlight: Colors.blueAccent,

    background: const Color(0xFFDAE3E5),
    surface: const Color(0xFFFFFBF5),

    text: const Color(0xFF04080F),
  );
}

static ThemeData get lavenderNightTheme {
  return generatePalette(
    primary: const Color(0xFF967AA1),
    onPrimary: const Color(0xFFFAFFF7),

    accent: const Color(0xFF675E85),
    highlight: const Color(0xFF008B8B),

    background: const Color(0xFFF5E6E8),
    surface: const Color(0xFFFAFFF7),

    text: const Color(0xFF192A51),
  );
}
}
