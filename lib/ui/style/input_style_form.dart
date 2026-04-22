import 'package:flutter/material.dart';

class InputStyleForm {
  static InputDecoration inputDecoration({
    required ThemeData theme,
    required String label,
    String? counterText,
    EdgeInsetsGeometry? contentPadding,
  }) => InputDecoration(
    labelText: label,
    labelStyle: TextStyle(
      color: theme.hintColor),
    alignLabelWithHint: true,
    filled: true,
    fillColor: theme.inputDecorationTheme.fillColor?.withAlpha(50),
    counterText: counterText,
    contentPadding: contentPadding ?? const EdgeInsets.fromLTRB(16, 12, 24, 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: theme.dividerColor.withAlpha(20), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: theme.colorScheme.primary.withAlpha(100),
        width: 1.5,
      ),
    ),
  );
}
