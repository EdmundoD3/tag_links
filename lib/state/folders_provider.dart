import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/repository/folder_repository.dart';
import '../models/folder.dart';

class FoldersNotifier extends AsyncNotifier<List<Folder>> {
  FoldersNotifier(this.parentFolderId);

  final String? parentFolderId;

  FolderRepository get _repo => ref.read(folderRepositoryProvider);

  @override
  Future<List<Folder>> build() async {
    if (parentFolderId == null) {
      return _repo.getRootFolders();
    }

    return _repo.getByParentId(parentFolderId!);
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
    await _repo.update(
      folder.copyWith(isFavorite: !folder.isFavorite),
    );
    ref.invalidateSelf();
  }
}


final foldersProvider =
    AsyncNotifierProvider.family<FoldersNotifier, List<Folder>, String?>(
  (parentFolderId) => FoldersNotifier(parentFolderId),
);
