import 'package:flutter/material.dart';

class ScaffoldLoginBackground extends StatelessWidget {
  const ScaffoldLoginBackground({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("---------- ScaffoldLoginBackground- agregar logo --------");
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // El logo de Tag Links o un icono representativo
            Icon(Icons.link, size: 80, color: Theme.of(context).primaryColor.withOpacity(0.5)),
            const SizedBox(height: 24),
            // Una barra de progreso lineal es más discreta que el círculo
            const SizedBox(
              width: 150,
              child: LinearProgressIndicator(minHeight: 2),
            ),
          ],
        ),
      ),
    );
  }
}