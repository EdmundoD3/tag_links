import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/data/data_sources/notes_dao.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/models/search_query.dart';
import 'package:tag_links/utils/paginated_utils.dart';

class NotesRepository {
  final NotesDao _dao;

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

  Future<void> create(Note note) {
    final noteToSave = note.ensureForInsert();
    return _dao.insert(noteToSave);
  }

  Future<void> update(Note note) {
    final noteToUpdate = note.ensureForInsert();
    return _dao.update(noteToUpdate);
  }

  Future<void> delete(String noteId) => _dao.delete(noteId);
}

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepository(NotesDao());
});
