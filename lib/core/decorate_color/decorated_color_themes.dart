import 'package:flutter/material.dart';

enum DecorateColor {
  red('red'),
  green('green'),
  blue('blue'),
  pink('pink');

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

extension DecorateColorThemeX on DecorateColor {
  DecorateColorTheme get theme => decorateThemes[this]!;

  Color get strong => theme.strong;

  Color get light => theme.light;

  Color get text => theme.text;
}

class DecorateColorTheme {
  final Color strong;
  final Color light;
  final Color text;

  const DecorateColorTheme({
    required this.strong,
    required this.light,
    required this.text,
  });
}

const Map<DecorateColor, DecorateColorTheme> decorateThemes = {
  DecorateColor.red: DecorateColorTheme(
    strong: Color(0xFFD32F2F),
    light: Color(0xFFFFEBEE),
    text: Color.fromARGB(255, 26, 1, 1),
  ),
  DecorateColor.green: DecorateColorTheme(
    strong: Color(0xFF388E3C),
    light: Color(0xFFE8F5E9),
    text: Color.fromARGB(255, 7, 23, 7),
  ),
  DecorateColor.blue: DecorateColorTheme(
    strong: Color(0xFF1976D2),
    light: Color(0xFFE3F2FD),
    text: Color.fromARGB(255, 0, 16, 31),
  ),
  DecorateColor.pink: DecorateColorTheme(
    strong: Color(0xFFC2185B),
    light: Color(0xFFFCE4EC),
    text: Color.fromARGB(255, 27, 0, 11),
  ),
};