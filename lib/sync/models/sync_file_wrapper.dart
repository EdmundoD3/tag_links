abstract class SyncFileWrapper {
  final String id;
  final String fileId;
  final DateTime createdAt;
  final DateTime updatedAt;

  SyncFileWrapper({
    required this.id,
    required this.fileId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap();
}