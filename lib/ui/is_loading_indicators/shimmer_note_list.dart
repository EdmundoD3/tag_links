import 'package:flutter/material.dart';
import 'package:tag_links/ui/is_loading_indicators/shimmer_box.dart';

class ShimmerNotesList extends StatelessWidget {
  const ShimmerNotesList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5, // Unas pocas notas bastan para llenar la pantalla
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerBox(width: 180, height: 18), // Título
            const SizedBox(height: 10),
            const ShimmerBox(width: double.infinity, height: 12), // Línea de texto 1
            const SizedBox(height: 6),
            const ShimmerBox(width: 250, height: 12), // Línea de texto 2
            const SizedBox(height: 12),
            Row(
              children: [
                const ShimmerBox(width: 60, height: 20, borderRadius: BorderRadius.all(Radius.circular(20))), // Tag 1
                const SizedBox(width: 8),
                const ShimmerBox(width: 60, height: 20, borderRadius: BorderRadius.all(Radius.circular(20))), // Tag 2
              ],
            )
          ],
        ),
      ),
    );
  }
}