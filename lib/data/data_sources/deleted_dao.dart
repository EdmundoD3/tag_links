import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tag_links/data/database.dart';
import 'package:tag_links/sync/db/local_sync_queue_dao.dart';
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
    DeletedType type,
    {DatabaseExecutor? executor,}
  ) async {
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

    Future<void> deleteIds(List<String> ids) async {
    if (ids.isEmpty) return;
    final placeholders = List.filled(ids.length, '?').join(',');
    await _db.delete(
      _tableName,
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
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
