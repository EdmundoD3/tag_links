import 'package:tag_links/sync/models/archive_item.dart';

class ArchiveInfo {
  final List<ArchiveItem> tags;
  final List<ArchiveItem> folders;
  final List<ArchiveItem> notes;
  final List<ArchiveItem> deletes;

  ArchiveInfo({
    required this.tags,
    required this.folders,
    required this.notes,
    required this.deletes,
  });

  factory ArchiveInfo.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return ArchiveInfo(tags: [], folders: [], notes: [], deletes: []);
    }
    
    // Función auxiliar interna para limpiar los mapeos de lista
    List<ArchiveItem> parseList(dynamic list) {
      if (list == null || list is! List) return [];
      return list
          .map((e) => ArchiveItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    return ArchiveInfo(
      tags: parseList(map['tags']),
      folders: parseList(map['folders']),
      notes: parseList(map['notes']),
      deletes: parseList(map['deletes']),
    );
  }

  Map<String, dynamic> toMap() => {
    "tags": tags.map((e) => e.toMap()).toList(),
    "folders": folders.map((e) => e.toMap()).toList(),
    "notes": notes.map((e) => e.toMap()).toList(),
    "deletes": deletes.map((e) => e.toMap()).toList(),
  };

  ArchiveInfo copyWith({
    List<ArchiveItem>? tags,
    List<ArchiveItem>? folders,
    List<ArchiveItem>? notes,
    List<ArchiveItem>? deletes,
  }) {
    return ArchiveInfo(
      tags: tags ?? this.tags,
      folders: folders ?? this.folders,
      notes: notes ?? this.notes,
      deletes: deletes ?? this.deletes,
    );
  }
}