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

  factory LinkPreview.create({
    required String noteId,
    required String url,
  }) {
    return LinkPreview(
      id: const Uuid().v4(),
      noteId: noteId,
      url: url,
    );
  }

  factory LinkPreview.withMetadata({
    required String id,
    required String noteId,
    required String url,
    String? title,
    String? description,
    String? image,
    String? siteName,
  }) {
    return LinkPreview(
      id: id,
      noteId: noteId,
      url: url,
      title: title,
      description: description,
      image: image,
      siteName: siteName,
    );
  }

  LinkPreview copyWith({
    String? title,
    String? description,
    String? image,
    String? siteName,
  }) {
    return LinkPreview(
      id: id,
      noteId: noteId,
      url: url,
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      siteName: siteName ?? this.siteName,
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
