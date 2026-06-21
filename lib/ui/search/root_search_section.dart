import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/folder_preference.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/state/folders_provider.dart';
import 'package:tag_links/state/notes_provider.dart';
import 'package:tag_links/state/search_query_provider.dart';
import 'package:tag_links/state/tags_provider.dart';
import 'package:tag_links/ui/button/switch_favorite.dart';
import 'package:tag_links/ui/search/search_bar.dart';
import 'package:tag_links/ui/search/tags_suggestion_list.dart';
import 'package:tag_links/ui/tags/tag_selected_container.dart';

class RootSearchSection extends ConsumerStatefulWidget {
  final FolderDefaultView currentView;

  const RootSearchSection({
    super.key,
    required this.currentView,
  });

  @override
  ConsumerState<RootSearchSection> createState() => _RootSearchSectionState();
}

class _RootSearchSectionState extends ConsumerState<RootSearchSection> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    // 🛡️ NUNCA empieza con foco — se desenfoca después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.unfocus();
    });
  }

  @override
  void didUpdateWidget(RootSearchSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si cambiamos a Folders, desenfocamos
    if (oldWidget.currentView != widget.currentView &&
        widget.currentView == FolderDefaultView.folders) {
      _focusNode.unfocus();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _SearchBarInternal(focusNode: _focusNode),
        ),
        const SizedBox(height: 16),
        TagsSelectedContainer(
          tags: ref.watch(searchQueryProvider).includeTags,
          onDeleted: (Tag tag) {
            ref.read(searchQueryProvider.notifier).removeTag(tag);
          },
          isCreateTag: false,
        ),
      ],
    );
  }
}

class _SearchBarInternal extends ConsumerWidget {
  final FocusNode focusNode;

  const _SearchBarInternal({required this.focusNode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagsProvider);
    final queryText = ref.watch(searchQueryProvider).text;

    return SearchListBar<Tag>(
      queryText: queryText,
      itemsSuggestion: tagsAsync,
      focusNode: focusNode,
      iconLeftBtn: SwitchFavorite(
        isFavorite: ref.read(searchQueryProvider).isFavorite,
        onChanged: () {
          ref.read(searchQueryProvider.notifier).toggleFavorite();
        },
      ),
      onChangeText: (String text) {
        ref.read(searchQueryProvider.notifier).setText(text);
        ref.read(tagSearchTextProvider.notifier).state = text;
        ref.invalidate(foldersProvider(null));
        ref.invalidate(notesProvider(null));
      },
      onItemSelected: (Tag tag) {
        ref.read(searchQueryProvider.notifier).addTag(tag);
        focusNode.unfocus();
      },
      suggestionBuilder: (context, itemsSuggestion, onItemSelected) {
        return TagsSuggestionList(
          itemsSuggestion: itemsSuggestion,
          onItemSelected: onItemSelected,
        );
      },
    );
  }
}