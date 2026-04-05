import 'package:tag_links/models/folder.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/sync/models/sync_file_wrapper.dart';

class FoldersFile extends SyncFileWrapper {
  final List<Folder> folders;

  FoldersFile({
    required super.id,
    required super.fileId,
    required this.folders,
    required super.createdAt,
    required super.updatedAt,
  });

  factory FoldersFile.fromMap(Map<String, dynamic> map) {
    return FoldersFile(
      id: map['id'],
      fileId: map['fileId'],
      folders: (map['folders'] as List? ?? [])
          .map((f) => FoldersToFile.fromMap(f as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['updatedAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fileId': fileId,
      'folders': folders.map((f) => FoldersToFile.toMap(f)).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }
}

class FoldersToFile {
  static Map<String, dynamic> toMap(Folder folder) {
    return {
      'id': folder.id,
      'parentId': folder.parentId,
      'fileId': folder.fileId,
      'title': folder.title,
      'description': folder.description,
      'image': folder.image,
      'color': folder.color,
      'isFavorite': folder.isFavorite ? 1 : 0,
      'createdAt': folder.createdAt,
      'updatedAt': folder.updatedAt,
      'syncAt': folder.syncAt,
      // Guardamos los tags completos de la carpeta
      'tags': folder.tags.map((t) => t.toMap()).toList(),
    };
  }

  static Folder fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map['id'] as String,
      parentId: map['parentId'] as String?,
      fileId: map['fileId'] as String,
      title: map['title'] ?? '',
      description: map['description'] as String?,
      image: map['image'] as String?,
      color: map['color'] as String?,
      isFavorite: (map['isFavorite'] ?? 0) == 1,
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      syncAt: map['syncAt'],
      tags: (map['tags'] as List? ?? [])
          .map((t) => Tag.fromMap(t as Map<String, dynamic>))
          .toList(),
    );
  }
}
