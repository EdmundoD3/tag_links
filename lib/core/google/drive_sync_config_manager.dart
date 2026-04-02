import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:tag_links/core/google/auth_provider.dart';
import 'package:tag_links/sync/models/config_info.dart';
import 'package:tag_links/sync/models/archive_info.dart';
import 'package:tag_links/core/google/local_id_manager.dart';
import 'package:tag_links/sync/models/device_info.dart';

class RemoteConfigData {
  final String fileId;
  final ConfigInfo config;

  RemoteConfigData(this.fileId, this.config);
}

class DriveSyncConfigManager {
  final drive.DriveApi _driveApi;
  static const String _configName = 'sync_config.json';
  final LocalIdManager localIdManager;

  DriveSyncConfigManager(this._driveApi, {required this.localIdManager});

  /// Obtiene o inicializa la configuración de Drive usando caché de ID para optimizar.
  Future<RemoteConfigData?> getOrInitializeRemoteConfig() async {
    final String myId = localIdManager.getOrCreateDeviceId();
    final String? cachedFileId = localIdManager.getDriveFileId();

    try {
      // 1. Intento Rápido: Usar el ID que ya conocemos
      if (cachedFileId != null) {
        try {
          print("🚀 Intentando acceso rápido por ID: $cachedFileId");
          final remoteMap = await _downloadConfig(cachedFileId);
          return await _processExistingConfig(cachedFileId, remoteMap, myId);
        } catch (e) {
          // Si falla (ej. 404), el archivo fue borrado. Limpiamos caché y seguimos.
          print("⚠️ ID en caché no válido o archivo borrado. Re-escaneando...");
          await localIdManager.clearDriveFileId();
        }
      }

      // 2. Camino Lento: Buscar por nombre en la AppDataFolder
      final drive.FileList found = await _findConfigFileId();

      if (found.files != null && found.files!.isNotEmpty) {
        final fileId = found.files!.first.id!;
        await localIdManager.saveDriveFileId(fileId); // Guardamos para la próxima vez
        
        final remoteMap = await _downloadConfig(fileId);
        return await _processExistingConfig(fileId, remoteMap, myId);
      }

      // 3. Inicialización: Si realmente no existe, lo creamos
      print("🔍 Config no encontrada en Drive. Creando una nueva...");
      final newData = await _createInitialRemoteConfig(myId);
      
      // Guardamos el ID del nuevo archivo creado
      await localIdManager.saveDriveFileId(newData.fileId);
      return newData;

    } catch (e) {
      debugPrint("❌ Error de comunicación con Drive: $e");
      return null;
    }
  }

  /// Procesa una configuración existente: valida el dispositivo y actualiza si es necesario.
  Future<RemoteConfigData> _processExistingConfig(
    String fileId, 
    Map<String, dynamic> map, 
    String myId
  ) async {
    ConfigInfo config = ConfigInfo.fromMap(map);
    final currentDevice = DeviceInfo.createCurrent(myId);

    // Si el dispositivo actual no está registrado en el archivo remoto, lo añadimos
    if (!config.hasDevice(myId)) {
      print("📱 Registrando nuevo dispositivo en el archivo de configuración.");
      config = config.upsertDevice(currentDevice);
      await updateRemoteConfig(fileId, config);
    }
    
    return RemoteConfigData(fileId, config);
  }

  /// Crea el archivo por primera vez en Drive
  Future<RemoteConfigData> _createInitialRemoteConfig(String myId) async {
    final currentDevice = DeviceInfo.createCurrent(myId);

    final config = ConfigInfo(
      lastGlobalUpdate: DateTime.now().millisecondsSinceEpoch,
      devices: [currentDevice],
      version: 1,
      premiumUntil: 0,
      archiveInfo: ArchiveInfo(tags: [], folders: [], notes: [], deletes: []),
    );

    final driveFile = drive.File()
      ..name = _configName
      ..parents = ["appDataFolder"];

    final content = utf8.encode(jsonEncode(config.toMap()));
    final media = drive.Media(Stream.value(content), content.length);

    final createdFile = await _driveApi.files.create(driveFile, uploadMedia: media);
    
    print("✅ Configuración inicial creada exitosamente.");
    return RemoteConfigData(createdFile.id!, config);
  }

  /// Busca el archivo por nombre
  Future<drive.FileList> _findConfigFileId() async {
    return await _driveApi.files.list(
      q: "name = '$_configName' and 'appDataFolder' in parents",
      spaces: 'appDataFolder',
    );
  }

  /// Descarga el JSON de Drive
  Future<Map<String, dynamic>> _downloadConfig(String fileId) async {
    final drive.Media response = await _driveApi.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    List<int> bytes = [];
    await for (var data in response.stream) {
      bytes.addAll(data);
    }
    return jsonDecode(utf8.decode(bytes));
  }

  /// Sube cambios a un archivo existente
  Future<void> updateRemoteConfig(String fileId, ConfigInfo config) async {
    final content = utf8.encode(jsonEncode(config.toMap()));
    final media = drive.Media(Stream.value(content), content.length);

    await _driveApi.files.update(drive.File(), fileId, uploadMedia: media);
    print("📱 Drive: Configuración actualizada.");
  }
}

// Provider de Riverpod
final syncConfigProvider = Provider<DriveSyncConfigManager?>((ref) {
  final auth = ref.watch(authProvider); // Esto ahora es seguro
  if (auth.driveApi == null) return null;

  return DriveSyncConfigManager(
    auth.driveApi!,
    localIdManager: ref.watch(localIdManagerProvider),
  );
});