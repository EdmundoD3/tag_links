import 'package:tag_links/sync/models/sync_item_wrapper.dart';
import 'package:uuid/uuid.dart';

class Tag extends BaseSyncModel {
  final String title; // ✅ Estandarizado
  final bool isFavorite;
  final int usageCount;

  Tag({
    required super.id,
    required super.fileId,
    required super.updatedAt,
    required this.title,
    this.isFavorite = false,
    this.usageCount = 0,
  });

  static Tag fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id']?.toString() ?? const Uuid().v4(),
      title: map['title']?.toString() ?? 'No name', // ✅ Cambiado de 'name' a 'title'
      fileId: map['fileId']?.toString() ?? '',
      isFavorite: (map['isFavorite'] == 1 || map['isFavorite'] == true),
      usageCount: map['usageCount'] ?? 0,
      updatedAt: map['updatedAt'] ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title, // ✅ Cambiado de 'name' a 'title' para persistencia y Drive
      'fileId': fileId,
      'isFavorite': isFavorite ? 1 : 0,
      'usageCount': usageCount,
      'updatedAt': updatedAt,
    };
  }

  Tag copyWith({
    String? id,
    String? title,
    bool? isFavorite,
    int? usageCount,
    int? updatedAt,
  }) {
    return Tag(
      id: id ?? this.id,
      title: title ?? this.title,
      fileId: fileId,
      isFavorite: isFavorite ?? this.isFavorite,
      usageCount: usageCount ?? this.usageCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Tag ensureForInsert() {
    return copyWith(
      id: id.isEmpty ? const Uuid().v4() : id,
      updatedAt: updatedAt == 0 ? DateTime.now().millisecondsSinceEpoch : updatedAt,
    );
  }
}

String tagTable = '''
  CREATE TABLE tags (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL UNIQUE,
    isFavorite INTEGER NOT NULL DEFAULT 0 CHECK (isFavorite IN (0,1)),
    usageCount INTEGER NOT NULL DEFAULT 0,
    $itemsBaseColumns -- fileId, updatedAt, etc.
  );
''';