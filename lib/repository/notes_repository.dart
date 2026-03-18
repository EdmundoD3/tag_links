import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/sync/note_raw_sync.dart';
import 'package:tag_links/core/sync/sync_types.dart';
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
    return _dao.insert(noteToSave);
  }

  Future<void> update(Note note) {
    final noteToUpdate = note.ensureForInsert();
    return _dao.update(noteToUpdate);
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
    return _dao.deleteByIds(ids);
  }
  Future<void> clearDeletedNotes(List<String> ids){
    return _deletedDao.deleteIds(ids);
  }
  // --------------------- SYNC section ----------------------//
  Future<SyncData<NoteRawSync>> getForSync() async {
    final limit = 200;
    final deletedData = await _deletedDao.getBatch(limit: limit);
    final deletedDataRaw = deletedData.map(NoteRawSync.fromDeleted).toList();
    final data = await _dao.getForSync(limit: limit - deletedData.length);
    final dataRaw = await Future.wait(data.map(NoteRawSync.fromNote));

    return SyncData(
      dataForSync: dataRaw,
      deletedDataForSync: deletedDataRaw,
      hasMore: data.length + deletedData.length >= limit,
    );
  }
  Future<Future<bool>> updateSyncAt(List<String> ids, int syncAt) async {
    return _dao.updateNotesSyncAt(ids, syncAt);
  }
}

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final notesDao = NotesDao(db);
  final deletedDao = DeletedNotesDao(db: db);
  return NotesRepository(notesDao, deletedDao);
});
