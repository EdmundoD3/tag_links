import 'package:flutter/material.dart';

class MoreVertButton extends StatelessWidget {
  final Color? color;
  final VoidCallback onPressed;

  const MoreVertButton({
    super.key,
    required this.onPressed,
    this.color
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(Icons.more_vert, size: 22), // Un poco más grande para carpetas
      splashRadius: 20,
      color: color?? Theme.of(context).hintColor,
    );
  }
}
