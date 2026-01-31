import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/search_query.dart';
import 'package:tag_links/models/tag.dart';

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, SearchQuery>(
  SearchQueryNotifier.new,
);

class SearchQueryNotifier extends Notifier<SearchQuery> {
  @override
  SearchQuery build() {
    return const SearchQuery(
      text: '',
      includeTags: [],
      excludeTags: [],
      isFavorite: false,
    );
  }

  void setText(String text) {
    state = state.copyWith(text: text);
  }

  void addTag(Tag tag) {
    if (state.includeTags.any((t) => t.id == tag.id)) return;

    state = state.copyWith(includeTags: [...state.includeTags, tag], text: '');
  }

  void removeTag(Tag tag) {
    state = state.copyWith(
      includeTags: state.includeTags.where((t) => t.id != tag.id).toList(),
    );
  }

  void toggleFavorite() {
    state = state.copyWith(isFavorite: !state.isFavorite);
  }

  void setFavorite(bool isFavorite) {
    state = state.copyWith(isFavorite: isFavorite);
  }

  void clear() {
    state = SearchQuery(
      text: '',
      includeTags: [],
      excludeTags: [],
      isFavorite: state.isFavorite, // se conserva el filtro
    );
  }
}
