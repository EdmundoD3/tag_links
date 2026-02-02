import 'package:flutter/material.dart';

PreferredSizeWidget appBar(BuildContext context,{
  required String title,
  List<Widget>? actions,
}) {
  final theme = Theme.of(context);

  return AppBar(
    title: Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 16,color: theme.appBarTheme.foregroundColor ?? Colors.black),
    ),
    backgroundColor: theme.appBarTheme.backgroundColor ?? const Color.fromARGB(92, 63, 81, 181),
    actions: actions,
  );
}
