import 'package:tag_links/models/link_preview.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/sync/models/sync_item_wrapper.dart';
import 'package:uuid/uuid.dart';

class Note extends BaseSyncModel {
  final String? folderId;
  final String title;
  final String content;
  final String? color;
  LinkPreview? link;
  final List<Tag> tags;
  final int createdAt; // Cambiado a int
  final bool isFavorite;

  Note({
    required super.id,
    required this.folderId,
    required super.fileId,
    required this.title,
    required this.content,
    this.color,
    required this.link,
    required this.tags,
    required this.createdAt,
    required super.updatedAt,
    this.isFavorite = false,
  });

  factory Note.baseNote({
    String? id,
    String? title,
    String? folderId,
    required String fileId,
    String? content,
    String? color,
    LinkPreview? link,
    List<Tag> tags = const [],
    int? createdAt,
    int? updatedAt,
    bool isFavorite = false,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return Note(
      id: id?.isEmpty ?? true ? const Uuid().v4() : id!,
      folderId: folderId,
      fileId: fileId,
      title: title ?? 'Nueva nota',
      content: content ?? '',
      color: color,
      link: link,
      tags: tags,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      isFavorite: isFavorite,
    );
  }

  static Note fromMap(Map<String, dynamic> map) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return Note(
      id: map['id'],
      folderId: map['folderId'],
      fileId: map['fileId'],
      title: map['title'] ?? 'Sin título',
      content: map['content'] ?? '',
      color: map['color'],
      link: null, 
      tags: const [], 
      createdAt: map['createdAt'] ?? now,
      updatedAt: map['updatedAt'] ?? now,
      isFavorite: map['isFavorite'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'folderId': folderId,
      'fileId': fileId,
      'title': title,
      'content': content,
      'color': color,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  Note copyWith({
    String? id,
    String? folderId, // Quitamos required para permitir null (raíz)
    String? title,
    String? content,
    String? color,
    LinkPreview? link,
    List<Tag>? tags,
    bool? isFavorite,
    int? updatedAt,
    int? createdAt,
  }) {
    return Note(
      id: id ?? this.id,
      folderId: folderId, 
      fileId: fileId,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      link: link ?? this.link,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Note ensureForInsert() {
    if (link != null && link!.noteId != id) {
      throw StateError('LinkPreview.noteId does not match Note.id');
    }
    return copyWith(
      updatedAt: DateTime.now().millisecondsSinceEpoch, 
      folderId: folderId
    );
  }

  String copyText() {
    final String url = link?.url ?? '';
    return '$title\n\n$url\n$content';
  }
}
class NoteConfig {
  static final titleMaxLength = 120;
  static final titleMaxLine = 1;
  static final contentMaxLength = 3000;
  static final contentMaxLine = 10;
  static final urlMaxLength = 500;
  static final urlMaxLine = 1;
  static final tagMaxLength = 42;
  static final maxTags = 10;
}
String noteTable = '''
  CREATE TABLE notes (
    id TEXT PRIMARY KEY,
    folderId TEXT,
    title TEXT NOT NULL,
    content TEXT,
    color TEXT,
    createdAt INTEGER NOT NULL,
    isFavorite INTEGER NOT NULL DEFAULT 0 CHECK (isFavorite IN (0,1)),
    $itemsBaseColumns, -- fileId, updatedAt y el FOREIGN KEY a files
    FOREIGN KEY (folderId) REFERENCES folders(id) ON DELETE CASCADE
  );
''';