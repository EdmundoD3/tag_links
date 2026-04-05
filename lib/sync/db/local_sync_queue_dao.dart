import 'package:sqflite/sqflite.dart';
import 'package:tag_links/sync/models/archive_info.dart';
import 'package:tag_links/sync/models/archive_item.dart';
import 'package:tag_links/sync/models/config_info.dart';
import 'package:tag_links/sync/models/local_sync_queue.dart';
import 'package:uuid/uuid.dart';

class LocalSyncQueueDao {
  final String _tableName = 'files';
  final Database _db;
  LocalSyncQueueDao(this._db);

  // --- CONSTANTES DE ESTADO (Para evitar números mágicos) ---
  static const int statusLocalOnly = 0; // Nuevo bucket, nunca subido
  static const int statusSynced = 1; // En espejo con Drive
  static const int statusDirty = 2; // Modificado localmente, necesita subir
  static const int statusError = 3; // Falló la última sincronización

  // 1. OBTENCIÓN BÁSICA
  Future<LocalSyncQueue?> getById(String id) async {
    final result = await _db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isEmpty ? null : LocalSyncQueue.fromMap(result.first);
  }

  // 2. UPSERT DE BUCKETS (Usado en Pull y creación local)
  Future<void> upsert(LocalSyncQueue item) async {
    await _db.rawInsert(
      """
      INSERT INTO $_tableName (id, driveFileId, fileName, lastUpdate, type, syncStatus, itemCount)
      VALUES (?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(id) DO UPDATE SET
        driveFileId = COALESCE(excluded.driveFileId, driveFileId),
        fileName = excluded.fileName,
        lastUpdate = excluded.lastUpdate,
        type = excluded.type,
        syncStatus = excluded.syncStatus,
        itemCount = excluded.itemCount
      """,
      [
        item.id,
        item.driveFileId,
        item.fileName,
        item.lastUpdate,
        item.type,
        item.syncStatus,
        item.itemCount,
      ],
    );
  }

  // 3. PUSH: Obtener archivos que necesitan subirse
  // ¡Súper simple ahora! Sin cálculos de fechas.
  Future<List<LocalSyncQueue>> getDirtyFiles({int limit = 10}) async {
    final res = await _db.query(
      _tableName,
      where: 'syncStatus IN (?, ?)',
      whereArgs: [statusLocalOnly, statusDirty],
      orderBy: 'lastUpdate DESC',
      limit: limit,
    );
    return res.map((row) => LocalSyncQueue.fromMap(row)).toList();
  }

  // 4. PULL: Comparar con ArchiveInfo de Drive para ver qué descargar
  Future<List<LocalSyncQueue>> getPendingDownloads(
    ConfigInfo remoteConfig,
  ) async {
    final List<LocalSyncQueue> toDownload = [];

    Future<void> processCategory(
      List<ArchiveItem> remoteItems,
      String type,
    ) async {
      for (var remote in remoteItems) {
        final List<Map<String, dynamic>> res = await _db.query(
          _tableName,
          columns: ['lastUpdate', 'driveFileId'],
          where: "id = ?",
          whereArgs: [remote.id],
        );

        // Descargamos si:
        // A) No existe localmente
        // B) La versión de Drive es más reciente (lastUpdate mayor)
        bool needsDownload =
            res.isEmpty ||
            (remote.lastUpdate > (res.first['lastUpdate'] as int));

        if (needsDownload) {
          toDownload.add(
            LocalSyncQueue(
              id: remote.id,
              driveFileId: remote.driveFileId,
              fileName: remote.fileName,
              lastUpdate: remote.lastUpdate,
              type: type,
              syncStatus:
                  statusSynced, // Al descargar, asumimos que viene limpio
              itemCount: 0,
            ),
          );
        }
      }
    }

    await processCategory(remoteConfig.archiveInfo.notes, 'notes');
    await processCategory(remoteConfig.archiveInfo.folders, 'folders');
    await processCategory(remoteConfig.archiveInfo.tags, 'tags');
    return toDownload;
  }

  // 5. GESTIÓN DE BUCKETS (Creación y asignación)
  Future<String> getOrCreateAvailableFileId(TypeQueue tableType) async {
    final String tName = tableType.tableName;
    final int limit = (tName == 'notes') ? 50 : 200;

    final List<Map<String, dynamic>> res = await _db.query(
      _tableName,
      columns: ['id'],
      where: 'type = ? AND itemCount < ?',
      whereArgs: [tName, limit],
      orderBy: 'lastUpdate DESC',
      limit: 1,
    );

    if (res.isNotEmpty) return res.first['id'] as String;

    final String newLocalId = const Uuid().v4();
    await upsert(
      LocalSyncQueue(
        id: newLocalId,
        driveFileId: null,
        fileName: "${tName}_$newLocalId.json",
        lastUpdate: DateTime.now().millisecondsSinceEpoch,
        type: tName,
        syncStatus: statusLocalOnly,
        itemCount: 0,
      ),
    );
    return newLocalId;
  }

  // 6. CIERRE DE CICLO: Marcar como sincronizado tras éxito en Drive
  Future<void> markAsSynced(
    String bucketId,
    String driveFileId,
    int timestamp,
  ) async {
    await _db.update(
      _tableName,
      {
        'driveFileId': driveFileId,
        'syncStatus': statusSynced,
        'lastUpdate': timestamp,
      },
      where: 'id = ?',
      whereArgs: [bucketId],
    );
  }

  // 7. ENSUCIAR: Marcar bucket como sucio tras edición local
  Future<void> markAsDirty(
    String bucketId, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? _db; // Usa la transacción si existe
    await db.update(
      _tableName,
      {
        'syncStatus': statusDirty,
        'lastUpdate': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [bucketId],
    );
  }

  // 8. AUDITORÍA: Actualizar conteos de items por bucket
  Future<void> refreshAllCounts() async {
    for (var type in ['notes', 'folders', 'tags']) {
      await _db.rawUpdate(
        '''
        UPDATE $_tableName 
        SET itemCount = (SELECT COUNT(*) FROM $type WHERE fileId = $_tableName.id)
        WHERE type = ?
      ''',
        [type],
      );
    }
  }

  // 9. ARCHIVE: Generar ArchiveInfo para subir a config.json
  Future<ArchiveInfo> getLocalArchiveForConfig() async {
    final List<Map<String, dynamic>> res = await _db.query(_tableName);

    final tags = <ArchiveItem>[];
    final folders = <ArchiveItem>[];
    final notes = <ArchiveItem>[];

    for (var row in res) {
      final item = ArchiveItem(
        id: row['id'],
        driveFileId: row['driveFileId'],
        fileName: row['fileName'],
        lastUpdate: row['lastUpdate'],
      );
      if (row['type'] == 'tags') {
        tags.add(item);
      } else if (row['type'] == 'folders') {
        folders.add(item);
      } else if (row['type'] == 'notes') {
        notes.add(item);
      }
    }
    return ArchiveInfo(tags: tags, folders: folders, notes: notes, deletes: []);
  }

  Future<void> updateMissingDriveIds(List<ArchiveItem> items) async {
    await _db.transaction((txn) async {
      for (var item in items) {
        await txn.update(
          'files',
          {
            'driveFileId': item.driveFileId,
            'syncStatus':
                1, // Si ya tiene DriveID y viene de la nube, está sincronizado
          },
          // Solo actualizamos si encontramos el ID local y el driveFileId actual no coincide
          where: 'id = ? AND (driveFileId IS NULL OR driveFileId != ?)',
          whereArgs: [item.id, item.driveFileId],
        );
      }
    });
  }

  // En LocalSyncQueueDao / Repository
  Future<void> clearDriveId(String localId) async {
    await _db.update(
      'files',
      {
        'driveFileId': null,
        'syncStatus': 0,
      }, // Al ser null, el Pusher lo recreará
      where: 'id = ?',
      whereArgs: [localId],
    );
  }
}
