import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tag_links/models/link_preview.dart';

class LinkPreviewWidget extends StatelessWidget {
  const LinkPreviewWidget({super.key, required this.preview});

  final LinkPreview preview;

  @override
  Widget build(BuildContext context) {
  if (preview.url.isEmpty) return const SizedBox.shrink();

  return Row(
    children: [
      if (preview.image != null)
        CachedNetworkImage(
          imageUrl: preview.image!,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        )
      else
        const Icon(Icons.link, size: 48),

      const SizedBox(width: 8),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              preview.title ?? preview.siteName ?? preview.url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (preview.description != null)
              Text(
                preview.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    ],
  );
}
}