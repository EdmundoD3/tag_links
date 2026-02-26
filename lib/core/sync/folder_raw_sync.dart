import 'dart:convert';
import 'package:tag_links/core/encypt/encripter.dart';
import 'package:tag_links/data/data_sources/deleted_dao.dart';
import 'package:tag_links/models/folder.dart';

class FolderRawSync {
  final String id;
  final String payload;
  final int? deletedAt;

  FolderRawSync({
    required this.id,
    required this.payload,
    this.deletedAt,
  });

  static FolderRawSync fromDeleted(DeletedData deletedData) {
    return FolderRawSync(
      id: deletedData.id,
      payload: "",
      deletedAt: deletedData.deletedAt,
    );
  }

  static Future<FolderRawSync> fromFolder(Folder folder) async {
    return FolderRawSync(
      id: folder.id,
      payload: await _buildFolderPayload(folder),
      deletedAt: null,
    );
  }

  factory FolderRawSync.fromJson(Map<String, dynamic> json) {
    return FolderRawSync(
      id: json['id'] as String,
      payload: json['payload'] as String? ?? "",
      deletedAt: json['deletedAt'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'payload': payload,
    'deletedAt': deletedAt,
  };
}

Future<String> _buildFolderPayload(Folder folder) {
  final raw = {
    'v': 1,
    'title': folder.title,
    'description': folder.description,
    'image': folder.image,
    'tags': folder.tags.map((t) => {'id': t.id, 'name': t.name}).toList(),
    'color': folder.color,
    'createdAt': folder.createdAt.millisecondsSinceEpoch,
    'updatedAt': folder.updatedAt.millisecondsSinceEpoch,
    'isFavorite': folder.isFavorite,
  };
  return encripter(jsonEncode(raw));
}