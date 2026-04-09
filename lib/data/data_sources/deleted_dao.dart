import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tag_links/data/database.dart';
import 'package:tag_links/sync/db/local_sync_queue_dao.dart';
import 'package:tag_links/sync/models/delete_file.dart';
import 'package:tag_links/sync/models/local_sync_queue.dart';

final deletedDaoProvider = Provider<DeletedDao>((ref) {
  final db = ref.read(databaseProvider);
  return DeletedDao(db);
});

class DeletedDao {
  final Database _db;
  final LocalSyncQueueDao _syncDao;
  final String _tableName = 'deletes';

  DeletedDao(this._db) : _syncDao = LocalSyncQueueDao(_db);

  /// Guarda el borrado usando el Enum para garantizar integridad
  Future<void> saveId(
    String id,
    DeletedType type, {
    required DatabaseExecutor executor,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final exist = await executor.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (exist.isNotEmpty) return;

    final bucketId = await _syncDao.getOrCreateAvailableFileId(
      TypeQueue.deletes,
      executor: executor,
    );

    await executor.insert(_tableName, {
      'id': id,
      'type': type.name, // 🎯 Guardamos el string del enum
      'fileId': bucketId,
      'deletedAt': now,
    });

    await _syncDao.markAsDirty(bucketId, executor: executor);
  }

  /// Busqueda filtrada por Bucket y Tipo
  Future<List<DeletedData>> getBatchByFileIdAndType(
    String fileId,
    DeletedType type,
  ) async {
    final result = await _db.query(
      _tableName,
      where: 'fileId = ? AND type = ?',
      whereArgs: [fileId, type.name], // 🎯 Filtro seguro
      orderBy: 'deletedAt ASC',
    );
    return result.map(DeletedData.fromRaw).toList();
  }

  /// Extraer IDs sucios filtrando por tipo
  Future<Set<String>> extractDirtyIdsByType(
    List<String> ids,
    DeletedType type, {
    DatabaseExecutor? executor,
  }) async {
    if (ids.isEmpty) return {};
    final db = executor ?? _db;
    final placeholders = List.filled(ids.length, '?').join(',');
    final result = await db.query(
      _tableName,
      columns: ['id'],
      where: 'type = ? AND id IN ($placeholders)',
      whereArgs: [type.name, ...ids], // 🎯 Comparación robusta
    );

    return result.map((e) => e['id'] as String).toSet();
  }

  Future<void> cleanOldDeletes({int days = 15}) async {
    final int threshold = DateTime.now()
        .subtract(Duration(days: days))
        .millisecondsSinceEpoch;

    await _db.transaction((txn) async {
      // 1. Buscamos qué archivos (buckets) se verán afectados por la limpieza
      final List<Map<String, dynamic>> affectedBuckets = await txn.rawQuery(
        '''
      SELECT DISTINCT fileId FROM deletes WHERE deletedAt < ?
    ''',
        [threshold],
      );

      if (affectedBuckets.isEmpty) return;

      // 2. Borramos los registros viejos
      await txn.delete(
        'deletes',
        where: 'deletedAt < ?',
        whereArgs: [threshold],
      );

      // 3. Actualizamos los archivos afectados
      for (var row in affectedBuckets) {
        final String fId = row['fileId'] as String;

        // Aquí usamos COUNT(*) real para actualizar itemCount
        // Y marcamos como DIRTY para que el Pusher suba la versión "limpia" a Drive
        await txn.rawUpdate(
          '''
            UPDATE files 
            SET 
              itemCount = (SELECT COUNT(*) FROM deletes WHERE fileId = ?),
              syncStatus = ?
            WHERE id = ?
          ''',
          [fId, SyncStatus.dirty, fId],
        );
      }
    });

    debugPrint(
      "Mantenimiento: IDs de borrado de más de $days días eliminados.",
    );
  }

Future<void> upsertAllFromRemote(DeleteFile remoteFile) async {
  // 1. Aplanamos todas las listas
  final List<Map<String, dynamic>> rows = [];

  // Validamos que el fileId no sea nulo o vacío para evitar errores de FK
  if (remoteFile.fileId.isEmpty) {
    debugPrint("❌ DeletedDao: remoteFile.fileId está vacío. Abortando upsert.");
    return;
  }

  for (var item in remoteFile.notes) {
    rows.add({'id': item.id, 'type': DeletedType.note.name, 'fileId': remoteFile.fileId, 'deletedAt': item.deletedAt});
  }
  for (var item in remoteFile.folders) {
    rows.add({'id': item.id, 'type': DeletedType.folder.name, 'fileId': remoteFile.fileId, 'deletedAt': item.deletedAt});
  }
  for (var item in remoteFile.tags) {
    rows.add({'id': item.id, 'type': DeletedType.tag.name, 'fileId': remoteFile.fileId, 'deletedAt': item.deletedAt});
  }

  if (rows.isEmpty) return;

  await _db.transaction((txn) async {
    // --- 🎯 PASO CRÍTICO: Asegurar la Foreign Key ---
    final bucketExist = await txn.query(
      'files',
      where: 'id = ?',
      whereArgs: [remoteFile.fileId],
    );

    if (bucketExist.isEmpty) {
      // Usar exactamente los nombres de tu tabla 'files'
      await txn.insert('files', {
        'id': remoteFile.fileId,
        'driveFileId': remoteFile.fileId, // Asumimos que es el mismo si viene de la nube
        'fileName': 'deletes_${remoteFile.id}.json',
        'type': TypeQueue.deletes.name,
        'itemCount': rows.length,
        'syncStatus': SyncStatus.synced, 
        'lastUpdate': DateTime.now().millisecondsSinceEpoch,
      });
    }

    // 2. Ejecutamos la inserción masiva
    final batch = txn.batch();
    for (var row in rows) {
      batch.insert(
        'deletes',
        row,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  });

  debugPrint("DeletesRepo: 💾 ${rows.length} registros sincronizados localmente.");
}
}

class DeletedData {
  final String id;
  final int deletedAt;
  final String fileId;

  DeletedData({
    required this.id,
    required this.deletedAt,
    required this.fileId,
  });
  Map<String, Object> toMap() => {
    'id': id,
    'deletedAt': deletedAt,
    'fileId': fileId,
  };
  factory DeletedData.fromRaw(Map<String, Object?> raw) {
    return DeletedData(
      id: raw['id'] as String,
      deletedAt: raw['deletedAt'] as int,
      fileId: raw['fileId'] as String,
    );
  }
}

enum DeletedType {
  note,
  folder,
  tag;

  // Para guardar en la DB de forma consistente
  String get name => toString().split('.').last;

  static DeletedType fromString(String value) {
    return DeletedType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DeletedType.note,
    );
  }
}

final deletedTable = '''
CREATE TABLE IF NOT EXISTS deletes (
    id TEXT PRIMARY KEY,       -- El ID del objeto borrado
    type TEXT NOT NULL,        -- 'note', 'folder', o 'tag'
    fileId TEXT NOT NULL,      -- A qué bucket de Drive pertenece
    deletedAt INTEGER NOT NULL,
    FOREIGN KEY (fileId) REFERENCES files (id) ON DELETE CASCADE
);
''';
