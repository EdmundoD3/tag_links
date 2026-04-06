import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/data/data_sources/deleted_dao.dart';
import 'package:tag_links/data/data_sources/notes_dao.dart';
import 'package:tag_links/data/database.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/models/search_query.dart';
import 'package:tag_links/sync/db/local_sync_queue_repository.dart';
import 'package:tag_links/sync/models/notes_file.dart';
import 'package:tag_links/utils/paginated_utils.dart';

class NotesRepository {
  final NotesDao _dao;
  final DeletedDao _deletedDao;
  final LocalSyncQueueRepository _syncRepo;

  NotesRepository(this._dao, this._deletedDao, this._syncRepo);

  Future<List<Note>> searchByQuery(
    SearchQuery query, {
    required PaginatedByDate paginated,
    required FolderFilter folderFilter,
  }) async {
    return _dao.searchByQuery(
      query,
      paginated: paginated,
      folderFilter: folderFilter,
    );
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

  Future<void> create(Note note) async {
    final noteToSave = note.ensureForInsert();
    // 1. IMPORTANTE: El bucket se marca como sucio ANTES o después de la inserción
    return _dao.upsert(noteToSave);
  }

  Future<void> update(Note note) async {
    final noteToUpdate = note.ensureForInsert();
    return _dao.upsert(noteToUpdate);
  }

  Future<void> delete(Note note) {
    return _dao.delete(note);
  }

  Future<void> upsert(Note note) async {
    await _syncRepo.markAsDirty(note.fileId);
    return _dao.upsert(note);
  }

  Future<void> upsertAll(List<Note> notes) async {
    final dirtysIds = await _deletedDao.extractDirtyIdsByType(
      notes.map((e) => e.id).toList(),DeletedType.note,
    );
    final cleanNotes = notes.where((e) => !dirtysIds.contains(e.id)).toList();
    return _dao.upsertAll(cleanNotes);
  }

  Future<void> serverDeleteByIds(List<String> ids) async {
    await _deletedDao.deleteIds(ids);
    return _dao.serverDeleteByIds(ids);
  }

  Future<void> clearDeletedNotes(List<String> ids) {
    return _deletedDao.deleteIds(ids);
  }

  // --------------------- SYNC section ----------------------//
  Future<List<Note>> getByFileId(String fileId) => _dao.getByFileId(fileId);
  Future<NotesFile> getFileWrapper({
    required String fileId,
    String? driveFileId,
    required DateTime now,
  }) async {
    final items = await getByFileId(fileId);
    return NotesFile(
      id: fileId,
      fileId: driveFileId ?? '',
      notes: items,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Obtener los registros borrados para subirlos a la nube
  Future<List<DeletedData>> getDeletedBatch(String fileId) =>
      _deletedDao.getBatchByFileIdAndType(fileId,DeletedType.note);
  Future<bool> hasAnyData() => _dao.hasAnyData();
}

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  final db = ref.read(databaseProvider);
  final deletedDao = ref.read(deletedDaoProvider);
  final notesDao = NotesDao(db,deletedDao);
  
  final syncRepo = ref.read(localSyncQueueRepositoryProvider);
  return NotesRepository(notesDao, deletedDao, syncRepo);
});
