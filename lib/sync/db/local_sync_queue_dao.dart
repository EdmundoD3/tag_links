import 'package:flutter/rendering.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tag_links/config/local_sync_config.dart';
import 'package:tag_links/sync/models/archive_info.dart';
import 'package:tag_links/sync/models/archive_item.dart';
import 'package:tag_links/sync/models/local_sync_queue.dart';
import 'package:uuid/uuid.dart';

class LocalSyncQueueDao {
  static final String _tableName = 'files';
  final Database _db;
  LocalSyncQueueDao(this._db);

  // 1. OBTENCIÓN BÁSICA
  Future<LocalSyncQueue?> getById(String id) async {
    return await getByIdTxn(executor: _db, id: id);
  }

  static Future<LocalSyncQueue?> getByIdTxn({
    required DatabaseExecutor executor,
    required String id,
  }) async {
    final result = await executor.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isEmpty ? null : LocalSyncQueue.fromMap(result.first);
  }

  Future<void> upsert(LocalSyncQueue item) {
    return LocalSyncQueueDao.upsertTx(_db, item: item);
  }

  // 2. UPSERT DE BUCKETS (Usado en Pull y creación local)
  static Future<void> upsertTx(
    DatabaseExecutor executor, {
    required LocalSyncQueue item,
  }) async {
    await executor.rawInsert(
      """
      INSERT INTO $_tableName (id, driveFileId, fileName, lastUpdate, type, syncStatus, itemCount)
      VALUES (?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(id) DO UPDATE SET
        driveFileId = COALESCE(excluded.driveFileId, driveFileId),
        fileName = excluded.fileName,
        -- 🛡️ PROTECCIÓN: Si el actual es Dirty (2), no lo pises con el status del Pull (1)
        syncStatus = CASE 
            WHEN syncStatus = 2 THEN 2 
            ELSE excluded.syncStatus 
        END,
        -- Solo actualizamos la fecha si la que viene es más nueva
        lastUpdate = MAX(lastUpdate, excluded.lastUpdate),
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
  // En LocalSyncQueueDao
  Future<List<LocalSyncQueue>> getDirtyFiles({int limit = 10}) async {
    final query =
        '''
      SELECT *
      FROM $_tableName
      WHERE syncStatus IN (?, ?)
      ORDER BY lastUpdate DESC
      LIMIT ?
    ''';

    final args = [SyncStatus.localOnly, SyncStatus.dirty, limit];

    final res = await _db.rawQuery(query, args);

    return res.map((row) => LocalSyncQueue.fromMap(row)).toList();
  }

  static Future<void> markAsDirty(
    DatabaseExecutor executor, {
    required String bucketId,
  }) async {
    await executor.update(
      _tableName,
      {
        'syncStatus':
            SyncStatus.dirty, // 🎯 Cambiado de statusDirty a SyncStatus.dirty
        'lastUpdate': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [bucketId],
    );
  }

  static Future<void> markMultipleAsDirty(
    DatabaseExecutor executor, {
    required Iterable<String> bucketIds,
  }) async {
    if (bucketIds.isEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch;

    // Convertimos a lista para asegurar orden y evitar múltiples iteraciones
    final ids = bucketIds.toList();

    // Creamos los placeholders: ?,?,?,...
    final placeholders = List.filled(ids.length, '?').join(',');

    await executor.update(
      _tableName,
      {'syncStatus': SyncStatus.dirty, 'lastUpdate': now},
      // Usamos IN para actualizar todos de un solo golpe
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
  }

  Future<void> markAsSynced(
    String bucketId,
    String driveFileId,
    int timestamp,
  ) async {
    await _db.update(
      _tableName,
      {
        'driveFileId': driveFileId,
        'syncStatus': SyncStatus.synced, // 🎯 Cambiado aquí también
        'lastUpdate': timestamp,
      },
      where: 'id = ?',
      whereArgs: [bucketId],
    );
  }

  Future<void> decreceCount({
    required String fileId,
    DatabaseExecutor? executor,
  }) async {
    try {
      final db = executor ?? _db;

      await db.rawUpdate(
        '''
          UPDATE $_tableName 
          SET itemCount = MAX(0, itemCount - 1), 
              syncStatus = ? 
          WHERE id = ?
        ''',
        [SyncStatus.dirty, fileId], // Usamos la constante 2
      );
    } catch (e) {
      debugPrint('LocalSyncQueueDao.decreceCount ERROR: $e');
    }
  }

  static Future<void> updateCount(
    DatabaseExecutor executor, {
    required String id,
    required int count,
  }) async {
    await executor.update(
      _tableName,
      {'itemCount': count},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<String> getOrCreateAvailableFileId(TypeQueue tableType) async {
    return await LocalSyncQueueDao.getOrCreateAvailableFileIdTxn(
      _db,
      tableType: tableType,
    );
  }

  static Future<String> getOrCreateAvailableFileIdTxn(
    DatabaseExecutor executor, {
    required TypeQueue tableType,
  }) async {
    final String tName = tableType.tableName;
    final int limit = LocalSyncConfig.getLimit(tableType);

    final List<Map<String, dynamic>> res = await executor.rawQuery(
      '''
    SELECT id, (SELECT COUNT(*) FROM $tName WHERE fileId = files.id) as realCount
    FROM $_tableName 
    WHERE type = ?
    ORDER BY lastUpdate DESC
    LIMIT 1
    ''',
      [tName],
    );

    // ✅ CORRECCIÓN: Validar que exista Y que no esté lleno
    // DENTRO DE getOrCreateAvailableFileId
    if (res.isNotEmpty) {
      final int realCount = res.first['realCount'] ?? 0;
      final String id = res.first['id'] as String;

      // ⚠️ ASEGÚRATE de que updateCount reciba el executor (db)
      await LocalSyncQueueDao.updateCount(executor, id: id, count: realCount);

      if (realCount < limit) {
        return id;
      }
    }

    // Si no hay o está lleno, creamos uno nuevo
    final String newLocalId = const Uuid().v4();
    await LocalSyncQueueDao.upsertTx(
      executor,
      item: LocalSyncQueue(
        id: newLocalId,
        driveFileId: null,
        fileName: "${tName}_$newLocalId.json",
        lastUpdate: DateTime.now().millisecondsSinceEpoch,
        type: tName,
        syncStatus: SyncStatus.localOnly, // Es 0, el Pusher lo verá
        itemCount: 1, // Ya contamos el que vas a insertar
      ),
    );

    return newLocalId;
  }

  Future<ArchiveInfo> getLocalArchiveForConfig() async {
    final List<Map<String, dynamic>> res = await _db.query(_tableName);

    final tags = <ArchiveItem>[];
    final folders = <ArchiveItem>[];
    final notes = <ArchiveItem>[];
    final deletes = <ArchiveItem>[]; // 1. Creamos la lista

    for (var row in res) {
      final item = ArchiveItem(
        id: row['id'],
        driveFileId: row['driveFileId'],
        fileName: row['fileName'],
        lastUpdate: row['lastUpdate'],
        type: row['type'],
      );

      final type = row['type'] as String;

      if (type == 'tags') {
        tags.add(item);
      } else if (type == 'folders') {
        folders.add(item);
      } else if (type == 'notes') {
        notes.add(item);
      } else if (type == 'deletes') {
        // 2. Filtramos el tipo deletes
        deletes.add(item);
      }
    }

    // 3. Devolvemos la lista real de borrados
    return ArchiveInfo(
      tags: tags,
      folders: folders,
      notes: notes,
      deletes: deletes,
    );
  }

  Future<void> updateMissingDriveIds(List<ArchiveItem> items) async {
    final batch = _db.batch();
    for (var item in items) {
      batch.rawUpdate(
        '''
      UPDATE files 
      SET driveFileId = ?, 
          fileName = ?
      WHERE id = ? AND driveFileId IS NULL
    ''',
        [item.driveFileId, item.fileName, item.id],
      );

      // Y un insert por si el registro ni siquiera existe
      batch.rawInsert(
        '''
      INSERT OR IGNORE INTO files (id, driveFileId, fileName, lastUpdate, type, syncStatus)
      VALUES (?, ?, ?, ?, ?, ?)
    ''',
        [
          item.id,
          item.driveFileId,
          item.fileName,
          item.lastUpdate,
          item.type,
          SyncStatus.synced,
        ],
      );
    }
    await batch.commit(noResult: true);
  }

  // En LocalSyncQueueDao / Repository
  Future<void> clearDriveId(String localId) async {
    await _db.update(
      'files',
      {
        'driveFileId': null,
        'syncStatus': SyncStatus.localOnly,
      }, // Al ser null, el Pusher lo recreará
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  /// Limpia la referencia de Drive cuando un archivo da 404 (no encontrado).
  /// Al poner driveFileId en null y el status en dirty, el Pusher lo recreará.
  Future<void> markAsDeletedInDrive(String localId) async {
    try {
      await _db.update(
        'files',
        {
          'driveFileId': null, // 🚩 Eliminamos el ID roto de Google Drive
          'syncStatus':
              SyncStatus.dirty, // 🚩 Marcamos como "pendiente de subir"
          'lastUpdate': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [localId],
      );
    } catch (e) {
      debugPrint("Error en markAsDeletedInDrive: $e");
    }
  }

  /// Recalcula el itemCount de todos los buckets basándose en la realidad de las tablas
  Future<void> recomputeAllItemCounts() async {
    await _db.transaction((txn) async {
      await txn.execute('''
      UPDATE files 
      SET itemCount = CASE 
        WHEN type = 'notes' THEN (SELECT COUNT(*) FROM notes WHERE fileId = files.id)
        WHEN type = 'folders' THEN (SELECT COUNT(*) FROM folders WHERE fileId = files.id)
        WHEN type = 'tags' THEN (SELECT COUNT(*) FROM tags WHERE fileId = files.id)
        WHEN type = 'deletes' THEN (SELECT COUNT(*) FROM deletes WHERE fileId = files.id)
        ELSE 0
      END
    ''');
    });
  }

  static Future<void> decrementCountBy(
    DatabaseExecutor executor, {
    required String fileId,
    required int amount,
  }) async {
    await executor.rawUpdate(
      '''
    UPDATE files 
    SET itemCount = MAX(0, itemCount - ?) 
    WHERE id = ?
  ''',
      [amount, fileId],
    );
  }
/// Asegura que un bucket exista para evitar errores de Foreign Key (SQLITE_CONSTRAINT_FOREIGNKEY).
  /// Si el ID no existe, crea un placeholder con status 'synced' para que el Pusher lo ignore
  /// hasta que llegue el archivo real desde el Pull.
  static Future<void> ensureExistenceTxn(
    DatabaseExecutor executor, {
    required String id,
    required TypeQueue type,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    await executor.rawInsert(
      '''
      INSERT OR IGNORE INTO $_tableName 
      (id, driveFileId, fileName, lastUpdate, type, syncStatus, itemCount)
      VALUES (?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        id,
        null,                               // driveFileId: Desconocido aún
        _generateName(type: type, id: id),  // Nombre consistente: "tipo_uuid.json"
        now,                                // Timestamp de creación del placeholder
        type.tableName,                    // El nombre de la tabla destino ('tags', 'notes', etc)
        SyncStatus.synced,                  // Status 1: Evita que el Pusher intente subirlo
        0,                                  // itemCount: Empezamos en 0
      ],
    );
  }

  static String _generateName({required TypeQueue type, required String id}) {
    return "${type.tableName}_$id.json";
  }
}
