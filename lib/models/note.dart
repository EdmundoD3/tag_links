import 'package:tag_links/models/link_preview.dart';
import 'package:tag_links/models/tag.dart';
import 'package:uuid/uuid.dart';

String noteTable = '''
          CREATE TABLE notes(
            id TEXT PRIMARY KEY,
            folderId TEXT NOT NULL,
            title TEXT NOT NULL,
            content TEXT,
            createdAt INTEGER NOT NULL,
            updatedAt INTEGER NOT NULL,
            isFavorite INTEGER NOT NULL DEFAULT 0 CHECK (isFavorite IN (0,1)),
            FOREIGN KEY (folderId) REFERENCES folders(id) ON DELETE CASCADE
          );
''';

class Note {
  final String id;
  final String folderId;
  final String title;
  final String content;
  LinkPreview? link;
  final List<Tag> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;

  Note({
    required this.id,
    required this.folderId,
    required this.title,
    required this.content,
    required this.link,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
  });
  static Note fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      folderId: map['folderId'],
      title: map['title'],
      content: map['content'],
      link: null, // luego lo conectas si aplica
      tags: const [], // se cargan después
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      isFavorite: map['isFavorite'] == 1,
    );
  }
  String copyText() {
    final String link = this.link?.url ?? '';
    return '$title\n\n$link\n$content';
  }

  factory Note.baseNote({
    String? id,
    String? title,
    String? folderId,
    String? content,
    LinkPreview? link,
    List<Tag> tags = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isFavorite = false,
  }) {
    return Note(
      id: id?.isEmpty ?? true ? const Uuid().v4() : id!,
      folderId: folderId ?? '',
      title: title ?? 'Nueva nota',
      content: content ?? '',
      link: link,
      tags: tags,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
      isFavorite: isFavorite,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'folderId': folderId,
      'title': title,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  Note copyWith({
    String? id,
    String? folderId,
    String? title,
    String? content,
    LinkPreview? link,
    List<Tag>? tags,
    bool? isFavorite,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      folderId: folderId ?? this.folderId,
      title: title ?? this.title,
      content: content ?? this.content,
      link: link ?? this.link,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Note ensureForInsert() {
    if (folderId.isEmpty) {
      throw StateError('Note cannot be inserted without folderId');
    }

    if (link != null && link!.noteId != id) {
      throw StateError('LinkPreview.noteId does not match Note.id');
    }

    return copyWith(updatedAt: DateTime.now());
  }
}

class NoteJoinRow {
  final String noteId;
  final String folderId;
  final String title;
  final String? content;
  final int createdAt;
  final int updatedAt;
  final bool isFavorite;

  final String? tagId;
  final String? tagName;

  final String? linkId;
  final String? linkUrl;
  final String? linkTitle;
  final String? linkDescription;
  final String? linkImage;
  final String? linkSiteName;

  NoteJoinRow.fromMap(Map<String, Object?> map)
    : noteId = map['note_id'] as String,
      folderId = map['folder_id'] as String,
      title = map['title'] as String,
      content = map['content'] as String?,
      createdAt = map['createdAt'] as int,
      updatedAt = map['updatedAt'] as int,
      isFavorite = map['isFavorite'] == 1,
      tagId = map['tag_id'] as String?,
      tagName = map['tag_name'] as String?,
      linkId = map['link_id'] as String?,
      linkUrl = map['link_url'] as String?,
      linkTitle = map['link_title'] as String?,
      linkDescription = map['link_description'] as String?,
      linkImage = map['link_image'] as String?,
      linkSiteName = map['link_siteName'] as String?;

  static const String selectQuery = '''
    SELECT
      n.id AS note_id,
      n.folderId AS folder_id,
      n.title,
      n.content,
      n.createdAt,
      n.updatedAt,
      n.isFavorite,

      t.id AS tag_id,
      t.name AS tag_name,

      lp.id AS link_id,
      lp.url AS link_url,
      lp.title AS link_title,
      lp.description AS link_description,
      lp.image AS link_image,
      lp.siteName AS link_siteName
    FROM notes n
    LEFT JOIN note_tags nt ON nt.noteId = n.id
    LEFT JOIN tags t ON t.id = nt.tagId
    LEFT JOIN link_previews lp ON lp.noteId = n.id
  ''';
}
