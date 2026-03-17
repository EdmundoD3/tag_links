import 'package:flutter/material.dart';

Future<void> goPage({required BuildContext context, required Widget page}) {
  return Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300), // <--- Duración controlada
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // El FadeTransition es el mejor para evitar flasheos de color
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );
}