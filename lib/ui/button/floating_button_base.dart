import 'package:flutter/material.dart';

class FloatingButonBase extends StatelessWidget {
  final String heroTag;
  final IconData icon;
  final void Function() onPressed;

  const FloatingButonBase({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom:50.0),
      child: FloatingActionButton(
        backgroundColor:  theme.appBarTheme.backgroundColor?? Color.fromARGB(92, 63, 81, 181),
        shape: CircleBorder(),
        elevation: 0, 
        hoverElevation: 0,
        highlightElevation: 0,
        foregroundColor: theme.iconTheme.color?? Colors.deepPurple,
        heroTag: heroTag,
        onPressed: onPressed,
        child: Icon(icon),
      ),
    );
  }
}
