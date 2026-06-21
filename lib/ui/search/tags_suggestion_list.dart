import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/ui/text/empty_tags_text.dart';

/// Widget que renderiza la lista de sugerencias de tags.
/// Ahora es un StatelessWidget normal, NO extiende una clase abstracta.
class TagsSuggestionList extends StatelessWidget {
  final AsyncValue<List<Tag>> itemsSuggestion;
  final void Function(Tag item) onItemSelected;

  const TagsSuggestionList({
    super.key,
    required this.itemsSuggestion,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return itemsSuggestion.when(
      data: (tags) => _whenData(tags, context),
      loading: _loading,
      error: (e, _) {
        debugPrint('TagsSuggestionList Error: $e');
        return const Text('Error: Tags');
      },
    );
  }

  Widget _whenData(List<Tag> tags, BuildContext context) {
    if (tags.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: EmptyTagsText(),
      );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 240),
      child: _listTags(tags, context),
    );
  }

  Widget _listTags(List<Tag> tags, BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: tags.length,
      itemBuilder: (context, index) {
        final tag = tags[index];
        return ListTile(
          title: Text(
            tag.title,
            style: TextStyle(color: theme.textTheme.labelSmall?.color),
          ),
          onTap: () => onItemSelected(tag),
        );
      },
    );
  }

  Widget _loading() {
    return const Padding(
      padding: EdgeInsets.all(8),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}