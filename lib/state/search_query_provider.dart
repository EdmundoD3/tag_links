import 'package:flutter_riverpod/legacy.dart';
import 'package:tag_links/models/search_query.dart';
import 'package:tag_links/models/tag.dart';
final searchQueryProvider =
    StateNotifierProvider<SearchQueryNotifier, SearchQuery>(
  (ref) => SearchQueryNotifier(),
);



class SearchQueryNotifier extends StateNotifier<SearchQuery> {
  SearchQueryNotifier()
      : super(const SearchQuery(text: '', includeTags: [], excludeTags: []));

  void setText(String text) {
    state = state.copyWith(text: text);
  }

    void addTag(Tag tag) {
    if (state.includeTags.any((t) => t.id == tag.id)) return;
    state = state.copyWith(
      includeTags: [...state.includeTags, tag],
      text: '',
    );
  }

  void removeTag(Tag tag) {
    state = state.copyWith(
      includeTags:
          state.includeTags.where((t) => t.id != tag.id).toList(),
    );
  }

  void clear() {
    state = SearchQuery(
      text: '',
      includeTags: [],
      excludeTags: [],
    );
  }
}

