import 'package:flutter/material.dart';
import 'package:tag_links/models/note.dart';

class TitleFormController extends StatelessWidget {
  final TextEditingController titleCtrl;
  final String label;
  final String validatorMsg;

  const TitleFormController({super.key, 
    required this.titleCtrl,
    required this.label,
    required this.validatorMsg,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      style: TextStyle(color: theme.textTheme.labelSmall?.color),
      controller: titleCtrl,
      maxLength: NoteConfig.titleMaxLength,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        labelStyle: TextStyle(color: theme.textTheme.labelSmall?.color),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.focusColor, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return validatorMsg;
        }
        return null;
      },
    );
  }
}