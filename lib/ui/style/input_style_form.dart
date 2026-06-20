import 'package:flutter/material.dart';

class InputStyleForm {
  static InputDecoration inputDecoration({
    required ThemeData theme,
    required String label,
    String? counterText,
    EdgeInsetsGeometry? contentPadding,
  }) {
    final borderColor =
    (theme.iconTheme.color ?? theme.colorScheme.primary)
        .withValues(alpha: 0.20);
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: theme.hintColor),
      floatingLabelStyle: TextStyle(
        color: theme.textTheme.titleSmall?.color,
        fontWeight: FontWeight.w600,
      ),
      alignLabelWithHint: true,
      filled: true,
      fillColor: theme.inputDecorationTheme.fillColor,
      counterText: counterText,
      contentPadding:
          contentPadding ?? const EdgeInsets.fromLTRB(16, 12, 24, 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: theme.textTheme.titleSmall?.color ?? theme.colorScheme.primary,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
  borderRadius: BorderRadius.circular(16),
  borderSide: BorderSide(
    color: theme.colorScheme.error,
    width: 1.5,
  ),
),
errorBorder: OutlineInputBorder(
  borderRadius: BorderRadius.circular(16),
  borderSide: BorderSide(
    color: theme.colorScheme.error,
    width: 1,
  ),
),
    );
  }
}
