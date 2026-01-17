import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/state/search_query_provider.dart';
import 'package:tag_links/utils/paginated_utils.dart';
import '../models/note.dart';
import '../repository/notes_repository.dart';

final notesProvider =
    AsyncNotifierProvider.family<NotesNotifier, List<Note>, String?>(
      NotesNotifier.new,
    );

class NotesNotifier extends AsyncNotifier<List<Note>> {
  final String? folderId;
  int _page = 1;
  final int _pageSize = 20;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  NotesNotifier(this.folderId);

  NotesRepository get _repo => ref.read(notesRepositoryProvider);

  @override
  Future<List<Note>> build() async {
    _page = 1;
    _hasMore = true;
    final query = ref.watch(searchQueryProvider);

    if (query.isEmpty) {
      if (folderId == null) {
        return _repo.getFavorites(pagination: const PaginatedByDate());
      }
      return _repo.getByFolder(folderId!, pagination: const PaginatedByDate());
    }

    return _repo.searchByQuery(query, paginated: const PaginatedByDate());
  }

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

    if (reset) return newItems;

    return [...state.value ?? [], ...newItems];
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    _page++;

    final current = state.value ?? [];
    final next = await _fetchPage();

    state = AsyncData([...current, ...next]);
    _isLoadingMore = false;
  }
}
