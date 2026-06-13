import 'package:flutter/material.dart';

class TextDialogTitle extends StatelessWidget {
  final String title;
  final double? fontSize;

  const TextDialogTitle({super.key, required this.title, this.fontSize});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(title, style: theme.textTheme.titleLarge?.copyWith(fontSize: fontSize));
  }
}

class TextDialogContent extends StatelessWidget {
  final String text;

  const TextDialogContent({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: TextStyle(color: theme.textTheme.titleSmall?.color),
    );
  }
}
