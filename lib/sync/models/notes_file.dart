import 'package:tag_links/models/link_preview.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/sync/models/file_base.dart';

class NotesFile extends FileBase {
  final List<Note> notes;
  NotesFile({
    required super.id,
    required super.fileId,
    required super.createdAt,
    required super.updatedAt,
    required this.notes,
  });

  factory NotesFile.fromMap(Map<String, dynamic> map) {
    return NotesFile(
      id: map['id'],
      fileId: map['fileId'],
      notes: (map['notes'] as List? ?? [])
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
      'fileId': fileId,
      'notes': notes.map((n) => NotesToFile.toMap(n)).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }
}

class NotesToFile {
  /// Transforma una Note a un Map optimizado para JSON/Drive
  static Map<String, dynamic> toMap(Note note) {
    return {
      'id': note.id,
      'folderId': note.folderId,
      'title': note.title,
      'content': note.content,
      'color': note.color,
      'createdAt': note.createdAt.millisecondsSinceEpoch,
      'updatedAt': note.updatedAt.millisecondsSinceEpoch,
      'syncAt': note.syncAt?.millisecondsSinceEpoch,
      'isFavorite': note.isFavorite ? 1 : 0,
      // Guardamos el objeto Tag completo (es ligero y útil)
      'tags': note.tags.map((t) => t.toMap()).toList(),
      // Del Link solo guardamos lo mínimo (ID y URL)
      'link': note.link?.toMiniMap(),
    };
  }

  /// Reconstruye una Note desde el Map del JSON
  // En NotesToFile.fromMap
  static Note fromMap(Map<String, dynamic> map) {
    final noteId = map['id'] as String;

    // Usamos el constructor de Note, pero asegúrate de que
    // no intente disparar lógica de DB en el constructor.
    return Note(
      id: noteId,
      folderId: map['folderId'] as String?,
      fileId: map['fileId'] as String,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      color: map['color'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      syncAt: map['syncAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['syncAt'])
          : null,
      isFavorite: map['isFavorite'] == 1,
      // Aquí es importante: si el Tag ya existe en el otro dispositivo,
      // el Repositorio deberá decidir si lo ignora o lo actualiza.
      tags: (map['tags'] as List? ?? []).map((t) => Tag.fromMap(t)).toList(),
      link: map['link'] != null
          ? LinkPreview.fromMiniMap(map['link'], noteId)
          : null,
    );
  }
}
