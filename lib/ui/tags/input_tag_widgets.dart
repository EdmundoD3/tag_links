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
    return TextField(
      controller: controller,
      autofocus: true,
      style: TextStyle(color: theme.textTheme.bodyMedium?.color),
      cursorColor: theme.scaffoldBackgroundColor,
      maxLength: LimitAppConfig.tagMaxLength,
      decoration: InputDecoration(
        filled: true,
        fillColor: theme.inputDecorationTheme.fillColor?.withAlpha(60),
        labelText: label,
        alignLabelWithHint: true,
        border: OutlineInputBorder(),
        labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.hintColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.hintColor, width: 2),
        ),
      ),
      textInputAction: TextInputAction.done,
    );
  }
}


