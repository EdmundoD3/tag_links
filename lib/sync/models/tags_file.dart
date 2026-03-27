import 'package:tag_links/models/tag.dart';
import 'package:tag_links/sync/models/file_base.dart';

class TagsFile extends FileBase {
  final List<Tag> tags;

  TagsFile({
    required super.id,
    required super.fileId,
    required this.tags,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TagsFile.fromMap(Map<String, dynamic> map) {
    return TagsFile(
      id: map['id'],
      fileId: map['fileId'],
      tags: (map['tags'] as List? ?? [])
          .map((t) => Tag.fromMap(t as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['updatedAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fileId': fileId,
      'tags': tags.map((t) => t.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }
}