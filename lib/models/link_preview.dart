import 'package:uuid/uuid.dart';

class LinkPreview {
  String id;
  final String noteId;
  final String url;
  final String? title;
  final String? description;
  final String? image;
  final String? siteName;

  LinkPreview({
    required this.url,
    required this.id,
    required this.noteId,
    this.title,
    this.description,
    this.image,
    this.siteName,
  });
  LinkPreview ensureForInsert(String noteId) {
    return LinkPreview(
      id: id.isEmpty ? const Uuid().v4() : id,
      noteId: noteId,
      url: url,
      title: title,
      description: description,
      image: image,
      siteName: siteName,
    );
  }
}

String linkPreviewTable = '''
          CREATE TABLE link_previews(
            id TEXT PRIMARY KEY,
            noteId TEXT NOT NULL,
            url TEXT NOT NULL,
            title TEXT,
            description TEXT,
            image TEXT,
            siteName TEXT,
            FOREIGN KEY (noteId) REFERENCES notes(id) ON DELETE CASCADE
          );
''';
