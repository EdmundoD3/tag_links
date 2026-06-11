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

class FolderColorUtils {
  static DecorateColor? fromString(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    try {
      return DecorateColor.values.firstWhere(
        (e) => e.name == value.trim().toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  static String? ensureColor(String? value) {
    final color = fromString(value);
    return color?.name;
  }

  static DecorateColorTheme? resolveTheme(String? value) {
    final color = fromString(value);
    if (color == null) return null;

    return decorateThemes[color];
  }

  static Color resolveStrong(
    String? value, {
    Color defaultColor = Colors.grey,
  }) {
    return resolveTheme(value)?.strong ?? defaultColor;
  }

  static Color resolveLight(
    String? value, {
    Color defaultColor = Colors.transparent,
  }) {
    return resolveTheme(value)?.light ?? defaultColor;
  }
}

class ColorPicker extends StatelessWidget {
  final String? selectedColor;
  final ValueChanged<String?> onChanged;

  const ColorPicker({
    super.key,
    required this.selectedColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _ColorItem(
          color: Colors.transparent,
          selected: selectedColor == null,
          onTap: () => onChanged(null),
          isNone: true,
        ),

        for (final color in DecorateColor.values)
          _ColorItem(
            color: decorateThemes[color]!.strong,
            selected: selectedColor == color.name,
            onTap: () => onChanged(color.name),
          ),
      ],
    );
  }
}

class _ColorItem extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final bool isNone;

  const _ColorItem({
    required this.color,
    required this.selected,
    required this.onTap,
    this.isNone = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).dividerColor;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isNone ? null : color,
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor,
            width: selected ? 3 : 1,
          ),
        ),
        child: isNone
            ? const Icon(
                Icons.close,
                size: 16,
              )
            : null,
      ),
    );
  }
}