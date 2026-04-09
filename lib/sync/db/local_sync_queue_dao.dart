import 'package:flutter/rendering.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tag_links/sync/models/archive_info.dart';
import 'package:tag_links/sync/models/archive_item.dart';
import 'package:tag_links/sync/models/local_sync_queue.dart';
import 'package:uuid/uuid.dart';

class LocalSyncQueueDao {
  final String _tableName = 'files';
  final Database _db;
  LocalSyncQueueDao(this._db);

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
  Future<void> upsert(LocalSyncQueue item, {DatabaseExecutor? executor}) async {
    final db = executor ?? _db; // Usa la transacción si existe

    await db.rawInsert(
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
  // En LocalSyncQueueDao
  Future<List<LocalSyncQueue>> getDirtyFiles({int limit = 10}) async {
    final res = await _db.query(
      _tableName,
      where: 'syncStatus IN (?, ?)',
      whereArgs: [SyncStatus.localOnly, SyncStatus.dirty], // Correcto
      orderBy: 'lastUpdate DESC',
      limit: limit,
    );
    return res.map((row) => LocalSyncQueue.fromMap(row)).toList();
  }

  Future<void> markAsDirty(
    String bucketId, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? _db;
    await db.update(
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

  Future<void> updateCount({
    required String id,
    required int count,
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? _db;
    await db.update(
      _tableName,
      {'itemCount': count},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<String> getOrCreateAvailableFileId(
    TypeQueue tableType, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? _db;
    final String tName = tableType.tableName;
    final int limit = (tName == 'deletes')
        ? 2000
        : (tName == 'notes' ? 50 : 200);

    final List<Map<String, dynamic>> res = await db.rawQuery(
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
      await updateCount(id: id, count: realCount, executor: db);

      if (realCount < limit) {
        return id;
      }
    }

    // Si no hay o está lleno, creamos uno nuevo
    final String newLocalId = const Uuid().v4();
    await upsert(
      LocalSyncQueue(
        id: newLocalId,
        driveFileId: null,
        fileName: "${tName}_$newLocalId.json",
        lastUpdate: DateTime.now().millisecondsSinceEpoch,
        type: tName,
        syncStatus: SyncStatus.localOnly, // Es 0, el Pusher lo verá
        itemCount: 1, // Ya contamos el que vas a insertar
      ),
      executor: db,
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

  Future<void> updateMissingDriveIds(
    List<ArchiveItem> items, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? _db;

    // Si usamos el db global y no hay transacción, un Batch es más seguro y rápido
    final batch = db.batch();
    for (var item in items) {
      batch.rawInsert(
        '''
      INSERT INTO files (id, driveFileId, fileName, lastUpdate, type, syncStatus)
      VALUES (?, ?, ?, ?, ?, ?)
      ON CONFLICT(id) DO UPDATE SET
        driveFileId = excluded.driveFileId,
        fileName = excluded.fileName,
        -- 🎯 LA CLAVE: Solo cambiamos a 1 si el registro actual NO es Dirty (2) 
        -- y NO es Local-Only (0). Si ya estaba sucio, se queda sucio.
        syncStatus = CASE 
            WHEN syncStatus IN (0, 2) THEN syncStatus 
            ELSE 1 
        END,
        -- Solo actualizamos el lastUpdate si el remoto es más nuevo
        lastUpdate = MAX(lastUpdate, excluded.lastUpdate)
      ''',
        [
          item.id,
          item.driveFileId,
          item.fileName,
          item.lastUpdate,
          item.type,
          1, // Este es el valor por defecto si es INSERT puro
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
      debugPrint(
        "LocalSyncQueue: Bucket $localId reseteado para recreación en Drive.",
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

  Future<void> decrementCountBy({
    required String fileId,
    required int amount,
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? _db;
    await db.rawUpdate(
      '''
    UPDATE files 
    SET itemCount = MAX(0, itemCount - ?) 
    WHERE id = ?
  ''',
      [amount, fileId],
    );
  }
}
