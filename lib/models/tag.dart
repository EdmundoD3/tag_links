import 'package:uuid/uuid.dart';

class Tag {
  final String id;
  final String name;
  final String fileId;
  final bool isFavorite;
  final int usageCount;
  final DateTime? updatedAt;
  final DateTime? syncAt;

  Tag({
    required this.id,
    required this.name,
    required this.fileId,
    this.isFavorite = false,
    this.usageCount = 0,
    this.updatedAt,
    this.syncAt,
  });

  static Tag fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id'],
      name: map['name'],
      fileId: map['fileId'],
      isFavorite: (map['isFavorite'] ?? 0) == 1,
      usageCount: map['usageCount'] ?? 0,
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : DateTime.now(),
      syncAt: map['syncAt'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['syncAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'fileId': fileId,
      'isFavorite': isFavorite ? 1 : 0,
      'usageCount': usageCount,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'syncAt': syncAt?.millisecondsSinceEpoch,
    };
  }

  Tag copyWith({
    String? id,
    String? name,
    bool? isFavorite,
    int? usageCount,
    DateTime? updatedAt,
    DateTime? syncAt,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      fileId: fileId,
      isFavorite: isFavorite ?? this.isFavorite,
      usageCount: usageCount ?? this.usageCount,
      updatedAt: updatedAt ?? this.updatedAt,
      syncAt: syncAt ?? this.syncAt,
    );
  }

  Tag ensureForInsert() {
    if (id.isEmpty || id == "") {
      return copyWith(id: const Uuid().v4(), updatedAt: DateTime.now());
    }
    return copyWith(updatedAt: DateTime.now());
  }
}

String tagTable = '''
          CREATE TABLE tags (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL UNIQUE,
            fileId TEXT,
            isFavorite INTEGER NOT NULL DEFAULT 0 CHECK (isFavorite IN (0,1)),
            usageCount INTEGER NOT NULL DEFAULT 0,
            updatedAt INTEGER NOT NULL,
            syncAt INTEGER,
            FOREIGN KEY (fileId) REFERENCES files(id) ON DELETE CASCADE
          );
''';
