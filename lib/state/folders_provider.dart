import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/folder_preference.dart';
import 'package:tag_links/models/search_query.dart';
import 'package:tag_links/repository/folder_repository.dart';
import 'package:tag_links/state/search_query_provider.dart';
import 'package:tag_links/utils/paginated_utils.dart';
import '../models/folder.dart';

final foldersViewProvider = Provider<AsyncValue<List<Folder>>>((ref) {
  final searchQuery = ref.watch(searchQueryProvider);
  final pagination = ref.watch(folderPaginationProvider);

  final hasSearch =
      searchQuery.text.isNotEmpty || searchQuery.includeTags.isNotEmpty || searchQuery.isFavorite;

  if (hasSearch) {
    return ref.watch(folderSearchProvider((searchQuery, pagination)));
  }

  return ref.watch(foldersProvider(null));
});

final folderSearchProvider =
    FutureProvider.family<List<Folder>, (SearchQuery, PaginatedByDate)>((
      ref,
      params,
    ) {
      final repo = ref.read(folderRepositoryProvider);
      return repo.searchByQuery(params.$1, paginated: params.$2);
    });

final folderPaginationProvider =
    NotifierProvider<FolderPaginationNotifier, PaginatedByDate>(
      FolderPaginationNotifier.new,
    );

final foldersProvider =
    AsyncNotifierProvider.family<FoldersNotifier, List<Folder>, String?>(
      FoldersNotifier.new,
    );

class FoldersNotifier extends AsyncNotifier<List<Folder>> {
  FoldersNotifier(this.parentFolderId);

  final String? parentFolderId;

  int _page = 1;
  final int _pageSize = 20;

  bool _hasMore = true;
  bool _isLoadingMore = false;

  FolderRepository get _repo => ref.read(folderRepositoryProvider);

  @override
  Future<List<Folder>> build() async {
    _page = 1;
    _hasMore = true;
    _isLoadingMore = false;

    return _fetchPage(reset: true);
  }

  Future<List<Folder>> _fetchPage({bool reset = false}) async {
    final pagination = PaginatedByDate(
      page: _page,
      pageSize: _pageSize,
      order: OrderDate.updatedDesc,
    );

    final items = parentFolderId == null
        ? await _repo.getRootFolders(paginated: pagination)
        : await _repo.getByParentId(parentFolderId!, paginated: pagination);

    if (items.length < _pageSize) {
      _hasMore = false;
    }

    return reset ? items : [...state.value ?? [], ...items];
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    _page++;

    final nextItems = await _fetchPage();
    state = AsyncData(nextItems);

    _isLoadingMore = false;
  }

  // ───────────── CRUD ─────────────

  Future<void> addFolder(Folder folder) async {
    await _repo.create(folder);
    ref.invalidateSelf();
  }

  Future<void> updateFolder(Folder folder) async {
    await _repo.update(folder);
    ref.invalidateSelf();
  }

  Future<void> deleteFolder(String id) async {
    await _repo.delete(id);
    removeFolder(id);
    ref.invalidateSelf();
  }

  void removeFolder(String folderId) {
    final current = state.asData?.value;
    if (current == null) return;

    state = AsyncValue.data(current.where((f) => f.id != folderId).toList());
  }

  Future<void> toggleFavorite(Folder folder) async {
    await _repo.toggleFavorite(folder);
    ref.invalidateSelf();
  }

  Future<FolderDefaultView> getPreference() async {
    if (parentFolderId == null) {
      throw StateError('No parentFolderId');
    }
    return _repo.getPreference(parentFolderId!);
  }

  // ───────────── UI getters ─────────────

  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
}

class FolderPaginationNotifier extends Notifier<PaginatedByDate> {
  @override
  PaginatedByDate build() => const PaginatedByDate();

  void reset() {
    state = const PaginatedByDate();
  }

  void set(PaginatedByDate pagination) {
    state = pagination;
  }
}
