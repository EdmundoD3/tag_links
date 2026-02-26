import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/sync/note_raw_sync.dart';
import 'package:tag_links/core/sync/sync_manager.dart';
import 'package:tag_links/data/data_sources/deleted_dao.dart';
import 'package:tag_links/data/data_sources/notes_dao.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/models/search_query.dart';
import 'package:tag_links/utils/paginated_utils.dart';

class NotesRepository {
  final NotesDao _dao;
  final DeletedNotesDao _deletedDao = DeletedNotesDao();

  NotesRepository(this._dao);

  Future<List<Note>> searchByQuery(
    SearchQuery query, {
    required PaginatedByDate paginated,
  }) async {
    return _dao.searchByQuery(query, paginated: paginated);
  }

  Future<List<Note>> getByFolder(
    String folderId, {
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
  Future<void> upsertAll(List<Note> notes) {
    return _dao.upsertAll(notes);
  }

  Future<void> delete(String noteId) {
    return _dao.delete(noteId);
  }
  Future<void> deleteByIds(List<String> ids) {
    return _dao.deleteByIds(ids);
  }



  Future<SyncData<NoteRawSync>> getForSync(int? deletedAt) async {
    final limit = 250;
    final deletedData = await _deletedDao.getBatch(
      limit: limit,
    );
    final deletedDataRaw = deletedData.map(NoteRawSync.fromDeleted).toList();
    final data = await _dao.getByLastUpdate(
      lastUpdate: deletedAt,
      limit: limit - deletedData.length,
    );
    final lastDate = data.isEmpty ? null : data.reduce((a, b) => a.updatedAt.isAfter(b.updatedAt)? a : b).updatedAt.millisecondsSinceEpoch;
    final dataRaw = await Future.wait(data.map(NoteRawSync.fromNote));

    return SyncData(
      data: [...deletedDataRaw, ...dataRaw],
      lastDate: lastDate,
      hasMore: data.length + deletedData.length >= limit,
    );
  }
}

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepository(NotesDao());
});
