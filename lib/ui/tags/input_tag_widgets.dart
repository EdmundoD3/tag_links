import 'package:flutter/material.dart';
import 'package:tag_links/config/limit_config.dart';

class InputTitleTag extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const InputTitleTag({
    super.key,
    required this.controller,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final accent = theme.iconTheme.color ?? theme.primaryColor;
    final highlight = theme.textTheme.labelMedium?.color ?? accent;

    return TextField(
      controller: controller,
      autofocus: true,
      maxLength: LimitAppConfig.tagMaxLength,

      style: TextStyle(color: theme.textTheme.bodyMedium?.color),

      cursorColor: accent,

      decoration: InputDecoration(
        filled: true,
        fillColor: theme.cardColor,
        labelText: label,
        labelStyle: TextStyle(color: theme.textTheme.bodySmall?.color),
        alignLabelWithHint: true,

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.35),
            width: 1,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: highlight, width: 2),
        ),
        floatingLabelStyle: TextStyle(
          color: highlight,
          fontWeight: FontWeight.w600,
        ),
      ),

      textInputAction: TextInputAction.done,
    );
  }
}
