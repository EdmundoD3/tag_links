import 'package:tag_links/sync/models/sync_item_wrapper.dart';
import 'package:uuid/uuid.dart';

class Tag extends BaseSyncModel {
  final String name;
  final bool isFavorite;
  final int usageCount;

  Tag({
    required super.id,
    required super.fileId,
    required super.updatedAt,
    super.syncAt,
    required this.name,
    this.isFavorite = false,
    this.usageCount = 0,
  });

static Tag fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id']?.toString() ?? const Uuid().v4(),
      name: map['name']?.toString() ?? 'Sin nombre',
      fileId: map['fileId']?.toString() ?? '',
      isFavorite: (map['isFavorite'] == 1 || map['isFavorite'] == true),
      usageCount: map['usageCount'] ?? 0,
      // IMPORTANTE: Asegurar que sea int
      updatedAt: map['updatedAt'] ?? DateTime.now().millisecondsSinceEpoch,
      syncAt: map['syncAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'fileId': fileId,
      'isFavorite': isFavorite ? 1 : 0,
      'usageCount': usageCount,
      'updatedAt': updatedAt,
      'syncAt': syncAt,
    };
  }

  Tag copyWith({
    String? id,
    String? name,
    bool? isFavorite,
    int? usageCount,
    int? updatedAt,
    int? syncAt,
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
    return copyWith(
      id: id.isEmpty ? const Uuid().v4() : id,
      // Si por alguna razón no hay fecha, la ponemos ahora
      updatedAt: updatedAt == 0 ? DateTime.now().millisecondsSinceEpoch : updatedAt,
    );
  }
}

String tagTable =
    '''
          CREATE TABLE tags (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL UNIQUE,
            isFavorite INTEGER NOT NULL DEFAULT 0 CHECK (isFavorite IN (0,1)),
            usageCount INTEGER NOT NULL DEFAULT 0,
            $itemsBaseColumns
          );
''';
