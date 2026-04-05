import 'package:flutter/widgets.dart';
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

  Future<LocalSyncQueue?> getById(String id) async {
    final result = await _db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return LocalSyncQueue.fromMap(result.first);
  }

  Future<void> upsert(LocalSyncQueue item) async {
    await _db.rawInsert(
      """
    INSERT INTO $_tableName (id, driveFileId, fileName, lastUpdate, type, syncStatus, itemCount)
    VALUES (?, ?, ?, ?, ?, ?, ?)
    ON CONFLICT(id) DO UPDATE SET
      driveFileId = excluded.driveFileId, -- <--- Agregado para que se actualice al recibir de Drive
      fileName = excluded.fileName,
      lastUpdate = excluded.lastUpdate,
      type = excluded.type,
      syncStatus = excluded.syncStatus,
      itemCount = excluded.itemCount
    """,
      [
        item.id,
        item.driveFileId, // <--- Agregado
        item.fileName,
        item.lastUpdate,
        item.type,
        item.syncStatus,
        item.itemCount,
      ],
    );
  }

  Future<List<LocalSyncQueue>> getPendingDownloads(
    ConfigInfo remoteConfig,
  ) async {
    final List<LocalSyncQueue> toDownload = [];

    Future<void> processCategory(
      List<ArchiveItem> remoteItems,
      String tableName,
    ) async {
      for (var remote in remoteItems) {
        final List<Map<String, dynamic>> res = await _db.query(
          _tableName,
          columns: ['lastUpdate'],
          where: "id = ?",
          whereArgs: [remote.id],
        );

        bool needsUpdate =
            res.isEmpty ||
            (remote.lastUpdate > (res.first['lastUpdate'] as int));

        if (needsUpdate) {
          toDownload.add(
            LocalSyncQueue(
              id: remote.id,
              fileName: remote.fileName,
              lastUpdate: remote.lastUpdate,
              type: tableName, // Usamos 'notes', 'folders', 'tags'
              syncStatus: 0,
              itemCount: 0,
            ),
          );
        }
      }
    }

    // Usamos los nombres exactos de las tablas de tu DB
    await processCategory(remoteConfig.archiveInfo.notes, 'notes');
    await processCategory(remoteConfig.archiveInfo.folders, 'folders');
    await processCategory(remoteConfig.archiveInfo.tags, 'tags');

    return toDownload;
  }

  // Método genérico para marcar sincronización en cualquier tabla
  Future<void> updateSyncAt({
    required String tableName, // 'notes', 'folders' o 'tags'
    required List<String> ids,
    required int syncAt,
    required String fileId,
  }) async {
    if (ids.isEmpty) return;
    await _db.update(
      tableName,
      {'syncAt': syncAt, 'fileId': fileId},
      where: "id IN (${ids.map((_) => '?').join(',')})",
      whereArgs: ids,
    );
  }

  Future<void> refreshItemCount(LocalSyncQueue file) async {
    // f.type contiene 'notes', 'folders' o 'tags'
    await _db.rawUpdate(
      '''
      UPDATE files 
      SET itemCount = (SELECT COUNT(*) FROM ${file.type} WHERE fileId = ?)
      WHERE id = ?
      ''',
      [file.id, file.id],
    );
  }

  Future<void> auditAndFixCounts(TypeQueue type) async {
    final String tName = type.tableName;
    await _db.rawUpdate(
      '''
    UPDATE files 
    SET itemCount = (
      SELECT COUNT(*) FROM $tName WHERE $tName.fileId = files.id
    )
    WHERE type = ?
  ''',
      [tName],
    );
  }

  Future<List<LocalSyncQueue>> getWithOutFile() async {
    final raws = await _db.query(_tableName, where: 'fileId IS NULL');
    return raws.map((row) => LocalSyncQueue.fromMap(row)).toList();
  }

  Future<String> getOrCreateAvailableFileId(TypeQueue tableType) async {
    final String tName = tableType.tableName;
    final int limit = (tName == 'notes') ? 50 : 200;

    // 1. Intentamos buscar un "cubo" con espacio
    final List<Map<String, dynamic>> res = await _db.query(
      _tableName,
      columns: ['id'],
      where: 'type = ? AND itemCount < ?',
      whereArgs: [tName, limit],
      orderBy: 'lastUpdate DESC', // Priorizamos el último usado
      limit: 1,
    );

    if (res.isNotEmpty) return res.first['id'] as String;

    // 2. Si no hay, generamos un ID local único e inmutable
    final String newLocalId = const Uuid().v4();

    await upsert(
      LocalSyncQueue(
        id: newLocalId,
        driveFileId: null,
        // El nombre del archivo ahora es único y descriptivo
        fileName: "${tName}_$newLocalId.json",
        lastUpdate: DateTime.now().millisecondsSinceEpoch,
        type: tName,
        syncStatus: 0,
        itemCount: 0,
      ),
    );

    return newLocalId;
  }

  //---------------------------------------------------------------
  // En LocalSyncQueueRepository
Future<List<String>> getDirtyFileIds(TypeQueue type, {int limit = 50}) async {
  final String tableName = type.tableName;

  // Ahora que todas las tablas (notes, folders, tags) tienen 
  // exactamente las mismas columnas gracias a $itemsBaseColumns...
  final sql = '''
    SELECT DISTINCT fileId 
    FROM $tableName 
    WHERE fileId IS NOT NULL 
      AND (
        syncAt IS NULL 
        OR (updatedAt - syncAt) > 1000 
      )
    LIMIT ?
  ''';

  final result = await _db.rawQuery(sql, [limit]);

  // Esto devolverá los UUIDs de los buckets (archivos JSON en Drive)
  // que necesitan ser resubidos porque su contenido local cambió.
  return result.map((row) => row['fileId'] as String).toList();
}

Future<void> markItemsAsSynced({
  required String id,          // Este es el ID de la tabla 'files'
  required TypeQueue type,
  required String fileId,      // Este es el ID que agrupa las notas/carpetas
  required int syncTimestamp,
}) async {
  // 1. ACTUALIZAR EL CONTENIDO (Notas/Carpetas/Tags)
  // Cambiamos 'id = ?' por 'fileId = ?' para limpiar TODO el grupo
  await _db.update(
    type.tableName,
    {'syncAt': syncTimestamp},
    where: 'fileId = ?', 
    whereArgs: [id], // Usamos el id del bucket que es el fileId en las notas
  );

  // 2. ACTUALIZAR EL BUCKET (Tabla 'files')
  await _db.update(
    'files',
    {
      'syncStatus': 1, 
      'lastUpdate': syncTimestamp,
      // 'driveFileId': fileId, // Si necesitas guardar el ID de Drive aquí
    },
    where: 'id = ?',
    whereArgs: [id], // Aquí sí usamos el id porque estamos en la tabla 'files'
  );
}

  /// Solo actualizamos si el driveFileId local es NULL o diferente al de la nube
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

  Future<void> syncBucketsFromArchive(ArchiveInfo archive) async {
    await _db.transaction((txn) async {
      final batch = txn.batch();

      // Función ayudante interna para no repetir código
      void addItemsToBatch(List<ArchiveItem> items, TypeQueue type) {
        for (var item in items) {
          // Solo registramos si tiene driveFileId (si existe en la nube)
          if (item.driveFileId != null) {
            batch.rawInsert(
              '''
            INSERT INTO files (id, driveFileId, fileName, lastUpdate, type, syncStatus, itemCount)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(id) DO UPDATE SET
              driveFileId = excluded.driveFileId,
              lastUpdate = excluded.lastUpdate,
              syncStatus = 1 -- Marcamos como sincronizado porque viene del config remoto
          ''',
              [
                item.id,
                item.driveFileId,
                item.fileName,
                item.lastUpdate,
                type.tableName,
                1, // syncStatus
                0, // itemCount (se actualizará al descargar el json)
              ],
            );
          }
        }
      }

      addItemsToBatch(archive.tags, TypeQueue.tags);
      addItemsToBatch(archive.folders, TypeQueue.folders);
      addItemsToBatch(archive.notes, TypeQueue.notes);

      await batch.commit(noResult: true);
    });
  }

  // En LocalSyncQueueDao
  Future<ArchiveInfo> getLocalArchiveAsRemote() async {
    final List<Map<String, dynamic>> res = await _db.query(_tableName);

    final List<ArchiveItem> tags = [];
    final List<ArchiveItem> folders = [];
    final List<ArchiveItem> notes = [];

    for (var row in res) {
      final item = ArchiveItem(
        id: row['id'] as String,
        driveFileId:
            row['driveFileId'] as String?, // Puede ser null si no se ha subido
        fileName: row['fileName'] as String,
        lastUpdate: row['lastUpdate'] as int,
      );

      // Solo nos interesan para el ArchiveInfo los que ya tienen presencia en Drive
      // o que al menos existen localmente para ser registrados
      if (row['type'] == 'tags') tags.add(item);
      if (row['type'] == 'folders') folders.add(item);
      if (row['type'] == 'notes') notes.add(item);
    }

    return ArchiveInfo(tags: tags, folders: folders, notes: notes, deletes: []);
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
