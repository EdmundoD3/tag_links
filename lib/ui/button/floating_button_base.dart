import 'package:flutter/material.dart';

class FloatingButtonBase extends StatelessWidget {
  final String heroTag;
  final IconData icon;
  final void Function() onPressed;

  const FloatingButtonBase({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom:20.0),
      child: FloatingActionButton(
        backgroundColor:  theme.appBarTheme.backgroundColor,
        shape: CircleBorder(),
        elevation: 0, 
        hoverElevation: 0,
        highlightElevation: 0,
        foregroundColor: theme.iconTheme.color,
        heroTag: heroTag,
        onPressed: onPressed,
        child: Icon(icon),
      ),
    );
  }
}
