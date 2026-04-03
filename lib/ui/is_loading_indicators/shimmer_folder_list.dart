import 'package:flutter/material.dart';
import 'package:tag_links/ui/is_loading_indicators/shimmer_box.dart';

class ShimmerFoldersList extends StatelessWidget {
  const ShimmerFoldersList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Row(
        children: [
          const ShimmerBox(width: 40, height: 40, borderRadius: BorderRadius.all(Radius.circular(8))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(width: 120, height: 14),
                const SizedBox(height: 8),
                const ShimmerBox(width: 80, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}