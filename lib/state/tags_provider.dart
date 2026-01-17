import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/repository/tags_repository.dart';
import 'package:tag_links/utils/paginated_utils.dart';

final tagSearchTextProvider = StateProvider<String>((ref) => '');
final _debouncedTagSearchProvider = FutureProvider<String>((ref) async {
  final searchText = ref.watch(tagSearchTextProvider);

  // Se usa debounce para evitar saturar SQLite al escribir rápido
  await Future.delayed(const Duration(milliseconds: 200));

  return searchText;
});

final tagsProvider = AsyncNotifierProvider<TagsNotifier, List<Tag>>(
  TagsNotifier.new,
);

class TagsNotifier extends AsyncNotifier<List<Tag>> {
  TagsRepository get _repo => ref.read(tagsRepositoryProvider);

  @override
  Future<List<Tag>> build() async {
    final searchText = await ref.watch(_debouncedTagSearchProvider.future);

    if (searchText.isEmpty) {
      return _repo.getAll(
        paginated: const PaginatedByUsage(page: 1, pageSize: 10),
      );
    }

    return _repo.getByName(
      searchText,
      paginated: const PaginatedByUsage(page: 1, pageSize: 10),
    );
  }
}
