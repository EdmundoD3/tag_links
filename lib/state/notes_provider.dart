import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      final repo = ref.read(notesRepositoryProvider);

      return repo.searchByQuery(params.$1, paginated: params.$2);
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
  NotesRepository get _repo => ref.read(notesRepositoryProvider);

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

    final newItems = folderId == null
        ? await _repo.getFavorites(pagination: pagination)
        : await _repo.getByFolder(folderId!, pagination: pagination);

    if (newItems.length < _pageSize) {
      _hasMore = false;
    }

    //revisar
    final links = newItems
        .map((n) => n.link)
        .whereType<LinkPreview>()
        .where((l) => !l.hasMetadata)
        .fold<Map<String, LinkPreview>>({}, (map, link) {
          map[link.url] = link;
          return map;
        })
        .values
        .toList();
    unawaited(_enrichLinks(links));

    return reset ? newItems : [...state.value ?? [], ...newItems];
  }

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    // 🔁 fuerza rebuild
    state = AsyncData(state.value ?? []);

    _page++;

    final updated = await _fetchPage();
    state = AsyncData(updated);

    _isLoadingMore = false;
    // 🔁 rebuild final
    state = AsyncData(state.value ?? []);
  }

  // CRUD
  Future<void> addNote(Note note) async {
    await _repo.create(note);
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

  Future<void> updateNote(Note note) async {
    await _repo.update(note);
    ref.invalidateSelf();
  }

  Future<void> deleteNote(String id) async {
    final current = state.asData?.value;
    if (current == null) return;

    state = AsyncValue.data(current.where((note) => note.id != id).toList());

    try {
      await _repo.delete(id);
    } catch (e) {
      // ❌ rollback si falla
      state = AsyncValue.data(current);
      rethrow;
    }
  }

  Future<void> _enrichLinks(List<LinkPreview> links) async {
    final service = LinkPreviewService();
    final repoLinkPreview = ref.read(linkPreviewRepositoryProvider);
    bool updatedAny = false;

    for (final link in links) {
      final updated = await service.enrich(link);
      if (updated != null && updated.hasMetadata) {
        await repoLinkPreview.replace(updated);
        updatedAny = true;
      }
    }

    if (updatedAny) {
      ref.invalidateSelf();
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
