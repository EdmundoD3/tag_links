class ArchiveItem {
  final String id;
  final String fileName;
  final int lastUpdate;

  ArchiveItem({
    required this.id,
    required this.fileName,
    required this.lastUpdate,
  });

  factory ArchiveItem.fromMap(Map<String, dynamic> map) {
    return ArchiveItem(
      id: map['id'] ?? '',
      fileName: map['file_name'] ?? '',
      lastUpdate: map['lastUpdate'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    "id": id,
    "file_name": fileName,
    "lastUpdate": lastUpdate,
  };
}
