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
  String? fileName, // Ahora es casi obligatorio para el fallback
}) async {
  try {
    return await _executeDownload<T>(fileId, fromMap);
  } catch (e) {
    if ((e.toString().contains("404") || e.toString().contains("File not found")) && fileName != null) {
      debugPrint("🔍 Falló fileId, intentando recuperar por nombre: $fileName");
      
      // Intentamos buscarlo en Drive por nombre
      final list = await _driveApi.files.list(
        q: "name = '$fileName' and trashed = false",
        spaces: 'appDataFolder',
      );

      if (list.files != null && list.files!.isNotEmpty) {
        final newId = list.files!.first.id!;
        debugPrint("✅ Archivo encontrado con nuevo ID: $newId");
        // Reintentamos con el nuevo ID (Esto podrías guardarlo en el catch del Puller)
        return await _executeDownload<T>(newId, fromMap);
      }
      
      throw PathNotFoundException(fileId);
    }
    rethrow;
  }
}

// Método privado para no repetir la lógica de streaming
Future<List<T>> _executeDownload<T>(String id, T Function(Map<String, dynamic>) fromMap) async {
  final response = await _driveApi.files.get(id, downloadOptions: drive.DownloadOptions.fullMedia);
  if (response is! drive.Media) throw Exception("Error de medio");
  
  final List<int> dataChunks = await response.stream.expand((chunk) => chunk).toList();
  final dynamic jsonData = json.decode(utf8.decode(dataChunks));

  if (jsonData is List) {
    return jsonData.map((item) => fromMap(Map<String, dynamic>.from(item))).toList();
  } else if (jsonData is Map) {
    return [fromMap(Map<String, dynamic>.from(jsonData))];
  }
  return [];
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
