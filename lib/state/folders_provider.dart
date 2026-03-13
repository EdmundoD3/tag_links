import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/sync/sync_notifier.dart';
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
    _page++;

    final nextItems = await _fetchPage();
    state = AsyncData(nextItems);

    _isLoadingMore = false;
  }

  // ───────────── CRUD ─────────────

  Future<void> addFolder(Folder folder) async {
    await _repo.create(folder);
    unawaited(ref.read(syncNotifierProvider.notifier).performSync());
    // En el caso de añadir, invalidateSelf está bien para traer el orden correcto de DB
    ref.invalidateSelf();
  }

  // En FoldersNotifier...

  Future<void> updateFolder(Folder folder) async {
    // 1. Guardar en DB para que el cambio sea permanente
    await _repo.update(folder);

    // 2. Sync
    unawaited(ref.read(syncNotifierProvider.notifier).performSync());

    // 3. Actualizar UI manualmente para que el movimiento sea fluido
    state.whenData((currentItems) {
      final index = currentItems.indexWhere((f) => f.id == folder.id);
      if (index != -1) {
        // Si ya está aquí, reemplazamos
        final newList = [...currentItems];
        newList[index] = folder;
        state = AsyncData(newList);
      } else {
        // Si no está (es porque viene de otro padre), la añadimos
        state = AsyncData([folder, ...currentItems]);
      }
    });
  }

  void removeFolder(String folderId) {
    state.whenData((currentItems) {
      state = AsyncData(currentItems.where((f) => f.id != folderId).toList());
    });
  }

  Future<void> deleteFolder(String id) async {
    // 1. Borrar de la base de datos (¡Este faltaba!)
    await _repo.delete(id);

    // 2. Sync
    unawaited(ref.read(syncNotifierProvider.notifier).performSync());

    // 3. Quitar de la UI
    removeFolder(id);

    // 4. Invalida para asegurar que la paginación se recalcule bien
    ref.invalidateSelf();
  }

  Future<void> toggleFavorite(Folder folder) async {
    await _repo.toggleFavorite(folder);
    // Para favoritos, como suele cambiar el icono, invalidar es lo más seguro
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
