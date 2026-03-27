class ArchiveItem {
  final String id; // local id
  final String? driveFileId; // drive id
  final String fileName;
  final int lastUpdate;

  ArchiveItem({
    required this.id,
    this.driveFileId,
    required this.fileName,
    required this.lastUpdate,
  });

  factory ArchiveItem.fromMap(Map<String, dynamic> map) {
    return ArchiveItem(
      id: map['id']?.toString() ?? '',
      driveFileId: map['drive_file_id']?.toString(),
      fileName: map['file_name']?.toString() ?? '',
      // Usamos num para aceptar int o double del JSON y convertimos a int
      lastUpdate: (map['lastUpdate'] as num? ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() => {
    "id": id,
    "drive_file_id": driveFileId,
    "file_name": fileName,
    "lastUpdate": lastUpdate,
  };

  ArchiveItem copyWith({
    String? id,
    String? driveFileId,
    String? fileName,
    int? lastUpdate,
  }) {
    return ArchiveItem(
      id: id ?? this.id,
      driveFileId: driveFileId ?? this.driveFileId,
      fileName: fileName ?? this.fileName,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}