// Una pequeña clase para identificar este error
class PathNotFoundException implements Exception {
  final String fileId;
  PathNotFoundException(this.fileId);
  @override
  String toString() => "Archivo no encontrado en Drive: $fileId";
}