import 'package:tag_links/models/tag.dart';

class SearchQuery {
  final String text;
  final bool isFavorite;
  final List<Tag> includeTags;
  final List<Tag> excludeTags;

  const SearchQuery({
    required this.text,
    required this.includeTags,
    required this.excludeTags,
    required this.isFavorite,
  });

  SearchQuery copyWith({
    String? text,
    List<Tag>? includeTags,
    List<Tag>? excludeTags,
    bool? isFavorite,
  }) {
    return SearchQuery(
      text: text ?? this.text,
      includeTags: includeTags ?? this.includeTags,
      excludeTags: excludeTags ?? this.excludeTags,
      isFavorite: isFavorite??this.isFavorite,
    );
  }

  bool get isEmpty =>
    text.isEmpty &&
    includeTags.isEmpty &&
    excludeTags.isEmpty &&
    !isFavorite;


  bool get hasIncludeTags => includeTags.isNotEmpty;
  bool get hasExcludeTags => excludeTags.isNotEmpty;

  List<String> get includeTagsIds => includeTags.map((t) => t.id).toList();
  List<String> get excludeTagsIds => excludeTags.map((t) => t.id).toList();
}
