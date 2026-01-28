import 'package:flutter/material.dart';

PreferredSizeWidget appBar({required String title, List<Widget>? actions}) {
  return AppBar(
    title: Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 16),
    ),
    backgroundColor: const Color.fromARGB(92, 63, 81, 181),
    actions: actions,
  );
}
