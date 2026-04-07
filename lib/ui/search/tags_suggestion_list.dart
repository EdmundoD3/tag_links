import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/ui/search/search_bar.dart';
import 'package:tag_links/ui/text/empty_tags_text.dart';

class TagsSuggestionList extends SuggestionListBuilder<Tag> {
  const TagsSuggestionList({
    super.key,
    required super.itemsSuggestion, // Pasa los datos al padre
    required super.onItemSelected,  // Pasa el callback al padre
  });

  @override
  Widget build(BuildContext context) {
    // Usamos 'itemsSuggestion' que viene heredado de la clase abstracta
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
    return ListView.builder( // Cambiado a builder por rendimiento
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: tags.length,
      itemBuilder: (context, index) {
        final tag = tags[index];
        return ListTile(
          title: Text(
            tag.name,
            style: TextStyle(color: theme.textTheme.labelSmall?.color),
          ),
          onTap: () => onItemSelected(tag), // Usamos el método del padre
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