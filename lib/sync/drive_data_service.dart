import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;
class DriveDataService {
  final drive.DriveApi _driveApi;

  DriveDataService(this._driveApi);

  // ==========================================
  // DESCARGA (PULL)
  // ==========================================

  Future<List<T>> downloadArray<T>({
    required String fileId,
    required T Function(Map<String, dynamic>) fromMap,
  }) async {
    try {
      // 1. IMPORTANTE: Cambiado a fullMedia para obtener el contenido real
      final response = await _driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      );

      if (response is! drive.Media) {
        throw Exception("No se pudo obtener el contenido del archivo $fileId");
      }

      // 2. Forma más eficiente de recolectar bytes en Dart
      final List<int> dataChunks = await response.stream
          .expand((chunk) => chunk)
          .toList();

      final String decoded = utf8.decode(dataChunks);
      final dynamic jsonData = json.decode(decoded);

      // Manejamos si el JSON viene como un objeto único o una lista
      if (jsonData is List) {
        return jsonData
            .map((item) => fromMap(Map<String, dynamic>.from(item)))
            .toList();
      } else if (jsonData is Map) {
        // Por si acaso subes un Wrapper único en lugar de una lista
        return [fromMap(Map<String, dynamic>.from(jsonData))];
      }
      
      return [];
    } catch (e) {
      debugPrint("DriveDataService.downloadArray Error: $e");
      throw Exception("Error descargando $fileId: $e");
    }
  }

  // ==========================================
  // SUBIDA (PUSH)
  // ==========================================

  Future<String> uploadArray<T>({
    required List<T> items,
    required Map<String, dynamic> Function(T) toMap,
    required String fileName,
    String? existingFileId,
  }) async {
    try {
      final List<Map<String, dynamic>> jsonList = 
          items.map((item) => toMap(item)).toList();
      
      // Si solo hay un item (como tus Wrappers), podrías decidir 
      // si mandas la lista o solo el objeto. Aquí seguimos con lista:
      final String jsonString = json.encode(jsonList);
      final List<int> bytes = utf8.encode(jsonString);
      final Stream<List<int>> stream = Stream.value(bytes);

      final drive.File fileMetadata = drive.File()
        ..name = fileName
        ..mimeType = 'application/json';

      final drive.Media media = drive.Media(stream, bytes.length);

      if (existingFileId != null) {
        // 3. Optimizamos la respuesta pidiendo solo el ID
        final updatedFile = await _driveApi.files.update(
          fileMetadata,
          existingFileId,
          uploadMedia: media,
          $fields: 'id', 
        );
        return updatedFile.id!;
      } else {
        fileMetadata.parents = ['appDataFolder'];
        final newFile = await _driveApi.files.create(
          fileMetadata,
          uploadMedia: media,
          $fields: 'id',
        );
        return newFile.id!;
      }
    } catch (e) {
      debugPrint("DriveDataService.uploadArray Error: $e");
      rethrow;
    }
  }
}