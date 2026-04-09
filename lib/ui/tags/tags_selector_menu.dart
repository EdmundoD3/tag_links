import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/config/limit_config.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/state/tags_provider.dart';
import 'package:tag_links/ui/search/search_bar.dart';
import 'package:tag_links/ui/search/tags_suggestion_list.dart';
import 'package:tag_links/ui/tags/show_create_tag_modal.dart';
import 'package:tag_links/ui/tags/tag_selected_container.dart';

class TagsSelectorMenu extends ConsumerWidget {
  final List<Tag> tags; // tags que contiene la nota o el folder o buscador
  final void Function(Tag tag) onTagSelected;
  final ValueChanged<Tag> onDeletedTag;
  final void Function()? onClearSave;

  const TagsSelectorMenu({
    super.key,
    required this.tags,
    required this.onTagSelected,
    required this.onDeletedTag,
    this.onClearSave,
  });

@override
Widget build(BuildContext context, WidgetRef ref) {
  final queryText = ref.watch(tagSearchTextProvider);
  final tagsSuggestion = ref.watch(tagsProvider);
  final bool canAddMoreTags = tags.length < LimitAppConfig.maxTagsPerItem;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // 1. Usamos AnimatedOpacity para dar feedback visual suave
      AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: canAddMoreTags ? 1.0 : 0.5, // Opacamos al 50% si llegó al límite
        child: AbsorbPointer(
          absorbing: !canAddMoreTags, // Evita que los toques traspasen si está bloqueado
          child: SearchListBar<Tag>(
            queryText: queryText,
            enabled: canAddMoreTags,
            itemsSuggestion: tagsSuggestion,
            onChangeText: (text) {
              if (text.length <= LimitAppConfig.tagMaxLength) {
                ref.read(tagSearchTextProvider.notifier).state = text;
              }
            },
            onTagSelected: (Tag tag) {
              if (canAddMoreTags) {
                onTagSelected(tag);
                ref.read(tagSearchTextProvider.notifier).state = '';
              }
            },
            suggestionBuilder: TagsSuggestionList(
              itemsSuggestion: tagsSuggestion,
              onItemSelected: (Tag tag) {
                if (canAddMoreTags) {
                  onTagSelected(tag);
                  ref.read(tagSearchTextProvider.notifier).state = '';
                }
              },
            ),
            addIconBtnCtrl: canAddMoreTags
                ? (tagName) async {
                    onClearSave?.call();
                    final newTag = await showCreateTagModal(
                      context: context,
                      ref: ref,
                      initText: tagName,
                    );
                    if (newTag != null) onTagSelected(newTag);
                  }
                : null,
          ),
        ),
      ),

      // 2. Contador integrado (ya no necesita el texto de error abajo)
      Padding(
        padding: const EdgeInsets.only(top: 4, right: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "${tags.length}/${LimitAppConfig.maxTagsPerItem}",
              style: TextStyle(
                fontSize: 12,
                color: canAddMoreTags ? Colors.black54 : Colors.orange,
                fontWeight: canAddMoreTags ? FontWeight.normal : FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 8),

      // Los tags seleccionados NO se opacan, para que sigan siendo legibles y editables
      TagsSelectedContainer(
        tags: tags,
        onDeleted: onDeletedTag,
        onGetNewTag: (tag) {
          if (canAddMoreTags) {
            onClearSave?.call();
            onTagSelected(tag);
          }
        },
      ),
    ],
  );
}
}
