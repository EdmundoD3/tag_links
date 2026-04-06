class ArchiveItem {
  final String id;
  final String? driveFileId;
  final String fileName;
  final int lastUpdate;
  final String type; // 'notes', 'folders', 'tags', 'deletes'

  ArchiveItem({
    required this.id,
    this.driveFileId,
    required this.fileName,
    required this.lastUpdate,
    required this.type,
  });

  // En el factory, podrías pasar el tipo desde el ArchiveInfo
  factory ArchiveItem.fromMap(Map<String, dynamic> map) {
    return ArchiveItem(
      id: map['id']?.toString() ?? '',
      driveFileId: map['drive_file_id']?.toString(),
      fileName: map['file_name']?.toString() ?? '',
      lastUpdate: (map['lastUpdate'] as num? ?? 0).toInt(),
      type: map['type'],
    );
  }
    Map<String, dynamic> toMap() => {
    "id": id,
    "drive_file_id": driveFileId,
    "file_name": fileName,
    "lastUpdate": lastUpdate,
    "type": type,
  };

  ArchiveItem copyWith({
    String? id,
    String? driveFileId,
    String? fileName,
    int? lastUpdate,
    String? type,
  }) {
    return ArchiveItem(
      id: id ?? this.id,
      driveFileId: driveFileId ?? this.driveFileId,
      fileName: fileName ?? this.fileName,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      type: type ?? this.type,
    );
  }
}