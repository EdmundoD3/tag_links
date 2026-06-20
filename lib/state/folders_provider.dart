import 'dart:async';

import 'package:flutter/rendering.dart';
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
      searchQuery.text.isNotEmpty ||
      searchQuery.includeTags.isNotEmpty ||
      searchQuery.isFavorite;

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
      final repo = ref.watch(folderRepositoryProvider);
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

  FolderRepository get _repo => ref.watch(folderRepositoryProvider);

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

    try {
      _page++;

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

      final current = state.value ?? [];
      state = AsyncData([...current, ...items]);
    } finally {
      _isLoadingMore = false;
    }
  }

  // ───────────── CRUD ─────────────

Future<void> saveFolder(Folder folder) async {
  await _repo.upsert(folder);

  state.whenData((currentItems) {
    final map = {
      for (final item in currentItems) item.id: item,
    };

    map[folder.id] = folder;

    state = AsyncData(map.values.toList());
  });
}

  void removeFolder(String folderId) {
    state.whenData((currentItems) {
      state = AsyncData(currentItems.where((f) => f.id != folderId).toList());
    });
  }

  Future<void> deleteFolder(Folder folder) async {
    try {
      debugPrint('FoldersNotifier.deleteFolder: ${folder.toMap().toString()}');
      await _repo.delete(folder);
      // 3. Quitar de la UI
      removeFolder(folder.id);
    } catch (e) {
      debugPrint(
        'FoldersNotifier.deleteFolder: Error al borrar folder: ${folder.toMap()} \n Error: $e',
      );
    }
  }

  Future<void> toggleFavorite(Folder folder) async {
    await _repo.toggleFavorite(folder);

    state.whenData((current) {
      final index = current.indexWhere((f) => f.id == folder.id);
      if (index == -1) return;

      final updated = [...current];
      updated[index] = folder.copyWith(isFavorite: !folder.isFavorite);
      state = AsyncData(updated);
    });
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
