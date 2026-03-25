import 'package:tag_links/sync/models/archive_item.dart';

class ArchiveInfo {
  final List<ArchiveItem> tags;
  final List<ArchiveItem> folders;
  final List<ArchiveItem> notes;
  final List<ArchiveItem> deletes; // Nuevo: Para rastrear archivos de borrado

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
    
    return ArchiveInfo(
      tags: (map['tags'] as List? ?? [])
          .map((e) => ArchiveItem.fromMap(e as Map<String, dynamic>))
          .toList(),
      folders: (map['folders'] as List? ?? [])
          .map((e) => ArchiveItem.fromMap(e as Map<String, dynamic>))
          .toList(),
      notes: (map['notes'] as List? ?? [])
          .map((e) => ArchiveItem.fromMap(e as Map<String, dynamic>))
          .toList(),
      deletes: (map['deletes'] as List? ?? [])
          .map((e) => ArchiveItem.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
    "tags": tags.map((e) => e.toMap()).toList(),
    "folders": folders.map((e) => e.toMap()).toList(),
    "notes": notes.map((e) => e.toMap()).toList(),
    "deletes": deletes.map((e) => e.toMap()).toList(),
  };

  /// Permite actualizar partes del índice de forma inmutable
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