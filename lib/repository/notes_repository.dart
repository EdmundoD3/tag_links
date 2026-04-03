import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/data/data_sources/deleted_dao.dart';
import 'package:tag_links/data/data_sources/notes_dao.dart';
import 'package:tag_links/data/database.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/models/search_query.dart';
import 'package:tag_links/utils/paginated_utils.dart';

class NotesRepository {
  final NotesDao _dao;
  final DeletedNotesDao _deletedDao;

  NotesRepository(this._dao, this._deletedDao);

  Future<List<Note>> searchByQuery(
    SearchQuery query, {
    required PaginatedByDate paginated,
    required FolderFilter folderFilter
  }) async {
    return _dao.searchByQuery(query, paginated: paginated, folderFilter: folderFilter);
  }

  Future<List<Note>> getByFolder(
    String? folderId, {
    required PaginatedByDate pagination,
  }) => _dao.getByFolder(folderId, pagination: pagination);

  Future<List<Note>> getFavorites({required PaginatedByDate pagination}) =>
      _dao.getFavorites(pagination: pagination);

  Future<Note?> getById(String id) => _dao.getById(id);

  Future<PaginatedByDate> getPageForNoteId(
    Note note, {
    required PaginatedByDate paginated,
  }) {
    return _dao.getPageForNoteId(note, paginated: paginated);
  }

  Future<void> create(Note note) {
    final noteToSave = note.ensureForInsert();
    return _dao.upsert(noteToSave);
  }

  Future<void> update(Note note) {
    final noteToUpdate = note.ensureForInsert();
    return _dao.upsert(noteToUpdate);
  }
  Future<void> upsert(Note note) {
    return _dao.upsert(note);
  }

  Future<void> upsertAll(List<Note> notes) {
    return _dao.upsertAll(notes);
  }

  Future<void> delete(Note note) async {
    if (note.syncAt == null) return _dao.delete(note.id);
    await _deletedDao.saveId(note.id);
    return _dao.delete(note.id);
  }

  Future<void> deleteByIds(List<String> ids) {
    return _dao.serverDeleteByIds(ids);
  }
  Future<void> clearDeletedNotes(List<String> ids){
    return _deletedDao.deleteIds(ids);
  }
  // --------------------- SYNC section ----------------------//
  Future<List<Note>> getByFileId(String fileId) => _dao.getByFileId(fileId);
  Future<Future<bool>> updateSyncAt({required List<String> ids,required int syncAt,required String fileId}) async {
    return _dao.updateNotesSyncAt(ids: ids, syncAt: syncAt, fileId: fileId);
  }
  // Obtener notas que han cambiado localmente y no se han subido
  Future<List<Note>> getPendingSync() => _dao.getPendingSync();

  // Obtener los registros borrados para subirlos a la nube
  Future<List<DeletedData>> getDeletedBatch({int limit = 500}) => 
      _deletedDao.getBatch(limit: limit);
  Future<bool> hasAnyData() => _dao.hasAnyData();
}

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  final db = ref.read(databaseProvider);
  final notesDao = NotesDao(db);
  final deletedDao = DeletedNotesDao(db: db);
  return NotesRepository(notesDao, deletedDao);
});
