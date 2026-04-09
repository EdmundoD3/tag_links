import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/locate/t_keys.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/repository/tags_repository.dart';
import 'package:tag_links/state/tags_provider.dart';
import 'package:tag_links/ui/alerts/confirm_dialog.dart';
import 'package:tag_links/ui/tags/show_create_tag_modal.dart';
import 'package:tag_links/ui/tags/show_edit_tag_modal.dart';

class TagsSelectedContainer extends ConsumerWidget {
  final void Function(Tag tag) onDeleted;
  final void Function(Tag tag)? onGetNewTag;
  final List<Tag> tags;
  final bool? isCreateTag;

  const TagsSelectedContainer({
    super.key,
    required this.tags,
    required this.onDeleted,
    this.onGetNewTag,
    this.isCreateTag = true,
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
            //el tag que llega puede estar cortado por conveniencia, asi que para obtener los datos confiables
            //mejor se obtienen de la db
            onEdit: (tag) async {
              final realTag = await ref
                  .read(tagsRepositoryProvider)
                  .getById(tag.id);
              if (!context.mounted) return;

              final result = await showEditTagModal(
                context,
                ref,
                realTag ?? tag,
              );

              // 1. Si es null, el usuario simplemente cerró el modal. No hacemos nada.
              if (result == null) return;

              // 2. Si marcó para eliminar
              if (result.isDeleted) {
                debugPrint( "TagSelectedContainer: ${result.isDeleted.toString()}");
                if (!context.mounted) return;
                await ConfirmDialog.deleteTag(context, ref, () async {
                  onDeleted(tag);
                  await ref.read(tagsProvider.notifier).deleteTag(tag);
                });
                return;
              }

              // 3. Si no es borrado, es una actualización normal
              await ref.read(tagsProvider.notifier).updateTag(result.tag);
            },
          ),
        ),
        if (isCreateTag == true) _createTagChip(context, ref),
      ],
    );
  }

  ActionChip _createTagChip(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return ActionChip(
      elevation: 0,
      label: Text(
        ref.tr(TKeys.tags.create, fallback: 'Crear nuevo tag'),
        style: TextStyle(color: theme.textTheme.titleLarge?.color),
      ),
      backgroundColor: theme.cardColor,
      side: BorderSide(color: theme.focusColor, width: 1),
      avatar: Icon(Icons.add, color: theme.textTheme.titleLarge?.color),
      surfaceTintColor: Colors.transparent,
      onPressed: () async {
        final newTag = await showCreateTagModal(context: context, ref: ref);
        if (newTag != null) {
          onGetNewTag?.call(newTag);
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
    final theme = Theme.of(context);
    return GestureDetector(
      onLongPress: () => onEdit(tag),
      child: Chip(
        backgroundColor: theme.appBarTheme.backgroundColor,
        label: Text(
          tag.title,
          style: TextStyle(color: theme.textTheme.titleLarge?.color),
        ),
        deleteIcon: const Icon(Icons.close),
        onDeleted: () => onDeleted(tag),
      ),
    );
  }
}
