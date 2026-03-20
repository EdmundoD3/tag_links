import 'package:flutter/material.dart';

Future<void> goPage({required BuildContext context, required Widget page}) {
  return Navigator.push(
    context,
    PageRouteBuilder(
      opaque: true, // Mejora el rendimiento al decirle a Flutter que esta página tapa la anterior
      maintainState: true, // Mantiene el estado de la página anterior (importante para tus listas)
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // El Curve le da un toque más profesional que una transición lineal
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeIn, 
          ),
          child: child,
        );
      },
    ),
  );
}