abstract class FileBase {
  final String id;
  final String fileId;
   final DateTime createdAt;
  final DateTime updatedAt;

  FileBase({
    required this.id,
    required this.fileId,
    required this.createdAt,
    required this.updatedAt,
  });
}