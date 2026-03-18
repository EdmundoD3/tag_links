import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/state/tags_provider.dart';
import 'package:tag_links/ui/search/search_bar.dart';
import 'package:tag_links/ui/tags/show_create_tag_modal.dart';
import 'package:tag_links/ui/tags/tag_selected_container.dart';

class TagsSelectorMenu extends ConsumerWidget {
  final List<Tag> tags;
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
    final tagsSuggestion = queryText.trim().isEmpty
        ? const AsyncValue.data(<Tag>[])
        : ref.watch(tagsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchListBar(
          queryText: queryText,
          tagsSuggestion: tagsSuggestion,
          onChangeText: (text) {
            ref.read(tagSearchTextProvider.notifier).state = text;
          },
          onTagSelected: (Tag tag) {
            onTagSelected(tag);
            ref.read(tagSearchTextProvider.notifier).state = '';
          },
          addIconBtnCtrl: (tagName) async {
             onClearSave?.call();
            final newTag = await showCreateTagModal(
              context: context,
              ref: ref,
              initText: tagName,
            );
            if (newTag != null) onTagSelected(newTag);
          },
        ),
        TagsSelectedContainer(
          tags: tags,
          onDeleted: onDeletedTag,
          onGetNewTag: (tag) {
            onClearSave?.call();
            onTagSelected(tag);
          },
        ),
      ],
    );
  }
}
