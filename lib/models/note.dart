import 'package:tag_links/models/link_preview.dart';
import 'package:tag_links/models/tag.dart';

class Note {
  final String id;
  final String folderId;
  final String title;
  final String? text;
  final LinkPreview? link;
  final List<Tag> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isFavorite;

  Note({
    required this.id,
    required this.folderId,
    required this.title,
    this.text,
    required this.link,
    required this.tags,
    required this.createdAt,
    this.updatedAt,
    this.isFavorite = false,
  });
  static Note fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      folderId: map['folderId'],
      title: map['title'],
      text: map['text'],
      link: map['link'],
      tags: map['tags'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      isFavorite: map['isFavorite'],
    );
  }

  toMap() {
    return {
      'id': id,
      'folderId': folderId,
      'title': title,
      'text': text,
      'link': link,
      'tags': tags,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isFavorite': isFavorite,
    };
  }
}

String noteTable = '''
          CREATE TABLE notes(
            id TEXT PRIMARY KEY,
            folderId TEXT NOT NULL,
            title TEXT NOT NULL,
            text TEXT,
            createdAt INTEGER NOT NULL,
            updatedAt INTEGER NOT NULL,
            isFavorite INTEGER NOT NULL DEFAULT 0 CHECK (isFavorite IN (0,1)),
            FOREIGN KEY (folderId) REFERENCES folders(id) ON DELETE CASCADE
          );
'''; //Date is timeStamp
