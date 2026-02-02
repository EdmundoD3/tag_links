import 'package:flutter/material.dart';

final Map<String, Color> decorateColors = {
  "red": Colors.red,
  "green": Colors.green,
  "blue": Colors.blue,
  "pink": Colors.pink,
};

class FolderColorUtils {
  static Color resolveColor(String? color, {Color defaultColor = Colors.grey}) {
    if (color == null || color.trim().isEmpty) {
      return defaultColor;
    }

    final colorKey = color.trim().toLowerCase();

    final preset = decorateColors[colorKey];
    if (preset != null) {
      return preset;
    }

    if (colorKey.startsWith('#') && colorKey.length == 7) {
      try {
        return Color(int.parse(colorKey.replaceFirst('#', '0xff')));
      } catch (_) {}
    }

    return defaultColor;
  }

  static String? ensureColor(String? color) {
  if (color == null || color.trim().isEmpty) {
    return null;
  }

  final colorKey = color.trim().toLowerCase();

  // Preset
  if (decorateColors.containsKey(colorKey)) {
    return colorKey;
  }

  // HEX custom
  if (colorKey.startsWith('#') && colorKey.length == 7) {
    try {
      int.parse(colorKey.replaceFirst('#', '0xff'));
      return colorKey;
    } catch (_) {
      return null;
    }
  }

  return null;
}

}
