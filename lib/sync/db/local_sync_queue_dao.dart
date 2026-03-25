import 'package:sqflite/sqflite.dart';
import 'package:tag_links/sync/models/archive_info.dart';
import 'package:tag_links/sync/models/archive_item.dart';
import 'package:tag_links/sync/models/config_info.dart';
import 'package:tag_links/sync/models/local_sync_queue.dart';

class LocalSyncQueueDao {
  final String _tableName = 'files';
  final Database _db;
  LocalSyncQueueDao(this._db);
  Future<void> upsert(LocalSyncQueue item) async {
    await _db.rawInsert(
      """
      INSERT INTO $_tableName (id, fileName, lastUpdate, type, syncStatus)
      VALUES (?, ?, ?, ?, ?)
      ON CONFLICT(id) DO UPDATE SET
        fileName = excluded.fileName,
        lastUpdate = excluded.lastUpdate,
        type = excluded.type,
        syncStatus = excluded.syncStatus
      """,
      [item.id, item.fileName, item.lastUpdate, item.type, item.syncStatus],
    );
  }

  /// Obtiene los archivos que necesitan ser descargados o actualizados.
  /// Mapea los ArchiveItem del ConfigInfo a objetos LocalSyncQueue
  /// para que el SyncService sepa exactamente qué tipo de dato procesar.
  Future<List<LocalSyncQueue>> getPendingDownloads(
    ConfigInfo remoteConfig,
  ) async {
    final List<LocalSyncQueue> toDownload = [];

    // Helper para procesar cada categoría y asignar su tipo
    Future<void> processCategory(
      List<ArchiveItem> remoteItems,
      String type,
    ) async {
      for (var remote in remoteItems) {
        // Consultamos la versión local de este ID
        final List<Map<String, dynamic>> res = await _db.query(
          _tableName,
          columns: ['lastUpdate'],
          where: "id = ?",
          whereArgs: [remote.id],
        );

        bool needsUpdate = false;
        if (res.isEmpty) {
          needsUpdate = true; // No existe localmente
        } else {
          final localUpdate = res.first['lastUpdate'] as int;
          if (remote.lastUpdate > localUpdate) {
            needsUpdate = true; // El servidor tiene algo más nuevo
          }
        }

        if (needsUpdate) {
          toDownload.add(
            LocalSyncQueue(
              id: remote.id,
              fileName: remote.fileName,
              lastUpdate: remote.lastUpdate,
              type: type, // 'note', 'folder' o 'tag'
              syncStatus: 0, // Pendiente de procesar descarga
            ),
          );
        }
      }
    }

    // Procesamos cada lista del ArchiveInfo por separado para inyectar el tipo correcto
    await processCategory(remoteConfig.archiveInfo.notes, 'note');
    await processCategory(remoteConfig.archiveInfo.folders, 'folder');
    await processCategory(remoteConfig.archiveInfo.tags, 'tag');

    return toDownload;
  }

  Future<LocalSyncQueue?> getByName(String name) async {
    final raw = await _db.query(
      _tableName,
      where: 'fileName = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (raw.isEmpty) return null;
    return LocalSyncQueue.fromMap(raw.first);
  }
}
