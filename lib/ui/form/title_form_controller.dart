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
      controller: titleCtrl,
      maxLength: LimitAppConfig.titleMaxLength,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: theme.textTheme.bodyLarge?.color,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.hintColor),
        // floatingLabelBehavior: FloatingLabelBehavior.never,
        hintText: '',
        filled: true,
        // Usamos alpha 30 para un fondo muy sutil
        fillColor: theme.inputDecorationTheme.fillColor?.withAlpha(50),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.focusColor.withAlpha(20),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.focusColor.withAlpha(100),
            width: 2,
          ),
        ),
        counterText: "",
      ),
      onChanged: (value) => onChange?.call(),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return validatorMsg;
        return null;
      },
    );
  }
}
