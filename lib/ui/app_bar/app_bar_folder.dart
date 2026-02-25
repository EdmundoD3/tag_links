import 'package:flutter/material.dart';

class AppBarPages  extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const AppBarPages({
    super.key,
    required this.title,
    this.actions,
  });
    @override
  Widget build(BuildContext context) {
  return AppBar(
    title: Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    actions: actions,
  );
  }
    @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}