import 'package:flutter/material.dart';
import 'package:tag_links/models/tag.dart';

class SelectedTagsContainer extends StatelessWidget {
  final void Function(Tag tag) onDeleted;
  final List<Tag> tags;
  const SelectedTagsContainer({super.key, required this.tags, required this.onDeleted});
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: tags
          .map(
            (tag) => _TagChip(tag, onDeleted: onDeleted),
          )
          .toList(),
    );
  }
}

class _TagChip extends StatelessWidget {
  final void Function(Tag tag) onDeleted;
  final Tag tag;
  const _TagChip(this.tag, {required this.onDeleted});
  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(tag.name),
      deleteIcon: const Icon(Icons.close),
      onDeleted: () {
        onDeleted(tag);
      },
    );
  }
}
