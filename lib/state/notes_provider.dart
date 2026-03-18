import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/sync/sync_notifier.dart';
import 'package:tag_links/models/link_preview.dart';
import 'package:tag_links/models/search_query.dart';
import 'package:tag_links/repository/link_preview_repository.dart';
import 'package:tag_links/service/link_preview_service.dart';
import 'package:tag_links/state/search_query_provider.dart';
import 'package:tag_links/utils/paginated_utils.dart';
import '../models/note.dart';
import '../repository/notes_repository.dart';

final notesViewProvider = Provider<AsyncValue<List<Note>>>((ref) {
  final searchQuery = ref.watch(searchQueryProvider);
  final pagination = ref.watch(notePaginationProvider);

  final hasSearch =
      searchQuery.text.isNotEmpty || searchQuery.includeTags.isNotEmpty;

  if (!hasSearch) {
    return ref.watch(notesProvider(null)); // favoritas
  }

  return ref.watch(noteSearchProvider((searchQuery, pagination)));
});

final noteSearchProvider =
    FutureProvider.family<List<Note>, (SearchQuery, PaginatedByDate)>((
      ref,
      params,
    ) {
      final repo = ref.watch(notesRepositoryProvider);

      return repo.searchByQuery(params.$1, paginated: params.$2, folderFilter: FolderFilter.all);
    });

final notePaginationProvider =
    NotifierProvider<NotePaginationNotifier, PaginatedByDate>(
      NotePaginationNotifier.new,
    );

final notesProvider =
    AsyncNotifierProvider.family<NotesNotifier, List<Note>, String?>(
      NotesNotifier.new,
    );

class NotesNotifier extends AsyncNotifier<List<Note>> {
  final String? folderId;

  NotesNotifier(this.folderId);

  int _page = 1;
  final int _pageSize = 20;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  NotesRepository get _repo => ref.watch(notesRepositoryProvider);
  LinkPreviewRepository get _repoLinkPreview =>
      ref.watch(linkPreviewRepositoryProvider);

  @override
  Future<List<Note>> build() async {
    _page = 1;
    _hasMore = true;
    _isLoadingMore = false;

    return _fetchPage(reset: true);
  }

  Future<List<Note>> _fetchPage({bool reset = false}) async {
    final pagination = PaginatedByDate(
      page: _page,
      pageSize: _pageSize,
      order: OrderDate.updatedDesc,
    );
    final newItems = await _repo.getByFolder(folderId, pagination: pagination);

    if (newItems.length < _pageSize) {
      _hasMore = false;
    }

    //revisar
    final linksToEnrich = newItems
        .map((n) => n.link)
        .whereType<LinkPreview>()
        .where((l) => !l.hasMetadata)
        .fold<Map<String, LinkPreview>>({}, (map, link) {
          map[link.url] = link;
          return map;
        })
        .values
        .toList();
    if (linksToEnrich.isNotEmpty) {
      unawaited(_enrichLinks(linksToEnrich));
    }

    return reset ? newItems : [...state.value ?? [], ...newItems];
  }

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    // Solo notificamos que estamos cargando más si es necesario para la UI
    // pero no reseteamos el estado para no perder la scroll position
    _page++;

    try {
      final updatedList = await _fetchPage();
      state = AsyncData(updatedList);
    } catch (e, st) {
      _page--; // Revertir página si falla
      state = AsyncError(e, st);
    } finally {
      _isLoadingMore = false;
    }
  }

  // CRUD
  Future<void> addNote(Note note) async {
    await _repo.create(note);
    // Disparamos el sync sin esperar (await) su respuesta aquí
    unawaited(ref.read(syncNotifierProvider.notifier).performSync());
    ref.invalidateSelf();
  }

  void removeNote(String id) {
    final current = state.asData?.value;
    if (current == null) return;

    final updated = current.where((note) => note.id != id).toList();

    if (updated.length < _pageSize) {
      _hasMore = false;
    }

    state = AsyncValue.data(updated);
  }

  Future<void> upsert(Note note) async {
    debugPrint('guardando nota con folder: ${note.folderId}');
    await _repo.upsert(note);
    unawaited(ref.read(syncNotifierProvider.notifier).performSync());

    // Actualización optimista: No invalides, solo actualiza el item en la lista
    state.whenData((notes) {
      state = AsyncData(notes.map((n) => n.id == note.id ? note : n).toList());
    });
  }

  void updateNoteState(Note note) {
    state.whenData((currentNotes) {
      // Si la nota ya existe la actualizamos, si no la insertamos al inicio
      final index = currentNotes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        final newList = [...currentNotes];
        newList[index] = note;
        state = AsyncData(newList);
      } else {
        state = AsyncData([note, ...currentNotes]);
      }
    });
  }

  Future<void> deleteNote(Note noteForDelete) async {
    final current = state.asData?.value;
    if (current == null) return;

    state = AsyncValue.data(
      current.where((note) => note.id != noteForDelete.id).toList(),
    );

    try {
      await _repo.delete(noteForDelete);
      unawaited(ref.read(syncNotifierProvider.notifier).performSync());
    } catch (e) {
      // ❌ rollback si falla
      state = AsyncValue.data(current);
      rethrow;
    }
  }

  Future<void> _enrichLinks(List<LinkPreview> links) async {
    final service = LinkPreviewService();

    bool updatedAny = false;

    for (final link in links) {
      final updated = await service.enrich(link);
      if (updated != null && updated.hasMetadata) {
        await _repoLinkPreview.replace(updated);
        updatedAny = true;
      }
    }

    // 🚩 CAMBIO CLAVE: En lugar de invalidateSelf (que crea bucles),
    // podrías usar un evento de bus o simplemente dejar que la UI
    // se actualice la próxima vez que el usuario navegue.
    // Si necesitas que sea real-time, actualiza el estado local de la nota.
    if (updatedAny) {
      // Opcional: Solo refrescar si es vital, pero con cuidado del bucle.
      // ref.invalidateSelf();
    }
  }
}

class NotePaginationNotifier extends Notifier<PaginatedByDate> {
  @override
  PaginatedByDate build() {
    return const PaginatedByDate();
  }

  void reset() {
    state = const PaginatedByDate();
  }

  void set(PaginatedByDate pagination) {
    state = pagination;
  }
}
