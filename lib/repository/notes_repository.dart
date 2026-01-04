import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/models/tag.dart';

class NotesRepository {
  final List<Folder> _folders = [Folder(id: "1", parentId: null, title: "gatitos", tags: [Tag(id: "", name: "tags")], createdAt: DateTime.now())];
  final List<Note> _notes = [Note(id: "1", folderId: "1", title: "title", link: null, tags: [Tag(id: "", name: "tags")], createdAt: DateTime.now())];

  List<Folder> getFolders() {
    return _folders.where((f) => f.parentId == null).toList();
  }

  List<Folder> getSubFolders(String folderId) {
    return _folders.where((f) => f.parentId == folderId).toList();
  }

  void saveFolder(Folder folder) {
    _folders.add(folder);
  }

  void deleteFolder(String id) {
    _folders.removeWhere((f) => f.id == id);
    _notes.removeWhere((n) => n.folderId == id);
  }

  List<Note> getNotes(String folderId) {
    return _notes.where((n) => n.folderId == folderId).toList();
  }

  void saveNote(Note note) {
    _notes.add(note);
  }
  void updateNote(Note note) {
  _notes.removeWhere((n) => n.id == note.id);
  _notes.add(note);
}


  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
  }

  List<Note> getNotesByTags(List<String> tags) {
    return _notes.where(
      (n) => tags.every((t) => n.tags.contains(t)),
    ).toList();
  }
}

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepository();
});