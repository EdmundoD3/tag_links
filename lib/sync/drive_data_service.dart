import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:tag_links/sync/exceptions/path_not_found.dart';

class DriveDataService {
  final drive.DriveApi _driveApi;

  DriveDataService(this._driveApi);

  // ==========================================
  // DESCARGA (PULL)
  // ==========================================

  Future<List<T>> downloadArray<T>({
    required String fileId,
    required T Function(Map<String, dynamic>) fromMap,

    ///opcional para debug
    String? fileName,
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
      // DETECCIÓN DE ARCHIVO NO ENCONTRADO
      if (e.toString().contains("404") ||
          e.toString().contains("File not found")) {
        debugPrint("⚠️ El archivo $fileId ya no existe en Drive.");
        // Lanzamos una excepción específica o retornamos una lista vacía
        // Pero es mejor lanzar una excepción personalizada para que el Puller sepa qué pasó
        throw PathNotFoundException(fileId);
      }
      rethrow;
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
  final List<Map<String, dynamic>> jsonList = items.map((item) => toMap(item)).toList();
  final String jsonString = json.encode(jsonList);
  final List<int> bytes = utf8.encode(jsonString);

  final drive.File fileMetadata = drive.File()
    ..name = fileName
    ..mimeType = 'application/json';

  // 💡 Función local para generar un Media "fresco" cada vez
  drive.Media createMedia() => drive.Media(Stream.value(bytes), bytes.length);

  try {
    if (existingFileId != null) {
      try {
        // 1. Primer intento: Update con un media nuevo
        final updatedFile = await _driveApi.files.update(
          fileMetadata,
          existingFileId,
          uploadMedia: createMedia(), // <-- Media fresco
          $fields: 'id',
        );
        return updatedFile.id!;
      } catch (e) {
        // 2. Detección de archivo borrado en Drive
        if (e.toString().contains("404") || e.toString().contains("File not found")) {
          debugPrint("⚠️ El archivo $existingFileId no existe. Creando uno nuevo...");
          
          // 3. Segundo intento: Create con OTRO media nuevo
          return await _createNewFile(fileMetadata, createMedia()); 
        }
        rethrow; 
      }
    } else {
      // 4. No había ID, crear directamente con media nuevo
      return await _createNewFile(fileMetadata, createMedia());
    }
  } catch (e) {
    debugPrint("DriveDataService.uploadArray Error: $e");
    rethrow;
  }
}

  // Helper simple para no repetir código de creación
  Future<String> _createNewFile(drive.File metadata, drive.Media media) async {
    metadata.parents = ['appDataFolder'];
    final newFile = await _driveApi.files.create(
      metadata,
      uploadMedia: media,
      $fields: 'id',
    );
    return newFile.id!;
  }
}
