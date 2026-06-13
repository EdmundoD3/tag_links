import 'package:flutter/material.dart';
import 'package:tag_links/models/tag.dart';

class MiniTagsFooter extends StatelessWidget {
  final List<Tag> tags;
  final Color? color;

  const MiniTagsFooter({super.key, required this.tags, this.color});
  @override
  Widget build(BuildContext context) {
    final String resultado = tags.map((tag) => '#${tag.title}').join(' ');
    final theme = Theme.of(context);
    return Text(
      resultado,
      style: theme.textTheme.labelMedium?.copyWith(color: color),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}