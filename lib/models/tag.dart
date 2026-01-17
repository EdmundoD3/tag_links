import 'package:uuid/uuid.dart';

class Tag {
  final String id;
  final String name;
  final bool isFavorite;
  final int usageCount;

  Tag({
    required this.id,
    required this.name,
    this.isFavorite = false,
    this.usageCount = 0,
  });

  static Tag fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id'],
      name: map['name'],
      isFavorite: map['isFavorite'] == 1,
      usageCount: map['usageCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isFavorite': isFavorite ? 1 : 0,
      'usageCount': usageCount,
    };
  }

  Tag copyWith({String? id, bool? isFavorite, int? usageCount}) {
    return Tag(
      id: id ?? this.id,
      name: name,
      isFavorite: isFavorite ?? this.isFavorite,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  Tag ensureForInsert() {
    return copyWith(id: Uuid().v4());
  }
}

String tagTable = '''
          CREATE TABLE tags (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL UNIQUE,
            isFavorite INTEGER NOT NULL DEFAULT 0 CHECK (isFavorite IN (0,1)),
            usageCount INTEGER NOT NULL DEFAULT 0
          );
''';
