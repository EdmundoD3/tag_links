import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:tag_links/core/google/auth_provider.dart';
import 'package:tag_links/sync/models/config_info.dart';
import 'package:tag_links/sync/models/archive_info.dart';
import 'package:tag_links/core/google/local_id_manager.dart';
import 'package:tag_links/sync/models/device_info.dart';
import 'package:tag_links/data/shared_prefs_provider.dart';

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

  Future<RemoteConfigData?> getRemoteConfig() async {
    final drive.FileList found = await _findConfigFileId();

    if (found.files == null || found.files!.isEmpty) return null;

    final fileId = found.files!.first.id!;
    final remoteMap = await _downloadConfig(fileId);

    return RemoteConfigData(fileId, ConfigInfo.fromMap(remoteMap));
  }

  /// 1. BUSCAR: Devuelve la lista de archivos que coinciden con el nombre
  /// Lo hacemos público para que otros managers obtengan el fileId
  Future<drive.FileList> _findConfigFileId() async {
    return await _driveApi.files.list(
      q: "name = '$_configName' and 'appDataFolder' in parents",
      spaces: 'appDataFolder',
    );
  }

  /// 2. DESCARGAR: Baja el contenido del JSON y lo convierte en Mapa
  /// Útil para obtener la versión más reciente antes de un copyWith
  Future<Map<String, dynamic>> _downloadConfig(String fileId) async {
    final drive.Media response =
        await _driveApi.files.get(
              fileId,
              downloadOptions: drive.DownloadOptions.fullMedia,
            )
            as drive.Media;

    List<int> bytes = [];
    await for (var data in response.stream) {
      bytes.addAll(data);
    }
    final decoded = utf8.decode(bytes);
    return jsonDecode(decoded);
  }

  /// 3. ACTUALIZAR: Sube los cambios de un ConfigInfo existente
  Future<void> updateRemoteConfig(String fileId, ConfigInfo config) async {
    final content = utf8.encode(jsonEncode(config.toMap()));
    final media = drive.Media(Stream.value(content), content.length);

    await _driveApi.files.update(drive.File(), fileId, uploadMedia: media);
    print("📱 Configuración actualizada exitosamente en Drive.");
  }

  /// Lógica de inicialización (usa los métodos anteriores internamente)
  /// Lógica de inicialización optimizada
  Future<ConfigInfo?> checkAndInitializeConfig() async {
    final String myId = localIdManager.getOrCreateId();

    // Usamos el método que ya centraliza la búsqueda y descarga
    final remoteData = await getRemoteConfig();

    if (remoteData != null) {
      ConfigInfo config = remoteData.config;
      final currentDevice = DeviceInfo.createCurrent(myId);

      // Si el dispositivo no existe o sus datos son viejos, actualizamos
      if (!config.hasDevice(myId)) {
        config = config.upsertDevice(currentDevice);
        await updateRemoteConfig(remoteData.fileId, config);
      }
      return config;
    } else {
      try {
        // Si no existe el archivo, lo creamos
        return await _createInitialRemoteConfig(myId);
      } catch (e) {
        debugPrint("DriveSyncConfigManager: Error al crear configuración: $e");
        return null;
      }
    }
  }

  /// Crea el archivo por primera vez
  Future<ConfigInfo> _createInitialRemoteConfig(String myId) async {
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

    await _driveApi.files.create(driveFile, uploadMedia: media);
    print("✅ Configuración inicial creada.");
    return config;
  }
}

// Provider de Riverpod
final syncConfigProvider = Provider<DriveSyncConfigManager?>((ref) {
  final auth = ref.watch(authProvider);
  if (auth.driveApi == null) return null;
  final prefs = ref.watch(sharedPrefsProvider);
  final localIdManager = LocalIdManager(prefs);
  return DriveSyncConfigManager(auth.driveApi!, localIdManager: localIdManager);
});
