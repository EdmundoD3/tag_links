import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/folder_preference.dart';
import 'package:tag_links/models/search_query.dart';
import 'package:tag_links/repository/folder_repository.dart';
import 'package:tag_links/utils/paginated_utils.dart';
import '../models/folder.dart';

final folderSearchProvider =
    FutureProvider.family<List<Folder>, (SearchQuery, PaginatedByDate)>(
  (ref, params) {
    final repo = ref.read(folderRepositoryProvider);
    return repo.searchByQuery(
      params.$1,
      paginated: params.$2,
    );
  },
);

final foldersProvider =
    AsyncNotifierProvider.family<FoldersNotifier, List<Folder>, String?>(
  (parentFolderId) => FoldersNotifier(parentFolderId),
);


class FoldersNotifier extends AsyncNotifier<List<Folder>> {
  FoldersNotifier(this.parentFolderId);

  final String? parentFolderId;
  FolderRepository get _repo => ref.read(folderRepositoryProvider);

  @override
  Future<List<Folder>> build() async {
    if (parentFolderId == null) {
      return _repo.getRootFolders(
        paginated: const PaginatedByDate(),
      );
    }

    return _repo.getByParentId(
      parentFolderId!,
      paginated: const PaginatedByDate(),
    );
  }

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
    ref.invalidateSelf();
  }

  Future<void> toggleFavorite(Folder folder) async {
    await _repo.toggleFavorite(folder);
    ref.invalidateSelf();
  }

  Future<FolderDefaultView> getPreference() async {
    return _repo.getPreference(parentFolderId!);
  }
}
