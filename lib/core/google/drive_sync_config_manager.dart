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
          await localIdManager.clearDriveFileId();
        }
      }

      // 2. Camino Lento (Búsqueda por nombre)
      final drive.FileList found = await _findConfigFileId();
      if (found.files != null && found.files!.isNotEmpty) {
        final fileId = found.files!.first.id!;
        final remoteMap = await _downloadConfig(fileId);

        if (remoteMap != null) {
          await localIdManager.saveDriveFileId(fileId);
          return await _processExistingConfig(fileId, remoteMap, myId);
        }
      }

      // 3. Recreación/Inicialización (Aquí entra tu lógica de inyectar metadata local)
      print("🔍 Reconstruyendo configuración desde estado local...");
      final newData = await _createInitialRemoteConfig(myId);
      await localIdManager.saveDriveFileId(newData.fileId);
      return newData;
    } catch (e) {
      debugPrint("❌ Fallo crítico en ConfigManager: $e");
      return null;
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
      print("📱 Registrando nuevo dispositivo en el archivo de configuración.");
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
  Future<Map<String, dynamic>?> _downloadConfig(String fileId) async {
    try {
      final response = await _driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      );

      if (response is drive.Media) {
        // Usamos una forma más directa de convertir el stream a string
        final String decoded = await response.stream
            .transform(utf8.decoder)
            .join();

        if (decoded.trim().isEmpty) return null;
        return jsonDecode(decoded) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint("❌ Error descargando $fileId: $e");
      // Si es un 404, retornamos null para que el llamador intente recrear
      return null;
    }
  }

  /// Sube cambios a un archivo existente
  Future<void> updateRemoteConfig(String fileId, ConfigInfo config) async {
    try {
      final content = utf8.encode(jsonEncode(config.toMap()));
      final media = drive.Media(Stream.value(content), content.length);

      await _driveApi.files.update(drive.File(), fileId, uploadMedia: media);
      print("📱 Drive: Configuración actualizada.");
    } catch (e) {
      debugPrint(
        "DriveSyncConfigManager.updateRemoteConfig: Error actualizando $fileId: $e",
      );
    }
  }
}

// Provider de Riverpod
final syncConfigProvider = Provider<DriveSyncConfigManager?>((ref) {
  final auth = ref.watch(authProvider);
  if (auth.driveApi == null) return null;

  // Usar watch es mejor para mantener la reactividad en el grafo de dependencias
  final localSyncQueueRepository = ref.watch(localSyncQueueRepositoryProvider);

  return DriveSyncConfigManager(
    auth.driveApi!,
    localIdManager: ref.watch(localIdManagerProvider),
    syncQueueRepo: localSyncQueueRepository,
  );
});
