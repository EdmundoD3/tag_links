import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/data/data_sources/folders_dao.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/utils/paginated_utils.dart';

class FolderRepository{
  final FoldersDao _dao;

  FolderRepository(this._dao);

  Future<void> create(Folder folder) async {
    final folderToSave = folder.ensureForInsert();
    return _dao.insert(folderToSave);
    }

  Future<void> update(Folder folder) {
    final folderToUpdate = folder.ensureForInsert();
    return _dao.update(folderToUpdate);
    }

  Future<void> delete(String folderId) => _dao.delete(folderId);

  Future<Folder?> getById(String id) => _dao.getById(id);

  Future<List<Folder>> getByParentId(String parentId, {PaginatedParams paginated = const PaginatedParams()}) => _dao.getByParentId(parentId, paginated: paginated);

  Future<List<Folder>> getRootFolders({PaginatedParams paginated = const PaginatedParams()}) => _dao.getRootFolders(paginated: paginated);

  Future<List<Folder>> getFavorites({PaginatedParams paginated = const PaginatedParams()}) => _dao.getFavorites(paginated: paginated);
}

final foldersDaoProvider = Provider((ref) => FoldersDao());

final folderRepositoryProvider = Provider<FolderRepository>((ref) {
  return FolderRepository(ref.read(foldersDaoProvider));
});