import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import '../repository/notes_repository.dart';

class NotesNotifier extends AsyncNotifier<List<Note>> {
  NotesNotifier(this.folderId);

  final String? folderId;

  NotesRepository get _repo =>
      ref.read(notesRepositoryProvider);

  @override
  Future<List<Note>> build() async {
    if (folderId == null) {
      return _repo.getFavorites();
    }

    return _repo.getByFolder(folderId!);
  }

  Future<void> addNote(Note note) async {
    await _repo.create(note);
    ref.invalidateSelf();
  }

  Future<void> updateNote(Note note) async {
    await _repo.update(note);
    ref.invalidateSelf();
  }

  Future<void> deleteNote(String id) async {
    await _repo.delete(id);
    ref.invalidateSelf();
  }
}

final notesProvider =
    AsyncNotifierProvider.family<NotesNotifier, List<Note>, String?>(
  (folderId) => NotesNotifier(folderId),
);
