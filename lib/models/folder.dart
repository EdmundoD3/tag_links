import 'package:tag_links/models/tag.dart';

class Folder {
  final String id;
  final String? parentId;
  final String title;
  final List<Tag> tags;
  final String? description;
  final String? image;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isFavorite;

  Folder({
    required this.id,
    this.parentId,
    required this.title,
    required this.tags,
    this.description,
    this.image,
    required this.createdAt,
    this.updatedAt,
    this.isFavorite = false,
  });
}

String folderTable = '''
          CREATE TABLE folders(
            id TEXT PRIMARY KEY,
            parentId TEXT,
            title TEXT NOT NULL,
            description TEXT,
            image TEXT,
            createdAt INTEGER NOT NULL,
            updatedAt INTEGER NOT NULL,
            isFavorite INTEGER NOT NULL DEFAULT 0 CHECK (isFavorite IN (0,1)),
            FOREIGN KEY (parentId) REFERENCES folders(id) ON DELETE CASCADE
          );
''';
