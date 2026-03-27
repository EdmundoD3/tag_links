import 'dart:convert';
import 'package:googleapis/drive/v3.dart' as drive;

class DriveDataService {
  final drive.DriveApi _driveApi;

  DriveDataService(this._driveApi);

  // ==========================================
  // DESCARGA (PULL)
  // ==========================================

  /// Descarga un archivo de Drive y lo convierte a una lista de objetos
  Future<List<T>> downloadArray<T>({
    required String fileId,
    required T Function(Map<String, dynamic>) fromMap,
  }) async {
    try {
      final drive.Media media = await _driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.metadata,
      ) as drive.Media;

      final List<int> dataChunks = [];
      await for (var chunk in media.stream) {
        dataChunks.addAll(chunk);
      }

      final String decoded = utf8.decode(dataChunks);
      final List<dynamic> jsonList = json.decode(decoded);

      return jsonList
          .map((item) => fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      throw Exception("Error descargando $fileId: $e");
    }
  }

  // ==========================================
  // SUBIDA (PUSH)
  // ==========================================

  /// Crea o actualiza un archivo JSON en Drive
  Future<String> uploadArray<T>({
    required List<T> items,
    required Map<String, dynamic> Function(T) toMap,
    required String fileName,
    String? existingFileId,
  }) async {
    final List<Map<String, dynamic>> jsonList = 
        items.map((item) => toMap(item)).toList();
    
    final String jsonString = json.encode(jsonList);
    final List<int> bytes = utf8.encode(jsonString);
    final Stream<List<int>> stream = Stream.value(bytes);

    final drive.File fileMetadata = drive.File()
      ..name = fileName
      ..mimeType = 'application/json';

    final drive.Media media = drive.Media(stream, bytes.length);

    if (existingFileId != null) {
      // Actualizar archivo existente
      final updatedFile = await _driveApi.files.update(
        fileMetadata,
        existingFileId,
        uploadMedia: media,
      );
      return updatedFile.id!;
    } else {
      // Crear nuevo archivo (Asegúrate de ponerlo en la carpeta de la app)
      fileMetadata.parents = ['appDataFolder'];
      final newFile = await _driveApi.files.create(
        fileMetadata,
        uploadMedia: media,
      );
      return newFile.id!;
    }
  }
}