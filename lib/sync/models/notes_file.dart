import 'package:tag_links/models/link_preview.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/sync/models/sync_file_wrapper.dart';
import 'package:uuid/uuid.dart';

class NotesFile extends SyncFileWrapper {
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

  @override
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
      'fileId': note.fileId, // Agregado para que sea simétrico
      'title': note.title,
      'content': note.content,
      'color': note.color,
      'createdAt': note.createdAt,
      'updatedAt': note.updatedAt,
      'syncAt': note.syncAt,
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
    final noteId = map['id']?.toString() ?? const Uuid().v4();

    return Note(
      id: noteId,
      folderId: map['folderId'] as String?,
      // Si no viene fileId en el JSON, usamos un String vacío o un valor por defecto
      fileId: map['fileId'] as String? ?? '',
      title: map['title']?.toString() ?? '',
      content: map['content']?.toString() ?? '',
      color: map['color'] as String?,
      createdAt: 
        map['createdAt'],
      updatedAt: 
        map['updatedAt'],
      syncAt: map['syncAt'],
      isFavorite: (map['isFavorite'] == 1 || map['isFavorite'] == true),
      tags: (map['tags'] as List? ?? [])
          .map((t) => Tag.fromMap(Map<String, dynamic>.from(t)))
          .toList(),
      link: map['link'] != null
          ? LinkPreview.fromMiniMap(map['link'], noteId)
          : null,
    );
  }
}
