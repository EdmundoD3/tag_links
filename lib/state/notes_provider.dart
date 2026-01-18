import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:tag_links/models/search_query.dart';
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

  return ref.watch(
    noteSearchProvider((searchQuery, pagination)),
  );
});

final noteSearchProvider = FutureProvider.family<
    List<Note>,
    (SearchQuery, PaginatedByDate)>((ref, params) {
  final repo = ref.read(notesRepositoryProvider);

  return repo.searchByQuery(
    params.$1,
    paginated: params.$2,
  );
});

final notePaginationProvider =
    StateProvider<PaginatedByDate>((ref) => const PaginatedByDate());

final notesProvider =
    AsyncNotifierProvider.family<NotesNotifier, List<Note>, String?>(
  NotesNotifier.new,
);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  NotesNotifier(this.folderId);

  final String? folderId;

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

  Future<void> updateNote(Note note) async {
    await _repo.update(note);
    ref.invalidateSelf();
  }

  Future<void> deleteNote(String id) async {
    await _repo.delete(id);
    ref.invalidateSelf();
  }
}
