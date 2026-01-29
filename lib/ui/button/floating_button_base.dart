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
    return FloatingActionButton(
      backgroundColor:  Color.fromARGB(92, 63, 81, 181),
      shape: CircleBorder(),
      elevation: 0,
      foregroundColor: Colors.purple[900],
      heroTag: heroTag,
      onPressed: onPressed,
      child: Icon(icon),
    );
  }
}
