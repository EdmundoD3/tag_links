import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/state/tags_provider.dart';
import 'package:tag_links/ui/tags/show_create_tag_modal.dart';
import 'package:tag_links/ui/tags/show_edit_tag_modal.dart';

class TagsSelectedContainer extends ConsumerWidget {
  final void Function(Tag tag) onDeleted;
  final List<Tag> tags;
  final bool? isCreateTag;

  const TagsSelectedContainer({
    super.key,
    required this.tags,
    required this.onDeleted, this.isCreateTag = true,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 8,
      children: [
        ...tags.map(
          (tag) => _TagChip(
            tag,
            onDeleted: onDeleted,
            onEdit: (tag) async {
              final result = await showEditTagModal(context, tag);

              if (result == null) {
                ref.read(tagsProvider.notifier).deleteTag(tag.id);
                return;
              }

              ref.read(tagsProvider.notifier).updateTag(result);
            },
          ),
        ),
        if (isCreateTag == true) _createTagChip(context, ref),
      ],
    );
  }

  ActionChip _createTagChip(BuildContext context, WidgetRef ref) {
    return ActionChip(
      label: const Text('Nuevo tag'),
      avatar: const Icon(Icons.add),
      onPressed: () async {
        final newTag = await showCreateTagModal(context);
        if (newTag != null) {
          ref.read(tagsProvider.notifier).addTag(newTag);
        }
      },
    );
  }
}

class _TagChip extends StatelessWidget {
  final void Function(Tag tag) onDeleted;
  final void Function(Tag tag) onEdit;
  final Tag tag;

  const _TagChip(this.tag, {required this.onDeleted, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => onEdit(tag),
      child: Chip(
        label: Text(tag.name),
        deleteIcon: const Icon(Icons.close),
        onDeleted: () => onDeleted(tag),
      ),
    );
  }
}
