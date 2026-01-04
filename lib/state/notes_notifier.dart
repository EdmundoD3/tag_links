import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/repository/notes_repository.dart';
import '../models/note.dart';

class NotesNotifier extends Notifier<List<Note>> {
  NotesNotifier(this.folderId);

  final String? folderId;
  late final NotesRepository _repo;

  @override
  List<Note> build() {
    _repo = ref.read(notesRepositoryProvider);

    if (folderId == null) {
      return _repo.getNotesByTags([]); // o getAllNotes()
    }

    return _repo.getNotes(folderId!);
  }

  void addNote(Note note) {
    _repo.saveNote(note);
    state = [...state, note];
  }

  void updateNote(Note note) {
    _repo.updateNote(note);
    state = state.map((n) => n.id == note.id ? note : n).toList();
  }

  void deleteNote(String id) {
    _repo.deleteNote(id);
    state = state.where((n) => n.id != id).toList();
  }

  List<Note> notesByTags(List<String> tags) {
    return state
        .where((n) => tags.every((t) => n.tags.contains(t)))
        .toList();
  }
}


final notesProvider =
    NotifierProvider.family<NotesNotifier, List<Note>, String?>(
  NotesNotifier.new,
);
