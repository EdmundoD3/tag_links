import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/data/data_sources/deleted_dao.dart';
import 'package:tag_links/data/data_sources/folder_preferences_dao.dart';
import 'package:tag_links/data/data_sources/folders_dao.dart';
import 'package:tag_links/data/database.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/models/folder_preference.dart';
import 'package:tag_links/models/search_query.dart';
import 'package:tag_links/sync/db/local_sync_queue_dao.dart';
import 'package:tag_links/sync/models/folders_file.dart';
import 'package:tag_links/utils/paginated_utils.dart';

class FolderRepository {
  final FoldersDao _dao;
  final DeletedDao _deletedDao;
  final FolderPreferencesDao _preferencesDao;

  FolderRepository(
    this._dao,
    this._preferencesDao,
    this._deletedDao,
  );

  Future<List<Folder>> searchByQuery(
    SearchQuery query, {
    required PaginatedByDate paginated,
  }) async {
    return _dao.searchByQuery(query, paginated: paginated);
  }

  Future<void> upsertAll(List<Folder> folders) async {
    
    return _dao.upsertAll(folders);
  }

  Future<void> create(Folder folder) async {
    return _dao.upsert(folder);
  }

  Future<void> upsert(Folder folder) async {
    return _dao.upsert(folder);
  }

  Future<void> delete(Folder folder) async {
    //este ya gestiona mark as dirty y deletedDao
    return _dao.delete(folder.id);
  }

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

  Future<void> toggleFavorite(Folder folder) async {
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
  }) async {
    return _dao.moveAndFlatten(folder, newParentId, toRoot: true);
  }

  Future<bool> hasChildren(String folderId) async {
    return _dao.hasChildren(folderId);
  }

  // ----------------------- SYNC section ------------------------- //
Future<List<Folder>> getByFileId(String fileId) async {
  return _dao.getByFileId(fileId);
}

/// Genera el Wrapper de carpetas listo para la sincronización.
Future<FoldersFile> getFileWrapper({
  required String fileId,
  String? driveFileId,
  required DateTime now,
}) async {
  final items = await getByFileId(fileId);

  return FoldersFile(
    id: fileId,
    fileId: driveFileId ?? '',
    folders: items,
    createdAt: now,
    updatedAt: now,
  );
}

  Future<void> serverDeleteByIds(List<String> ids) async {
    return _dao.serverDeleteByIds(ids);
  }

  // Obtener los registros borrados para subirlos a la nube
  Future<List<DeletedData>> getDeletedBatch(String fileId) => 
      _deletedDao.getBatchByFileIdAndType(fileId,DeletedType.folder);
}

final folderRepositoryProvider = Provider<FolderRepository>((ref) {
  final db = ref.read(databaseProvider);
  final deletedDao = ref.read(deletedDaoProvider);
  final foldersDao = FoldersDao(
    db: db,
    syncDao: LocalSyncQueueDao(db),
    deletedDao: deletedDao,
  );
  final preferencesDao = FolderPreferencesDao(db: db);
  return FolderRepository(foldersDao, preferencesDao, deletedDao);
});
