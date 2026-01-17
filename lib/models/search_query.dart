import 'package:tag_links/models/tag.dart';

class SearchQuery {
  final String text;
  final List<Tag> includeTags;
  final List<Tag> excludeTags;

  const SearchQuery({
    required this.text,
    required this.includeTags,
    required this.excludeTags,
  });

  SearchQuery copyWith({
    String? text,
    List<Tag>? includeTags,
    List<Tag>? excludeTags,
  }) {
    return SearchQuery(
      text: text ?? this.text,
      includeTags: includeTags ?? this.includeTags,
      excludeTags: excludeTags ?? this.excludeTags,
    );
  }

  bool get isEmpty => text.isEmpty && includeTags.isEmpty && excludeTags.isEmpty;

  bool get hasIncludeTags => includeTags.isNotEmpty;
  bool get hasExcludeTags => excludeTags.isNotEmpty;

  List<String> get includeTagsIds => includeTags.map((t) => t.id).toList();
  List<String> get excludeTagsIds => excludeTags.map((t) => t.id).toList();
}
