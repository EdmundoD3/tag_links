import 'package:flutter/material.dart';
import 'package:tag_links/ui/is_loading_indicators/shimmer_box.dart';

class ScaffoldLoading extends StatelessWidget {
  const ScaffoldLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Simulamos el título o buscador
              const ShimmerBox(width: 200, height: 30),
              const SizedBox(height: 30),
              // Simulamos una lista de elementos (carpetas/notas)
              Expanded(
                child: ListView.separated(
                  itemCount: 6,
                  separatorBuilder: (_, _) => const SizedBox(height: 15),
                  itemBuilder: (_, _) => Row(
                    children: [
                      const ShimmerBox(width: 50, height: 50, borderRadius: BorderRadius.all(Radius.circular(12))),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ShimmerBox(width: 150, height: 15),
                          const SizedBox(height: 8),
                          const ShimmerBox(width: 100, height: 12),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}