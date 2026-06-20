import 'package:flutter/material.dart';

enum DecorateColor {
  red('red'), //sin referencias pero esta bien
  orange('orange'), //charizard
  yellow('yellow'),
  green('green'), //meowscarada
  teal('teal'),
  blue('blue'), //sin referencias pero esta bien
  purple('purple'),
  pink('pink'); // tinkaton

  final String code;
  const DecorateColor(this.code);

  static DecorateColor? fromCode(String? code) {
    for (final value in DecorateColor.values) {
      if (value.code == code) {
        return value;
      }
    }
    return null;
  }
}

class DecorateColorTheme {
  final Color strong;
  final Color light;
  final Color text;
  final Color accent;

  const DecorateColorTheme({
    required this.strong,
    required this.light,
    required this.text,
    required this.accent,
  });
}


extension DecorateColorThemeX on DecorateColor {
  DecorateColorTheme get theme => decorateThemes[this]!;

  Color get strong => theme.strong;
  Color get background => theme.strong;
  Color get light => theme.light;

  Color get text => theme.text;

  Color get acent => theme.accent;
}


const Map<DecorateColor, DecorateColorTheme> decorateThemes = {
  DecorateColor.red: DecorateColorTheme(
    strong: Color(0xFFD32F2F),
    light: Color(0xFFFFEBEE),
    text: Color(0xFF350404),
    accent: Color(0xFF00897B),
  ),

  DecorateColor.orange: DecorateColorTheme(
    strong: Color(0xFFF34D26),
    light: Color.fromARGB(255, 252, 222, 189),
    text: Color(0xFF3A0C0E),
    accent: Color.fromARGB(255, 76, 38, 243),
  ),

  DecorateColor.yellow: DecorateColorTheme(
    strong: Color(0xFFFBC02D),
    light: Color.fromRGBO(255, 250, 214, 19),
    text: Color.fromARGB(255, 49, 37, 22),
    accent: Color.fromARGB(255, 20, 174, 156),
  ),

  DecorateColor.green: DecorateColorTheme(
    strong: Color(0xFF559153),
    light: Color(0xFFECF3DF),
    text: Color(0xFF042A04),
    accent: Color.fromARGB(255, 130, 94, 163),
  ),

  DecorateColor.teal: DecorateColorTheme(
    strong: Color(0xFF00897B),
    light: Color(0xFFE0F2F1),
    text: Color(0xFF032B28),
    accent: Color.fromARGB(255, 156, 94, 163),
  ),

  DecorateColor.blue: DecorateColorTheme(
    strong: Color(0xFF1976D2),
    light: Color(0xFFE3F2FD),
    text: Color(0xFF00101F),
    accent: Color(0xFFFF7043),
  ),

  DecorateColor.purple: DecorateColorTheme(
    strong: Color(0xFF7B1FA2),
    light: Color(0xFFF3E5F5),
    text: Color(0xFF22042E),
    accent: Color(0xFF26A69A),
  ),

  DecorateColor.pink: DecorateColorTheme(
    strong: Color.fromARGB(255, 230, 105, 160),
    light: Color.fromARGB(255, 243, 225, 233),
    text: Color.fromARGB(255, 75, 27, 51),
    accent: Color(0xFF26A69A),
  ),
};
