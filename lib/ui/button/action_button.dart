import 'package:flutter/material.dart';

class ActionButtonFilled extends StatelessWidget {
  final String label;
  final void Function() onPressed;

  const ActionButtonFilled({
    super.key,
    required this.label,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilledButton(
      onPressed: onPressed, // Retorna null (Cancelar)
      style: FilledButton.styleFrom( backgroundColor: theme.appBarTheme.backgroundColor, 
      foregroundColor: theme.textTheme.titleLarge?.color),
      child: Text(label),
    );
  }
}

class ActionTextButton extends StatelessWidget {
  final String label;
  final void Function() onPressed;

  const ActionTextButton({
    super.key,
    required this.label,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton(
            onPressed: onPressed,
            child: Text(label,
            style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
    );
  }
}
