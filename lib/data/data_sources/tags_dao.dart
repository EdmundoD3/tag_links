import 'package:flutter/rendering.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tag_links/data/data_sources/deleted_dao.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/sync/db/local_sync_queue_dao.dart';
import 'package:tag_links/utils/paginated_utils.dart';

class TagsDao {
  final String _tableName = 'tags';
  final Database _db;
  final DeletedDao _deletedDao;
  final LocalSyncQueueDao _syncDao;
  TagsDao(this._db, this._deletedDao, this._syncDao);

  Future<Tag?> insertIfNotExist(Tag tag) async {
    try {
      // 1. Aseguramos que tenga un ID válido antes de intentar nada
      final tagToInsert = tag.ensureForInsert();

      // 2. Intentamos el INSERT con IGNORE.
      // Si el 'name' ya existe (UNIQUE), no hará nada y devolverá 0 o el ID existente.
      final idResult = await _db.insert(
        _tableName,
        tagToInsert.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );

      // 3. Si idResult es > 0, significa que se insertó correctamente.
      if (idResult > 0) {
        return tagToInsert;
      }

      // 4. Si no se insertó (porque ya existía el nombre), lo buscamos y lo devolvemos.
      // Así garantizamos que la app siempre use el ID que ya está en la DB.
      return await getByExactlyName(tag.name);
    } catch (e) {
      debugPrint('TagsDao.upsert error: ${e.toString()}');
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
      await _syncDao.markAsDirty(tag.fileId, executor: txn);
    });
  }

  Future<void> delete(String id) async {
    _db.transaction((tx) async {
      await tx.delete(_tableName, where: 'id = ?', whereArgs: [id]);
      await _deletedDao.saveId(id, DeletedType.tag, executor: tx);
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
    final result = await _db.query(
      _tableName,
      orderBy: paginated.orderSql,
      limit: paginated.limit,
      offset: paginated.offset,
    );

    return result.map(Tag.fromMap).toList();
  }

  Future<List<Tag>> getByName(
    String name, {
    required PaginatedByUsage paginated,
  }) async {
    final result = await _db.query(
      _tableName,
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
      orderBy: paginated.orderSql,
      limit: paginated.limit,
    );
    return result.map(Tag.fromMap).toList();
  }

  Future<Tag?> getByExactlyName(String name) async {
    try {
      // Asegúrate de que el nombre no vaya con espacios accidentales
      final cleanName = name.trim();

      final result = await _db.query(
        _tableName,
        where: 'name = ?',
        whereArgs: [cleanName],
        limit: 1,
      );

      debugPrint("DAO: Query finalizada. Resultados: ${result.length}");

      if (result.isEmpty) return null;
      return Tag.fromMap(result.first);
    } catch (e) {
      debugPrint("Error: TagsDao.getByExactlyName: $e");
      return null;
    }
  }

  // -------------- SYNC section --------------
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
      final tagToUpdate = tag.ensureForInsert();
      await _db.rawInsert(
        '''
      INSERT INTO tags (id, name, fileId, isFavorite, usageCount, updatedAt)
      VALUES (?, ?, ?, ?, ?, ?) -- 6 columnas, 6 signos '?'
      ON CONFLICT(id) DO UPDATE SET
        name = excluded.name,
        fileId = excluded.fileId,
        isFavorite = excluded.isFavorite,
        usageCount = excluded.usageCount,
        updatedAt = excluded.updatedAt
    ''',
        [
          tagToUpdate.id,
          tagToUpdate.name,
          tagToUpdate.fileId,
          tagToUpdate.isFavorite ? 1 : 0,
          tagToUpdate.usageCount,
          tagToUpdate.updatedAt,
        ],
      );
    } catch (e) {
      debugPrint('TagsDao.upsert error: $e');
    }
  }

  Future<void> upsertAll(List<Tag> tags) async {
    if (tags.isEmpty) return;

    try {
      // Usamos await para que la función espere a que la transacción termine
      await _db.transaction((txn) async {
        // 1. Obtenemos los IDs que el usuario borró localmente y aún no sube a Drive
        // Usamos el 'txn' para que la lectura sea exacta en este microsegundo
        final List<String> incomingIds = tags.map((e) => e.id).toList();
        final Set<String> dirtyDeletedIds = await _deletedDao
            .extractDirtyIdsByType(incomingIds, DeletedType.tag, executor: txn);

        final batch = txn.batch();

        for (final tag in tags) {
          // 2. Filtro de exclusión: Si está en la papelera local, lo ignoramos
          if (dirtyDeletedIds.contains(tag.id)) {
            debugPrint("🚫 Ignorando Tag resucitado: ${tag.name}");
            continue;
          }

          // 3. Procesamos el Batch
          _upsertAllBatch(tag, batch);
        }

        await batch.commit(noResult: true);
      });
    } catch (e) {
      debugPrint('TagsDao.upsertAll error: ${e.toString()}');
      rethrow; // Es mejor relanzar para que el SyncManager sepa que falló
    }
  }

  void _upsertAllBatch(Tag tag, Batch batch) {
    // Aseguramos que el objeto sea válido para inserción
    final tagToUpdate = tag.ensureForInsert();

    batch.rawInsert(
      '''
    INSERT INTO tags (id, name, fileId, isFavorite, usageCount, updatedAt)
    VALUES (?, ?, ?, ?, ?, ?)
    ON CONFLICT(id) DO UPDATE SET
      name = excluded.name,
      fileId = excluded.fileId,
      isFavorite = excluded.isFavorite,
      usageCount = excluded.usageCount,
      updatedAt = excluded.updatedAt
    WHERE excluded.updatedAt > updatedAt 
    ''',
      [
        tagToUpdate.id,
        tagToUpdate.name,
        tagToUpdate.fileId,
        tagToUpdate.isFavorite ? 1 : 0,
        tagToUpdate.usageCount,
        tagToUpdate.updatedAt,
      ],
    );
  }

  Future<void> serverDeleteByIds(List<String> ids) async {
    if (ids.isEmpty) return;
    await _deletedDao.deleteIds(ids);
    final placeholders = List.filled(ids.length, '?').join(',');

    try {
      await _db.delete('tags', where: 'id IN ($placeholders)', whereArgs: ids);
    } catch (e) {
      debugPrint('TagsDao.serverDeleteByIds ERROR: $e');
    }
  }

  Future<List<DeletedData>> getBatchByFileId(String fileId) =>
      _deletedDao.getBatchByFileIdAndType(fileId, DeletedType.tag);
  Future<void> clearDeletedTags(List<String> ids) => _deletedDao.deleteIds(ids);
}
