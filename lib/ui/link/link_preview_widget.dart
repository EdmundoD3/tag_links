import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tag_links/models/link_preview.dart';

class LinkPreviewWidget extends StatelessWidget {
  final LinkPreview preview;
  final Future<void> Function()? clearLinkPreview;
  const LinkPreviewWidget({
    super.key,
    required this.preview,
    this.clearLinkPreview,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (preview.url.isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        if (preview.image != null)
          CachedNetworkImage(
            imageUrl: preview.image!,
            width: 100,
            height: 80,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) {
              unawaited(clearLinkPreview?.call());
              return _LinkFallback(url: preview.url);
            },
          )
        else
          _LinkFallback(url: preview.url),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                preview.title ?? preview.siteName ?? preview.url,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (preview.description != null)
                Text(
                  preview.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LinkFallback extends StatelessWidget {
  final String url;

  const _LinkFallback({required this.url});

  @override
  Widget build(BuildContext context) {
    String host;

    try {
      host = Uri.parse(url).host;
    } catch (_) {
      host = '';
    }

    host = host.replaceFirst('www.', '');

    return Container(
      width: 100,
      height: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.public, size: 28),
          const SizedBox(height: 4),
          Text(
            host.isEmpty ? 'Link' : _compactHost(host),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  String _compactHost(String host) {
    return host.replaceFirst('www.', '');
  }
}
