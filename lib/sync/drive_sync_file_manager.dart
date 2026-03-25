import 'dart:convert';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:tag_links/sync/models/archive_item.dart';

class DriveSyncFileManager {
  final drive.DriveApi _driveApi;

  DriveSyncFileManager(this._driveApi);

  /// DESCARGA: Obtiene el contenido de un archivo JSON usando su fileId de Drive
  Future<Map<String, dynamic>?> downloadFileContent(String fileId) async {
    try {
      final drive.Media response = await _driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      List<int> bytes = [];
      await for (var data in response.stream) {
        bytes.addAll(data);
      }
      
      return jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    } catch (e) {
      print("Error descargando archivo $fileId: $e");
      return null;
    }
  }

  /// SUBIDA/ACTUALIZACIÓN: Sube un nuevo archivo o actualiza uno existente.
  /// Si item.id es un fileId de Drive válido, lo actualiza. 
  /// Si es un nuevo objeto, crea el archivo y retorna el nuevo ArchiveItem.
  Future<ArchiveItem?> uploadFile({
    required String type,
    required Map<String, dynamic> content,
    String? existingFileId,
  }) async {
    final String jsonString = jsonEncode(content);
    final List<int> bytes = utf8.encode(jsonString);
    final media = drive.Media(Stream.value(bytes), bytes.length);

    try {
      if (existingFileId != null && existingFileId.isNotEmpty) {
        // ACTUALIZAR ARCHIVO EXISTENTE
        await _driveApi.files.update(
          drive.File(),
          existingFileId,
          uploadMedia: media,
        );
        
        return ArchiveItem(
          id: existingFileId,
          fileName: "$existingFileId.json",
          lastUpdate: DateTime.now().millisecondsSinceEpoch,
        );
      } else {
        // CREAR ARCHIVO NUEVO
        final driveFile = drive.File()
          ..name = "${DateTime.now().millisecondsSinceEpoch}_$type.json"
          ..parents = ["appDataFolder"];

        final createdFile = await _driveApi.files.create(
          driveFile,
          uploadMedia: media,
        );

        return ArchiveItem(
          id: createdFile.id!,
          fileName: createdFile.name!,
          lastUpdate: DateTime.now().millisecondsSinceEpoch,
        );
      }
    } catch (e) {
      print("Error subiendo archivo: $e");
      return null;
    }
  }

  /// ELIMINACIÓN: Borra el archivo de la AppDataFolder de Drive
  Future<bool> deleteFile(String fileId) async {
    try {
      await _driveApi.files.delete(fileId);
      return true;
    } catch (e) {
      print("Error eliminando archivo en Drive: $e");
      return false;
    }
  }
}