import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/repository/tags_repository.dart';
import 'package:tag_links/state/folders_provider.dart';
import 'package:tag_links/state/notes_provider.dart';
import 'package:tag_links/utils/paginated_utils.dart';

final tagSearchTextProvider = StateProvider.autoDispose<String>((ref) => '');

final _debouncedTagSearchProvider = FutureProvider.autoDispose<String>((
  ref,
) async {
  final searchText = ref.watch(tagSearchTextProvider);
  await Future.delayed(const Duration(milliseconds: 220));
  return searchText;
});

final tagsProvider = AsyncNotifierProvider<TagsNotifier, List<Tag>>(
  TagsNotifier.new,
);

class TagsNotifier extends AsyncNotifier<List<Tag>> {
  TagsRepository get _repo => ref.watch(tagsRepositoryProvider);

  @override
  Future<List<Tag>> build() async {
    // 1. Observamos el estado del provider debounced
    final searchState = ref.watch(_debouncedTagSearchProvider);

    // 2. Extraemos el valor del texto.
    // Si está cargando, usamos el valor que ya teníamos (si existe) o un string vacío.
    final String searchText = searchState.value ?? '';

    // 3. Ejecutamos la consulta
    if (searchText.isEmpty) {
      debugPrint('DEBUG: Buscando todos los tags (vacío)');
      return _repo.getAll(
        paginated: const PaginatedByUsage(page: 1, pageSize: 10),
      );
    }

    debugPrint('DEBUG: Buscando tags por nombre: $searchText');
    return _repo.getByName(
      searchText,
      paginated: const PaginatedByUsage(page: 1, pageSize: 10),
    );
  }

  Future<Tag?> addTag(Tag tag) async {
    debugPrint(tag.toMap().toString());
    final savedTag = await _repo.upsert(tag);
    ref.invalidateSelf();
    return savedTag;
  }

  Future<void> updateTag(Tag tag) async {
    await _repo.update(tag);
    ref.invalidateSelf();
  }

  Future<void> deleteTag(Tag tag) async {
    await _repo.delete(tag);
    ref.invalidate(notesProvider);
    ref.invalidate(foldersProvider);
    ref.invalidateSelf();
  }

  Future<Tag?> getByExactlyName(String name) {
    return _repo.getByExactlyName(name);
  }
}
