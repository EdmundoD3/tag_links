import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/data/data_sources/folder_preferences_dao.dart';
import 'package:tag_links/data/data_sources/folders_dao.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/models/folder_preference.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/models/search_query.dart';
import 'package:tag_links/utils/paginated_utils.dart';

class FolderRepository {
  final FoldersDao _dao;
  final FolderPreferencesDao _preferencesDao;

  FolderRepository(this._dao, this._preferencesDao);

  Future<List<Folder>> searchByQuery(
    SearchQuery query, {
    required PaginatedByDate paginated,
  }) async {
    return _dao.searchByQuery(query, paginated: paginated);
  }
  Future<PaginatedByDate> getPageForNoteId(Note note, {required PaginatedByDate paginated}){
    return _dao.getPageForNoteId(note, paginated:paginated);
  }

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

  Future<List<Folder>> getByParentId(
    String parentId, {
    required PaginatedByDate paginated,
  }) => _dao.getByParentId(parentId, paginated: paginated);

  Future<List<Folder>> getRootFolders({required PaginatedByDate paginated}) =>
      _dao.getRootFolders(paginated: paginated);

  Future<List<Folder>> getFavorites({required PaginatedByDate paginated}) =>
      _dao.getFavorites(paginated: paginated);

  Future<FolderDefaultView> getPreference(String folderId) async {
    return _preferencesDao.getDefaultView(folderId);
  }

  Future<void> toggleFavorite(Folder folder) {
    return update(folder.copyWith(isFavorite: !folder.isFavorite));
  }

  Future<void> savePreference(String folderId, FolderDefaultView view) async {
    await _preferencesDao.save(
      FolderPreference(folderId: folderId, defaultView: view),
    );
  }
}

final foldersDaoProvider = Provider<FoldersDao>((ref) => FoldersDao());

final folderPreferencesDaoProvider = Provider((ref) => FolderPreferencesDao());

final folderRepositoryProvider = Provider<FolderRepository>((ref) {
  return FolderRepository(
    ref.read(foldersDaoProvider),
    ref.read(folderPreferencesDaoProvider),
  );
});

final folderPreferenceProvider =
    FutureProvider.family<FolderDefaultView, String>((ref, folderId) {
      final repo = ref.read(folderRepositoryProvider);
      return repo.getPreference(folderId);
    });
