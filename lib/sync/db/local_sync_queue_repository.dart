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
  Future<LocalSyncQueue> getById(String id) async {
    return _dao.getById(id);
  }

  Future<void> upsert(LocalSyncQueue item) async {
    return _dao.upsert(item);
  }

  Future<List<LocalSyncQueue>> getPendingDownloads(
    ConfigInfo remoteConfig,
  ) async {
    return _dao.getPendingDownloads(remoteConfig);
  }

  // Método genérico para marcar sincronización en cualquier tabla
  Future<void> updateSyncAt({
    required String tableName, // 'notes', 'folders' o 'tags'
    required List<String> ids,
    required int syncAt,
    required String fileId,
  }) async {
    return _dao.updateSyncAt(
      tableName: tableName,
      ids: ids,
      syncAt: syncAt,
      fileId: fileId,
    );
  }

  Future<void> refreshItemCount(LocalSyncQueue file) async {
    return _dao.refreshItemCount(file);
  }

  Future<void> auditAndFixCounts(TypeQueue type) async {
    return _dao.auditAndFixCounts(type);
  }

  Future<String> getOrCreateAvailableFileId(TypeQueue tableType) async {
    try {
      return _dao.getOrCreateAvailableFileId(tableType);
    } catch (e) {
      debugPrint("LocalSyncQueueRepository.getOrCreateAvailableFileId Error: $e");
      rethrow;
    }
  }
  Future<List<String>> getDirtyFileIds(TypeQueue type, {int limit = 50}) async {
    return _dao.getDirtyFileIds(type, limit: limit);
  }
  Future<void> markItemsAsSynced({
    required String id,
    required String fileId,
    required TypeQueue type,
    required int syncTimestamp,
  }) async {
    return _dao.markItemsAsSynced(
      id: id,
      type: type,
      fileId: fileId,
      syncTimestamp: syncTimestamp,
    );
  }
  /// Sincroniza los IDs locales con los IDs de Drive obtenidos del config.json
  Future<void> reconcileDriveIds(ArchiveInfo remoteArchive) async {
    // 1. Aplanamos todos los items remotos en una sola lista para procesar
    final allRemoteItems = [
      ...remoteArchive.notes,
      ...remoteArchive.folders,
      ...remoteArchive.tags,
    ];

    if (allRemoteItems.isEmpty) return;

    // 2. Ejecutamos una actualización masiva (o por lotes)
    await _dao.updateMissingDriveIds(allRemoteItems);
  }
}
