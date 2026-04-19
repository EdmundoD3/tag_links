import 'package:flutter/material.dart';
import 'package:tag_links/config/limit_config.dart';

class TitleFormController extends StatelessWidget {
  final TextEditingController titleCtrl;
  final String label;
  final String validatorMsg;
  final void Function()? onChange;

  const TitleFormController({
    super.key,
    required this.titleCtrl,
    required this.label,
    required this.validatorMsg,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      cursorColor: theme.appBarTheme.backgroundColor,
      style: TextStyle(color: theme.textTheme.bodyMedium?.color),
      controller: titleCtrl,
      maxLength: LimitAppConfig.titleMaxLength,
      decoration: InputDecoration(
        filled: true,
        fillColor: theme.inputDecorationTheme.fillColor?.withAlpha(60),
        labelText: label,
        border: OutlineInputBorder(),
        labelStyle: TextStyle(color: theme.hintColor),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.hintColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.hintColor, width: 2),
        ),
      ),
      onChanged: (value) => onChange?.call(),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return validatorMsg;
        }
        return null;
      },
    );
  }
}
