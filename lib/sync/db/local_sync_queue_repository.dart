import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/data/database.dart';
import 'package:tag_links/sync/db/local_sync_queue_dao.dart';
import 'package:tag_links/sync/models/archive_info.dart';
import 'package:tag_links/sync/models/config_info.dart';
import 'package:tag_links/sync/models/local_sync_queue.dart';

final localSyncQueueRepositoryProvider = Provider<LocalSyncQueueRepository>((
  ref,
) {
  final db = ref.watch(databaseProvider);
  return LocalSyncQueueRepository(LocalSyncQueueDao(db));
});

class LocalSyncQueueRepository {
  final LocalSyncQueueDao _dao;
  LocalSyncQueueRepository(this._dao);

  // --- MÉTODOS DE BUCKETS (CRUD) ---

  Future<LocalSyncQueue?> getById(String id) async {
    return _dao.getById(id);
  }

  Future<void> upsert(LocalSyncQueue item) async {
    return _dao.upsert(item);
  }

  // --- LÓGICA DE SINCRONIZACIÓN (PUSH/PULL) ---

  /// Marca los archivos sucios para poder enviarlos al servidor
  Future<void> markAsDirty(String id) {
    return _dao.markAsDirty(id);
  }

  /// PUSH: Obtiene los buckets que están en estado Dirty o LocalOnly para subirlos a Drive
  Future<List<LocalSyncQueue>> getDirtyFiles({int limit = 10}) async {
    return _dao.getDirtyFiles(limit: limit);
  }

  /// CIERRE DE CICLO: Marca un bucket como sincronizado tras subirlo con éxito
  Future<void> markAsSynced({
    required String bucketId,
    required String driveFileId,
    required int timestamp,
  }) async {
    return _dao.markAsSynced(bucketId, driveFileId, timestamp);
  }

  // --- GESTIÓN DE ESPACIO ---

  /// Obtiene un ID de bucket que tenga espacio disponible o crea uno nuevo
  Future<String> getOrCreateAvailableFileId(TypeQueue tableType) async {
    try {
      return await _dao.getOrCreateAvailableFileId(tableType);
    } catch (e) {
      debugPrint(
        "LocalSyncQueueRepository.getOrCreateAvailableFileId Error: $e",
      );
      rethrow;
    }
  }

  // --- INTEGRACIÓN CON CONFIG.JSON ---

  /// Genera el ArchiveInfo local necesario para actualizar el config.json en Drive
  Future<ArchiveInfo> getLocalArchiveForConfig() async {
    return _dao.getLocalArchiveForConfig();
  }

  /// Vincula IDs locales con DriveFileIds remotos (Reconciliación)
  Future<void> reconcileDriveIds(ArchiveInfo remoteArchive) async {
    // 1. Aplanamos todos los items remotos (Notas, Carpetas, Etiquetas)
    final allRemoteItems = [
      ...remoteArchive.notes,
      ...remoteArchive.folders,
      ...remoteArchive.tags,
      // IMPORTANTE: No olvides incluir los buckets de borrado
      ...remoteArchive.deletes,
    ];

    if (allRemoteItems.isEmpty) return;

    // 2. Actualización masiva en la tabla de sincronización local
    // Esto vincula el UUID local con el driveFileId real de Google Drive
    await _dao.updateMissingDriveIds(allRemoteItems);
  }

  Future<void> clearDriveId(String localId) async {
    await _dao.clearDriveId(localId);
  }
}
