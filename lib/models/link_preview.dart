import 'package:uuid/uuid.dart';

class LinkPreview {
  final String id;
  final String noteId;
  final String url;
  final String? title;
  final String? description;
  final String? image;
  final String? siteName;

  LinkPreview({
    required this.id,
    required this.noteId,
    required this.url,
    this.title,
    this.description,
    this.image,
    this.siteName,
  });

  bool get hasMetadata =>
      title != null || description != null || image != null || siteName != null;

  factory LinkPreview.create({required String noteId, required String url}) {
    return LinkPreview(id: const Uuid().v4(), noteId: noteId, url: url);
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

  LinkPreview? ensureForInsert() {
    final normalizedUrl = _normalizeUrl(url);

    if (!_isValidUrl(normalizedUrl)) return null;

    return copyWith(
      id: id.isEmpty ? const Uuid().v4() : id,
      url: normalizedUrl,
    );
  }

  LinkPreview copyWith({
    String? id,
    String? noteId,
    String? url,
    String? title,
    String? description,
    String? image,
    String? siteName,
  }) {
    return LinkPreview(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      siteName: siteName ?? this.siteName,
    );
  }

  bool _isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    if (!uri.hasScheme || uri.host.isEmpty) return false;
    return true;
  }

  String _normalizeUrl(String url) {
    final trimmed = url.trim();
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      return 'https://$trimmed';
    }
    return trimmed;
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
