import 'package:flutter/rendering.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tag_links/data/data_sources/deleted_dao.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/sync/db/local_sync_queue_dao.dart';
import 'package:tag_links/sync/models/local_sync_queue.dart';
import 'package:tag_links/utils/paginated_utils.dart';

class TagsDao {
  final String _tableName = 'tags';
  final Database _db;
  final DeletedDao _deletedDao;
  final LocalSyncQueueDao _syncDao;

  TagsDao(this._db, this._deletedDao, this._syncDao);

  Future<Tag?> insertIfNotExist(Tag tag) async {
    try {
      final tagToInsert = tag.ensureForInsert();

      // 🎯 1. Usamos 'title' en lugar de 'name'
      final idResult = await _db.insert(
        _tableName,
        tagToInsert.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );

      if (idResult > 0) {
        await LocalSyncQueueDao.markAsDirty(_db, bucketId: tag.fileId);
        return tagToInsert;
      }

      // 🎯 2. Cambiado a getByExactlyTitle
      return await getByExactlyTitle(tag.title);
    } catch (e) {
      debugPrint('TagsDao.insertIfNotExist error: ${e.toString()}');
      return null;
    }
  }

  Future<void> update(Tag tag) async {
    await _db.transaction((txn) async {
      await txn.update(
        _tableName,
        tag.toMap(),
        where: 'id = ?',
        whereArgs: [tag.id],
      );

      await LocalSyncQueueDao.markAsDirty(txn, bucketId: tag.fileId);
    });
  }

  Future<void> delete(Tag tag) async {
    await _db.transaction((txn) async {
      await txn.delete(_tableName, where: 'id = ?', whereArgs: [tag.id]);
      await DeletedDao.saveId(txn, id: tag.id, type: DeletedType.tag);
      await LocalSyncQueueDao.markAsDirty(txn, bucketId: tag.fileId);
      await _syncDao.decreceCount(fileId: tag.fileId, executor: txn);
    });
  }

  Future<Tag?> getById(String id) async {
    final result = await _db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return null;

    return Tag.fromMap(result.first);
  }

  Future<List<Tag>> getAll({required PaginatedByUsage paginated}) async {
    const String customOrder =
        'isFavorite DESC, usageCount DESC, updatedAt DESC';

    final result = await _db.query(
      _tableName,
      orderBy: customOrder,
      limit: paginated.limit,
      offset: paginated.offset,
    );
    return result.map(Tag.fromMap).toList();
  }

  // 🎯 3. Cambiado a getByTitle
  Future<List<Tag>> getByTitle(
    String title, {
    required PaginatedByUsage paginated,
  }) async {
    final result = await _db.query(
      _tableName,
      where: 'title LIKE ?', // 🎯 Columna title
      whereArgs: ['%$title%'],
      orderBy: paginated.orderSql,
      limit: paginated.limit,
    );
    return result.map(Tag.fromMap).toList();
  }

  // 🎯 4. Cambiado a getByExactlyTitle
  Future<Tag?> getByExactlyTitle(String title) async {
    try {
      final cleanTitle = title.trim();

      final result = await _db.query(
        _tableName,
        where: 'title = ?', // 🎯 Columna title
        whereArgs: [cleanTitle],
        limit: 1,
      );

      if (result.isEmpty) return null;
      return Tag.fromMap(result.first);
    } catch (e) {
      debugPrint("Error: TagsDao.getByExactlyTitle: $e");
      return null;
    }
  }

  Future<List<Tag>> getByFileId(String fileId) async {
    final result = await _db.query(
      _tableName,
      where: 'fileId = ?',
      whereArgs: [fileId],
    );
    return result.map(Tag.fromMap).toList();
  }

  Future<void> upsert(Tag tag) async {
    try {
      await _db.transaction((txn) async {
        await txn.rawInsert(
          '''
          INSERT INTO tags (id, title, fileId, isFavorite, usageCount, updatedAt)
          VALUES (?, ?, ?, ?, ?, ?)
          ON CONFLICT(id) DO UPDATE SET
            title = excluded.title,
            fileId = excluded.fileId,
            isFavorite = excluded.isFavorite,
            usageCount = excluded.usageCount,
            updatedAt = excluded.updatedAt
          ''',
          [
            tag.id,
            tag.title,
            tag.fileId,
            tag.isFavorite ? 1 : 0,
            tag.usageCount,
            tag.updatedAt,
          ],
        );
        await LocalSyncQueueDao.markAsDirty(txn, bucketId: tag.fileId);
      });
    } catch (e) {
      debugPrint('TagsDao.upsert error: $e');
    }
  }

  Future<void> upsertAll(List<Tag> tags) async {
    if (tags.isEmpty) return;

    try {
      await _db.transaction((txn) async {
        final List<String> incomingIds = tags.map((e) => e.id).toList();
        final Set<String> dirtyDeletedIds = await DeletedDao
          .extractDirtyIdsByTypeTxn(txn,ids: incomingIds,type: DeletedType.tag);

        final batch = txn.batch();

        for (final tag in tags) {
          if (dirtyDeletedIds.contains(tag.id)) {
            debugPrint("🚫 Ignorando Tag resucitado: ${tag.title}");
            continue;
          }
          TagsDao.upsertAllBatch(tag, batch);
        }

        await batch.commit(noResult: true);
      });
    } catch (e) {
      debugPrint('TagsDao.upsertAll error: ${e.toString()}');
      rethrow;
    }
  }

  static void upsertAllBatch(Tag tag, Batch batch) {
    final tagToUpdate = tag.ensureForInsert();

    batch.rawInsert(
      '''
    INSERT INTO tags (id, title, fileId, isFavorite, usageCount, updatedAt)
    VALUES (?, ?, ?, ?, ?, ?)
    ON CONFLICT(id) DO UPDATE SET
      title = excluded.title, -- 🎯 Antes 'name'
      fileId = excluded.fileId,
      isFavorite = excluded.isFavorite,
      usageCount = excluded.usageCount,
      updatedAt = excluded.updatedAt
    WHERE excluded.updatedAt > updatedAt 
    ''',
      [
        tagToUpdate.id,
        tagToUpdate.title,
        tagToUpdate.fileId,
        tagToUpdate.isFavorite ? 1 : 0,
        tagToUpdate.usageCount,
        tagToUpdate.updatedAt,
      ],
    );
  }

  Future<void> serverDeleteByIds(List<String> ids) async {
    if (ids.isEmpty) return;
    final placeholders = List.filled(ids.length, '?').join(',');

    try {
      await _db.delete(
        _tableName,
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
    } catch (e) {
      debugPrint('TagsDao.serverDeleteByIds ERROR: $e');
    }
  }

static Future<void> ensureTagsDependencies(
    Transaction txn,
    List<Tag> tags,
  ) async {
    if (tags.isEmpty) return;

    // 1. Obtener IDs únicos para verificar si han sido borrados
    final allTagIds = tags.map((t) => t.id).toList();
    
    // 🛡️ FILTRO DE SEGURIDAD: Consultamos cuáles de estos tags están en la "lista negra" de borrados
    final deletedTagIds = await DeletedDao.extractDirtyIdsByTypeTxn(
      txn,
      ids: allTagIds,
      type: DeletedType.tag,
    );

    // Solo procesamos los tags que NO han sido borrados localmente
    final activeTags = tags.where((t) => !deletedTagIds.contains(t.id)).toSet().toList();
    if (activeTags.isEmpty) return;

    // 2. Extraer todos los fileIds únicos de los tags activos
    final fileIds = activeTags.map((t) => t.fileId).whereType<String>().toSet();

    for (final fId in fileIds) {
      // Aseguramos que el bucket (archivo) existe para los tags válidos
      await LocalSyncQueueDao.ensureExistenceTxn(
        txn,
        id: fId,
        type: TypeQueue.tags,
      );
    }

    // 3. Insertamos o ignoramos los tags que pasaron el filtro
    for (final tag in activeTags) {
      await TagsDao.insertOrIgnoreAllTxn(txn, tag);
    }
  }

  static Future<void> insertOrIgnoreAllTxn(Transaction txn, Tag tag) async {
    // Usamos INSERT OR IGNORE para que si el ID existe, no haga nada.
    // Esto protege la etiqueta si ya fue insertada por otra carpeta en el mismo pull.
    await txn.rawInsert(
      '''
    INSERT OR IGNORE INTO tags (id, title, fileId, isFavorite, usageCount, updatedAt)
    VALUES (?, ?, ?, ?, ?, ?)
    ''',
      [
        tag.id,
        tag.title,
        tag.fileId,
        tag.isFavorite ? 1 : 0,
        tag.usageCount,
        tag.updatedAt,
      ],
    );
  }

  Future<List<DeletedData>> getBatchByFileId(String fileId) =>
      _deletedDao.getBatchByFileIdAndType(fileId, DeletedType.tag);
}
