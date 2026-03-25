import 'package:tag_links/models/link_preview.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/models/tag.dart';

class NotesFile {
  final String id;
  final List<Note> notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotesFile({
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.id,
  });

  factory NotesFile.fromMap(Map<String, dynamic> map, String fileId) {
    final List<dynamic> notesRaw = map['notes'] ?? [];
    return NotesFile(
      id: fileId, // Lo tomamos del ID del archivo de Drive
      notes: notesRaw
          .map((n) => NotesToFile.fromMap(n as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['updatedAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'notes': notes.map((n) => NotesToFile.toMap(n)).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }
}

class NotesToFile {
  static Map<String, Object?> toMap(Note note) {
    return {
      'id': note.id,
      'folderId': note.folderId,
      'title': note.title,
      'url': note.link?.toMiniMap(),
      'content': note.content,
      'color': note.color,
      'createdAt': note.createdAt.millisecondsSinceEpoch,
      'updatedAt': note.updatedAt.millisecondsSinceEpoch,
      'syncAt': note.syncAt?.millisecondsSinceEpoch,
      'isFavorite': note.isFavorite ? 1 : 0,
      'tagsId': note.tags.map((t) => t.id).toList(),
    };
  }

  static Note fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      folderId: map['folderId'],
      title: map['title'],
      link: map['url'] == null
          ? null
          : LinkPreview.fromMiniMap(map['url'], map['id']),
      content: map['content'],
      color: map['color'],
      createdAt: map['createdAt'] == null
          ? DateTime.now()
          : DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: map['updateAt'] == null
          ? DateTime.now()
          : DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      syncAt: map['syncAt'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['syncAt']),
      isFavorite: map['isFavorite'] == 1,
      tags: tagsFromMap(map['tagsId']),
    );
  }

  static List<Tag> tagsFromMap(List<String> tagsRaw) {
    //solo interesan los id para ligar con la nota
    return tagsRaw.map((t) => Tag.fromMap({'id': t, 'name': ""})).toList();
  }
}
