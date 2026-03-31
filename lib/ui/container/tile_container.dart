import 'package:flutter/material.dart';

class TileContainer extends StatelessWidget {
  final Widget child;
  final Color? cardColor;
  final BorderRadius? borderRadius;

  const TileContainer({super.key, required this.child, required this.cardColor, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: borderRadius ?? BorderRadius.circular(5),
        boxShadow: const [
          BoxShadow(blurRadius: 4, color: Colors.black12, offset: Offset(0, 1)),
        ],
      ),
      child: child,
    );
  }

}