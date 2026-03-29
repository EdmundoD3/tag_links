import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/google/auth_provider.dart';
import 'package:tag_links/core/google/drive_sync_config_manager.dart';
import 'package:tag_links/core/google/local_id_manager.dart';
import 'package:tag_links/data/shared_prefs_provider.dart';
import 'package:tag_links/repository/folder_repository.dart';
import 'package:tag_links/repository/notes_repository.dart';
import 'package:tag_links/repository/tags_repository.dart';
import 'package:tag_links/sync/db/local_sync_queue_repository.dart';
import 'package:tag_links/sync/drive_data_service.dart';
import 'package:tag_links/sync/last_sync_storage.dart';
import 'package:tag_links/sync/models/device_info.dart';
import 'package:tag_links/sync/sync_puller.dart';
import 'package:tag_links/sync/sync_pusher.dart';

class SyncManager {
  final DriveSyncConfigManager _configManager;
  final SyncStorage _storage;
  final LocalIdManager _idManager;
  final SyncPusher _syncPusher;
  final SyncPuller _syncPuller;

  SyncManager({
    required DriveSyncConfigManager configManager,
    required SyncStorage storage,
    required LocalIdManager idManager,
    required SyncPuller syncPuller,
    required SyncPusher syncPusher,
  }) : _configManager = configManager,
       _storage = storage,
       _idManager = idManager,
       _syncPuller = syncPuller,
       _syncPusher = syncPusher;

  bool _isSynchronizing = false;

  /// Sincronización inteligente con delay (por defecto 5 min)
  Future<void> synchronize({
    Duration delay = const Duration(minutes: 5),
  }) async {
    // 1. Seguro de estado: Si ya hay una orquestación en marcha, ignoramos
    if (_isSynchronizing) {
      debugPrint("Sync: Bloqueado. Ya hay una sincronización en curso.");
      return;
    }

    final lastSync = await _storage.getLastPulledAt() ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    // 2. Seguro de frecuencia: Verificamos el delay
    if (lastSync == 0 || (now - lastSync) >= delay.inMilliseconds) {
      await forceSynchronize();
    } else {
      final remaining = (delay.inMilliseconds - (now - lastSync)) ~/ 1000;
      debugPrint(
        "Sync: Omitido. Faltan ${remaining}s para el próximo intento.",
      );
    }
  }

  /// Fuerza la sincronización ignorando el delay, pero respetando el bloqueo de estado
  Future<void> forceSynchronize() async {
    if (_isSynchronizing) return;

    try {
      _isSynchronizing = true; // ACTIVAR BLOQUEO
      debugPrint("Sync: Orquestación iniciada...");

      await _executeFullSync();
    } finally {
      _isSynchronizing =
          false; // LIBERAR BLOQUEO (siempre, incluso si hay error)
      debugPrint("Sync: Bloqueo liberado.");
    }
  }

  Future<void> _executeFullSync() async {
    try {
      // 0. REQUISITOS
      final remoteData = await _configManager.getOrInitializeRemoteConfig();
      if (remoteData == null) return;
      final lastPulled = await _storage.getLastPulledAt() ?? 0;

      // --- FASE 1: PULL (ENTRADA) ---
      // Usamos el Puller que ya hiciste
      await _syncPuller.processRemoteArchive(
        remote: remoteData.config.archiveInfo,
      );
      await _syncPuller.processRemoteDeletes(
        remoteData.config.archiveInfo.deletes,
        lastPulled,
      );
      await _syncPuller.processRemoteData(
        remoteData.config.archiveInfo,
        lastPulled,
      );

      // --- FASE 2: PUSH (SALIDA) ---
      // El Pusher se encarga de todo el proceso de subida y devuelve la config actualizada
      final updatedArchive = await _syncPusher.pushLocalChanges(
        currentArchive: remoteData.config.archiveInfo,
        maxFiles: 10, // Límite de seguridad
      );

      // --- FASE 3: CIERRE ---
      // Solo actualizamos el config.json si el Pusher detectó cambios (o si el puller hizo algo)
      final finalConfig = remoteData.config
          .copyWith(
            archiveInfo: updatedArchive,
            lastGlobalUpdate: DateTime.now().millisecondsSinceEpoch,
          )
          .upsertDevice(DeviceInfo.createCurrent(_idManager.getOrCreateDeviceId()));

      await _configManager.updateRemoteConfig(remoteData.fileId, finalConfig);
      await _storage.setLastPulledAt(DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint("SyncManager Orchestrator Error: $e");
    }
  }
}

final syncManagerProvider = Provider<SyncManager?>((ref) {
  // Obtenemos tu manager ya configurado
  final configManager = ref.watch(syncConfigProvider);
  if (configManager == null) return null;

  // Obtenemos el API para el servicio de transporte
  final auth = ref.watch(authProvider);
  final dataService = DriveDataService(auth.driveApi!);

  // Obtenemos el resto de dependencias
  final prefs = ref.watch(sharedPrefsProvider);
  final syncQueueRepo = ref.watch(localSyncQueueRepositoryProvider);
  final notesRepo = ref.watch(notesRepositoryProvider);
  final folderRepo = ref.watch(folderRepositoryProvider);
  final tagsRepo = ref.watch(tagsRepositoryProvider);

  final syncPuller = SyncPuller(
    syncQueueRepo: syncQueueRepo,
    driveDataService: dataService,
    notesRepo: notesRepo,
    folderRepo: folderRepo,
    tagsRepo: tagsRepo,
  );
  final syncPusher = SyncPusher(
    syncQueueRepo: syncQueueRepo,
    driveDataService: dataService,
    folderRepo: folderRepo,
    notesRepo: notesRepo,
    tagsRepo: tagsRepo,
  );
  return SyncManager(
    configManager: configManager,
    storage: SyncStorage(prefs),
    idManager: ref.watch(
      localIdManagerProvider,
    ), // El mismo que usa tu ConfigManager
    syncPuller: syncPuller,
    syncPusher: syncPusher,
  );
});
