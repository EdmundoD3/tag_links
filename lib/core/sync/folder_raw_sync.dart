import 'dart:convert';
import 'package:tag_links/core/sync/encripter.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/models/tag.dart';

// El userId lo asigna el servidor
class FolderRawSync {
  final String id;
  final String payload;
  final int? deletedAt;

  FolderRawSync({
    required this.id,
    required this.payload,
    required this.deletedAt,
  });

  static FolderRawSync fromFolder(
    Folder folder,
    String key,
    int? deletedAt,
  ) {
    return FolderRawSync(
      id: folder.id,
      payload: _buildPayload(folder, key),
      deletedAt: deletedAt,
    );
  }

  static Folder toFolderFromPayload({
    required String id,
    required String encryptedPayload,
    required String key,
  }) {
    final decrypted = decripter(encryptedPayload, key);

    final Map<String, dynamic> json =
        jsonDecode(decrypted) as Map<String, dynamic>;

    final List<dynamic> tagsRaw =
        (json['tags'] as List<dynamic>?) ?? [];

    return Folder(
      id: id,
      title: json['title'] as String,
      description: json['description'] as String?,
      image: json['image'] as String?, // ahora sí lo soportamos
      tags: tagsRaw
          .map((t) => Tag(
                id: t['id'] as String,
                name: t['name'] as String,
              ))
          .toList(),
      color: json['color'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['createdAt'] as int,
      ),
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              json['updatedAt'] as int,
            )
          : null,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}

String _buildPayload(Folder folder, String key) {
  final raw = <String, dynamic>{
    'v': 1,
    'title': folder.title,
    'description': folder.description,
    'image': folder.image, // ahora consistente
    'tags': folder.tags
        .map((t) => {
              'id': t.id,
              'name': t.name,
            })
        .toList(),
    'color': folder.color,
    'createdAt': folder.createdAt.millisecondsSinceEpoch,
    'updatedAt': (folder.updatedAt ?? folder.createdAt)
        .millisecondsSinceEpoch,
    'isFavorite': folder.isFavorite,
  };

  final json = jsonEncode(raw);
  return encripter(json, key);
}
