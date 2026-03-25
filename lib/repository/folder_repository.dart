import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/data/data_sources/deleted_dao.dart';
import 'package:tag_links/data/data_sources/folder_preferences_dao.dart';
import 'package:tag_links/data/data_sources/folder_tags_dao.dart';
import 'package:tag_links/data/data_sources/folders_dao.dart';
import 'package:tag_links/data/database.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/models/folder_preference.dart';
import 'package:tag_links/models/search_query.dart';
import 'package:tag_links/utils/paginated_utils.dart';

class FolderRepository {
  final FoldersDao _dao;
  final DeletedFoldersDao _deletedDao;
  final FolderPreferencesDao _preferencesDao;

  FolderRepository(this._dao, this._preferencesDao, this._deletedDao);

  Future<List<Folder>> searchByQuery(
    SearchQuery query, {
    required PaginatedByDate paginated,
  }) async {
    return _dao.searchByQuery(query, paginated: paginated);
  }

  Future<void> upsertAll(List<Folder> folders) {
    final enshuredFolders = folders.map((f) => f.ensureForInsert()).toList();
    return _dao.upsertAll(enshuredFolders);
  }

  Future<void> deleteByIds(List<String> ids) {
    return _dao.serverDeleteByIds(ids);
  }

  Future<void> create(Folder folder) async {
    final folderToSave = folder.ensureForInsert();
    return _dao.upsert(folderToSave);
  }

  Future<void> upsert(Folder folder) {
    debugPrint(folder.parentId);

    final folderToUpdate = folder.ensureForInsert();
    return _dao.upsert(folderToUpdate);
  }

  Future<void> delete(String folderId) => _dao.delete(folderId);

  Future<Folder?> getById(String id) => _dao.getById(id);

  Future<List<Folder>> getByParentId(
    String parentId, {
    required PaginatedByDate paginated,
  }) => _dao.getByParentId(parentId, paginated: paginated);

  Future<List<Folder>> getRootFolders({required PaginatedByDate paginated}) =>
      _dao.getRootFolders(paginated: paginated);

  Future<List<Folder>> getFavorites({required PaginatedByDate paginated}) =>
      _dao.getFavorites(paginated: paginated);

  Future<Set<String>> getAllDescendantIds(String folderId) async {
    return _dao.getAllDescendantIds(folderId);
  }

  Future<void> toggleFavorite(Folder folder) {
    return upsert(
      folder.copyWith(
        isFavorite: !folder.isFavorite,
        parentId: folder.parentId,
      ),
    );
  }
  // --------------------- PREFERENCES section ----------------------//

  Future<FolderDefaultView> getPreference(String folderId) async {
    return _preferencesDao.getDefaultView(folderId);
  }

  Future<void> savePreference(String folderId, FolderDefaultView view) async {
    await _preferencesDao.upsert(
      FolderPreference(folderId: folderId, defaultView: view),
    );
  }

  // ---------------------------- MOVE ---------------------------- //
  Future<void> moveAndFlatten(
    Folder folder,
    String? newParentId, {
    bool toRoot = true,
  }) => _dao.moveAndFlatten(folder, newParentId,toRoot: true);

  Future<bool> hasChildren(String folderId) async {
    return _dao.hasChildren(folderId);
  }

  // ----------------------- SYNC section ------------------------- //
  Future<Future<void>> updateSyncAt(List<String> ids, int syncAt) async {
    return _dao.updateSyncAt(ids, syncAt);
  }

  Future<void> clearDeletedNotes(List<String> ids) {
    return _deletedDao.deleteIds(ids);
  }
}

final folderRepositoryProvider = Provider<FolderRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final foldersDao = FoldersDao(
    db: db,
    folderTagsDao: FolderTagsDao(db),
    deletedFoldersDao: DeletedFoldersDao(db: db),
  );
  final deleteDao = DeletedFoldersDao(db: db);
  final preferencesDao = FolderPreferencesDao(db: db);

  return FolderRepository(foldersDao, preferencesDao, deleteDao);
});
