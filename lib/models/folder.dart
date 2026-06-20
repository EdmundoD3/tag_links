import 'package:tag_links/core/decorate_color/decorated_color_themes.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/sync/models/sync_item_wrapper.dart';
import 'package:uuid/uuid.dart';

class Folder extends BaseSyncModel {
  final String? parentId;
  final String title;
  final List<Tag> tags;
  final String? description;
  final String? image;
  final String? color;
  final int createdAt; // Cambiado a int para consistencia
  final bool isFavorite;

  Folder({
    required super.id,
    this.parentId,
    required super.fileId,
    required this.title,
    required this.tags,
    this.description,
    this.image,
    this.color,
    required this.createdAt,
    required super.updatedAt,
    this.isFavorite = false,
  });

  factory Folder.empty({
    required bool hasId,
    required String fileId,
    String? parentId,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return Folder(
      id: hasId ? const Uuid().v4() : '',
      parentId: parentId,
      fileId: fileId,
      title: '',
      tags: [],
      description: null,
      image: null,
      color: null,
      createdAt: now,
      updatedAt: now,
      isFavorite: false,
    ).ensureForInsert();
  }

  static Folder fromMap(Map<String, dynamic> map) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return Folder(
      id: map['id']?.toString() ?? const Uuid().v4(),
      parentId: map['parentId'] as String?,
      fileId: map['fileId']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Carpeta sin nombre',
      description: map['description'] as String?,
      image: map['image'] as String?,
      color: map['color'] as String?,
      isFavorite: (map['isFavorite'] == 1 || map['isFavorite'] == true),
      createdAt: map['createdAt'] ?? now,
      updatedAt: map['updatedAt'] ?? now,
      tags: (map['tags'] as List? ?? [])
          .map((t) => Tag.fromMap(Map<String, dynamic>.from(t)))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parentId': parentId,
      'fileId': fileId,
      'title': title,
      'description': description,
      'image': image,
      'color': color,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  Folder copyWith({
    String? id,
    String? parentId,
    String? title,
    List<Tag>? tags,
    String? description,
    String? image,
    String? color,
    int? createdAt,
    int? updatedAt,
    bool? isFavorite,
  }) {
    return Folder(
      id: id ?? this.id,
      parentId: parentId, // Permitimos que pase como null
      fileId: fileId,
      title: title ?? this.title,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      image: image ?? this.image,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Folder ensureForInsert() {
    return copyWith(
      id: id.isEmpty ? const Uuid().v4() : id,
      parentId: id != parentId ? parentId : null,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }
  DecorateColor? get decorateColor => DecorateColor.fromCode(color);
}

String folderTable = '''
  CREATE TABLE folders (
    id TEXT PRIMARY KEY,
    parentId TEXT,
    title TEXT NOT NULL,
    description TEXT,
    image TEXT,
    color TEXT,
    createdAt INTEGER NOT NULL,
    isFavorite INTEGER NOT NULL DEFAULT 0 CHECK (isFavorite IN (0,1)),
    $itemsBaseColumns, 
    FOREIGN KEY (parentId) REFERENCES folders(id) ON DELETE CASCADE
  );
''';