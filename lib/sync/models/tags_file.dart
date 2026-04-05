import 'package:tag_links/models/tag.dart';
import 'package:tag_links/sync/models/sync_file_wrapper.dart';

class TagsFile extends SyncFileWrapper {
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
      id: map['id']?.toString() ?? '',
      fileId: map['fileId']?.toString() ?? '',
      tags: (map['tags'] as List? ?? [])
          .map((t) => Tag.fromMap(Map<String, dynamic>.from(t as Map)))
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
      'tags': tags.map((t) => t.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }
}
