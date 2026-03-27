import 'package:tag_links/models/link_preview.dart';
import 'package:tag_links/models/tag.dart';
import 'package:uuid/uuid.dart';

class Note {
  final String id;
  final String? folderId;
  final String fileId;
  final String title;
  final String content;
  final String? color;
  LinkPreview? link;
  final List<Tag> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncAt;
  final bool isFavorite;

  Note({
    required this.id,
    required this.folderId,
    required this.fileId,
    required this.title,
    required this.content,
    this.color,
    required this.link,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.syncAt,
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
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isFavorite = false,
  }) {
    return Note(
      id: id?.isEmpty ?? true ? const Uuid().v4() : id!,
      folderId: folderId,
      fileId: fileId,
      title: title ?? 'Nueva nota',
      content: content ?? '',
      color: color,
      link: link,
      tags: tags,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
      isFavorite: isFavorite,
    );
  }

  static Note fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      folderId: map['folderId'],
      fileId: map['fileId'],
      title: map['title'],
      content: map['content'],
      color: map['color'],
      link: null, // luego lo conectas si aplica
      tags: const [], // se cargan después
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      syncAt: map['syncAt'] == null ? null : DateTime.fromMillisecondsSinceEpoch(map['syncAt']),
      isFavorite: map['isFavorite'] == 1,
    );
  }
  String copyText() {
    final String link = this.link?.url ?? '';
    return '$title\n\n$link\n$content';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'folderId': folderId,
      'fileId': fileId,
      'title': title,
      'content': content,
      'color': color,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'syncAt': syncAt?.millisecondsSinceEpoch,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  Note copyWith({
    String? id,
    required String? folderId,
    String? title,
    String? content,
    String? color,
    LinkPreview? link,
    List<Tag>? tags,
    bool? isFavorite,
    DateTime? updatedAt,
    DateTime? createdAt,
    DateTime? syncAt,
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
      syncAt: syncAt ?? this.syncAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Note ensureForInsert() {
    if (link != null && link!.noteId != id) {
      throw StateError('LinkPreview.noteId does not match Note.id');
    }
    return copyWith(updatedAt: DateTime.now(), folderId: folderId);
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
            fileId TEXT NOT NULL,
            title TEXT NOT NULL,
            content TEXT,
            color TEXT,
            createdAt INTEGER NOT NULL,
            updatedAt INTEGER NOT NULL,
            syncAt INTEGER,
            isFavorite INTEGER NOT NULL DEFAULT 0 CHECK (isFavorite IN (0,1)),
            FOREIGN KEY (folderId) REFERENCES folders(id) ON DELETE CASCADE,
            FOREIGN KEY (fileId) REFERENCES files(id) ON DELETE CASCADE
          );
''';