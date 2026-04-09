import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:tag_links/core/google/auth_provider.dart';
import 'package:tag_links/sync/db/local_sync_queue_repository.dart';
import 'package:tag_links/sync/models/config_info.dart';
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
  final LocalSyncQueueRepository _syncQueueRepo;

  DriveSyncConfigManager(
    this._driveApi, {
    required this.localIdManager,
    required LocalSyncQueueRepository syncQueueRepo,
  }) : _syncQueueRepo = syncQueueRepo;

  /// Obtiene o inicializa la configuración de Drive usando caché de ID para optimizar.
  Future<RemoteConfigData?> getOrInitializeRemoteConfig() async {
    final String myId = localIdManager.getOrCreateDeviceId();
    final String? cachedFileId = localIdManager.getDriveFileId();

    try {
      // 1. Intento Rápido
      if (cachedFileId != null) {
        try {
          final remoteMap = await _downloadConfig(cachedFileId);
          if (remoteMap != null) {
            return await _processExistingConfig(cachedFileId, remoteMap, myId);
          }
        } catch (e) {
          // 🎯 Si es un 401 aquí, debemos lanzarlo, NO borrar el cache y seguir.
          if (e.toString().contains('401')) rethrow; 
          
          await localIdManager.clearDriveFileId();
        }
      }

      // 2. Camino Lento
      final drive.FileList found = await _findConfigFileId();
      if (found.files != null && found.files!.isNotEmpty) {
        final fileId = found.files!.first.id!;
        final remoteMap = await _downloadConfig(fileId);

        if (remoteMap != null) {
          await localIdManager.saveDriveFileId(fileId);
          return await _processExistingConfig(fileId, remoteMap, myId);
        }
      }

      // 3. Recreación
      debugPrint("🔍 DriveSyncConfigManager: Reconstruyendo configuración...");
      final newData = await _createInitialRemoteConfig(myId);
      await localIdManager.saveDriveFileId(newData.fileId);
      return newData;

    } catch (e) {
      debugPrint("❌ DriveSyncConfigManager: Fallo crítico: $e");
      // 🎯 CRÍTICO: Si el error es de autenticación, LÁNZALO.
      // Si solo haces 'return null', el Notifier cree que es un error de red genérico.
      if (e.toString().contains('401')) rethrow; 
      
      return null; 
    }
  }

  /// Descarga el JSON de Drive
  Future<Map<String, dynamic>?> _downloadConfig(String fileId) async {
    try {
      final response = await _driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      );

      if (response is drive.Media) {
        final String decoded = await response.stream
            .transform(utf8.decoder)
            .join();

        if (decoded.trim().isEmpty) return null;
        return jsonDecode(decoded) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint("❌ DriveSyncConfigManager.downloadConfig error: $e");
      
      // 🎯 NUEVA LÓGICA DE EXCEPCIONES:
      // Si el error es 404 (no existe), devolvemos null para que se intente crear uno nuevo.
      // Pero si es 401 (auth), DEBEMOS lanzar la excepción.
      if (e.toString().contains('401')) rethrow;
      
      return null; // Solo retornamos null si el archivo no existe o hay error de parsing
    }
  }

  Future<void> updateRemoteConfig(String fileId, ConfigInfo config) async {
    try {
      final content = utf8.encode(jsonEncode(config.toMap()));
      final media = drive.Media(Stream.value(content), content.length);

      await _driveApi.files.update(drive.File(), fileId, uploadMedia: media);
    } catch (e) {
      debugPrint("❌ Error actualizando config: $e");
      if (e.toString().contains('401')) rethrow; // 🔥 Deja que el SyncNotifier se entere
    }
  }

  /// Procesa una configuración existente: valida el dispositivo y actualiza si es necesario.
  Future<RemoteConfigData> _processExistingConfig(
    String fileId,
    Map<String, dynamic> map,
    String myId,
  ) async {
    ConfigInfo config = ConfigInfo.fromMap(map);
    final currentDevice = DeviceInfo.createCurrent(myId);

    // Si el dispositivo actual no está registrado en el archivo remoto, lo añadimos
    if (!config.hasDevice(myId)) {
      debugPrint("📱 Registrando nuevo dispositivo en el archivo de configuración.");
      config = config.upsertDevice(currentDevice);
      await updateRemoteConfig(fileId, config);
    }

    return RemoteConfigData(fileId, config);
  }

  /// Crea el archivo por primera vez en Drive
  /// Crea el archivo por primera vez, pero inyectando lo que ya conocemos localmente
  Future<RemoteConfigData> _createInitialRemoteConfig(String myId) async {
    final localState = await _syncQueueRepo.getLocalArchiveForConfig();
    final currentDevice = DeviceInfo.createCurrent(myId);

    final config = ConfigInfo(
      lastGlobalUpdate: DateTime.now().millisecondsSinceEpoch,
      devices: [currentDevice],
      version: 1,
      premiumUntil: 0,
      archiveInfo: localState, // <--- Aquí inyectamos la metadata local
    );

    final driveFile = drive.File()
      ..name = _configName
      ..parents = ["appDataFolder"];

    final content = utf8.encode(jsonEncode(config.toMap()));
    final media = drive.Media(Stream.value(content), content.length);

    final createdFile = await _driveApi.files.create(
      driveFile,
      uploadMedia: media,
    );

    debugPrint("✅ DriveSyncConfigManager.createInitialRemoteConfig: Configuración inicial creada exitosamente.");
    return RemoteConfigData(createdFile.id!, config);
  }

  /// Busca el archivo por nombre
  Future<drive.FileList> _findConfigFileId() async {
    return await _driveApi.files.list(
      q: "name = '$_configName' and 'appDataFolder' in parents",
      spaces: 'appDataFolder',
    );
  }
}

final syncConfigProvider = Provider<DriveSyncConfigManager?>((ref) {
  // 🎯 Solo re-ejecuta si el driveApi CAMBIA (ej: tras una reparación)
  final driveApi = ref.watch(authProvider.select((s) => s.driveApi));
  
  if (driveApi == null) return null;

  return DriveSyncConfigManager(
    driveApi,
    localIdManager: ref.watch(localIdManagerProvider),
    syncQueueRepo: ref.watch(localSyncQueueRepositoryProvider),
  );
});