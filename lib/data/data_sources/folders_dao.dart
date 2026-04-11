import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tag_links/data/data_sources/deleted_dao.dart';
import 'package:tag_links/data/data_sources/folder_tags_dao.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/models/search_query.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/sync/db/local_sync_queue_dao.dart';
import 'package:tag_links/sync/models/local_sync_queue.dart';
import 'package:tag_links/utils/paginated_utils.dart';

class FoldersDao {
  final Database _db;
  final DeletedDao _deletedDao;

  FoldersDao({
    required Database db,
    required LocalSyncQueueDao syncDao,
    required DeletedDao deletedDao,
  }) : _db = db,
       _deletedDao = deletedDao;

  /// BY LAST UPDATE

  Future<List<Folder>> getByLastUpdate({
    required int? lastUpdate,
    int limit = 500,
  }) async {
    final db = _db;
    final hasLastUpdate = lastUpdate != null;
    final where = hasLastUpdate ? "WHERE updatedAt > ?" : "";
    final args = hasLastUpdate ? [lastUpdate, limit] : [limit];
    final sql =
        '''
        SELECT *
        FROM folders
        $where
        ORDER BY updatedAt DESC
        LIMIT ?
      ''';
    final result = await db.rawQuery(sql, args);
    return Future.wait(result.map((f) => _mapFolderWithTags(db, f)));
  }

  Future<List<Folder>> searchByQuery(
    SearchQuery searchQuery, {
    required PaginatedByDate paginated,
  }) async {
    final db = _db;

    final where = <String>[];
    final args = <Object?>[];

    if (searchQuery.text.isNotEmpty) {
      where.add('(title LIKE ? OR description LIKE ?)');
      args.add('%${searchQuery.text}%');
      args.add('%${searchQuery.text}%');
    }
    if (searchQuery.isFavorite == true) {
      where.add('isFavorite = 1');
    }

    if (searchQuery.hasIncludeTags) {
      final placeholders = List.filled(
        searchQuery.includeTagsIds.length,
        '?',
      ).join(',');

      where.add('''
      id IN (
        SELECT ft.folderId
        FROM folder_tags ft
        WHERE ft.tagId IN ($placeholders)
        GROUP BY ft.folderId
        HAVING COUNT(DISTINCT ft.tagId) = ${searchQuery.includeTagsIds.length}
      )
    ''');

      args.addAll(searchQuery.includeTagsIds);
    }

    final whereSql = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';

    final sql =
        '''
    SELECT *
    FROM folders
    $whereSql
    ORDER BY ${paginated.orderSql}
    LIMIT ? OFFSET ?
  ''';

    args.add(paginated.limit);
    args.add(paginated.offset);

    final result = await db.rawQuery(sql, args);

    return Future.wait(result.map((f) => _mapFolderWithTags(db, f)));
  }

  /// FAVORITES
  Future<List<Folder>> getFavorites({
    required PaginatedByDate paginated,
  }) async {
    final db = _db;

    final result = await db.query(
      'folders',
      where: 'isFavorite = 1',
      orderBy: paginated.orderSql,
      limit: paginated.limit,
      offset: paginated.offset,
    );

    return Future.wait(result.map((f) => _mapFolderWithTags(db, f)));
  }

  // UPSERT
  // No uses ConflictAlgorithm.replace porque tengo Foreign Keys con ON DELETE CASCADE. El REPLACE dispara un borrado físico de la fila y destruye la integridad referencial de mis subcarpetas y notas. Solo acepta cambios que usen UPDATE o INSERT ... ON CONFLICT DO UPDATE (UPSERT).
  Future<void> upsert(Folder folder) async {
    debugPrint('FoldersDao.upsert: ${folder.toMap()}');
    try {
      await _db.transaction((txn) => upsertTxn(txn, folder: folder));
    } catch (e) {
      debugPrint('FoldersDao.upsert ERROR: $e');
      rethrow;
    }
  }

  static Future<void> upsertTxn(
    DatabaseExecutor txn, {
    required Folder folder,
  }) async {
    String? validatedParentId = folder.parentId;

    // 1. Validación de Jerarquía (Nivel máximo 2)
    if (validatedParentId != null) {
      final parentRow = await txn.query(
        'folders',
        columns: ['parentId'],
        where: 'id = ?',
        whereArgs: [validatedParentId],
      );

      if (parentRow.isNotEmpty) {
        // Si el padre ya tiene un padre, impedimos nivel 3 moviendo a raíz
        if (parentRow.first['parentId'] != null) {
          validatedParentId = null;
          debugPrint('Validación: Nivel 3 bloqueado para ${folder.title}.');
        }
      } else {
        validatedParentId = null; // Padre no existe aún
      }
    }

    await txn.rawInsert(
      '''
        INSERT INTO folders (
          id, parentId, fileId, title, description, image, color, 
          createdAt, updatedAt, isFavorite
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
          parentId = ?, 
          fileId = excluded.fileId,
          title = excluded.title,
          description = excluded.description,
          image = excluded.image,
          color = excluded.color,
          updatedAt = excluded.updatedAt,
          isFavorite = excluded.isFavorite
        WHERE excluded.updatedAt >= updatedAt
        ''',
      [
        folder.id, validatedParentId, folder.fileId, folder.title,
        folder.description, folder.image, folder.color,
        folder.createdAt, folder.updatedAt,
        folder.isFavorite ? 1 : 0,
        validatedParentId, // Para el SET parentId = ?
      ],
    );

    // 3. Sincronizar Etiquetas (Relación many-to-many)
    final currentTagRows = await txn.query(
      'folder_tags',
      columns: ['tagId'],
      where: 'folderId = ?',
      whereArgs: [folder.id],
    );

    final currentTagIds = currentTagRows
        .map((e) => e['tagId'] as String)
        .toSet();
    final newTagIds = folder.tags.map((t) => t.id).toSet();

    for (final tagId in newTagIds.difference(currentTagIds)) {
      await FolderTagsDao.upsert(txn, folderId: folder.id, tagId: tagId);
    }
    for (final tagId in currentTagIds.difference(newTagIds)) {
      await FolderTagsDao.delete(txn, folderId: folder.id, tagId: tagId);
    }

    // 🚀 4. NOTIFICAR AL BUCKET: Marcar como Dirty (syncStatus = 2)
    await LocalSyncQueueDao.markAsDirty(txn, bucketId: folder.fileId);
  }

  Future<void> upsertAll(List<Folder> rawFolders) async {
    if (rawFolders.isEmpty) return;
    final dirtysIds = await _deletedDao.extractDirtyIdsByType(
      rawFolders.map((e) => e.id).toList(),
      DeletedType.folder,
    );
    final folders = rawFolders.where((e) => !dirtysIds.contains(e.id)).toList();

    if (folders.isEmpty) return;

    // Ordenamos: Primero carpetas raíz para que las subcarpetas encuentren su FK
    final sortedFolders = [
      ...folders.where((f) => f.parentId == null),
      ...folders.where((f) => f.parentId != null),
    ];

    await _db.transaction((txn) async {
      final batch = txn.batch();

      for (final folder in sortedFolders) {
        batch.rawInsert(
          '''
        INSERT INTO folders (
          id, parentId, fileId, title, description, image, color, 
          createdAt, updatedAt, isFavorite
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
          parentId = excluded.parentId,
          fileId = excluded.fileId,
          title = excluded.title,
          description = excluded.description,
          image = excluded.image,
          color = excluded.color,
          updatedAt = excluded.updatedAt,
          isFavorite = excluded.isFavorite
        WHERE excluded.updatedAt >= updatedAt
        ''',
          [
            folder.id,
            folder.parentId,
            folder.fileId,
            folder.title,
            folder.description,
            folder.image,
            folder.color,
            folder.createdAt,
            folder.updatedAt,
            folder.isFavorite ? 1 : 0,
          ],
        );

        // B. Sincronizar etiquetas (Limpieza rápida en batch)
        FolderTagsDao.deleteBatch(batch, folderId: folder.id);
        for (final tag in folder.tags) {
          FolderTagsDao.upsertBatch(batch, folderId: folder.id, tagId: tag.id);
        }
      }

      await batch.commit(noResult: true);
      // Al ser PULL (upsertAll), no marcamos el bucket como sucio.
    });
  }

  /// DELETE RECURSIVO DE CARPETAS (Optimizado para Sincronización y Conteos)
  Future<void> delete(String id) async {
    try {
      await _db.transaction((txn) async {
        // 1. Obtener todos los IDs de carpetas descendientes (incluyendo la actual)
        final idsToDelete = await getAllDescendantIds(id, executor: txn);
        if (idsToDelete.isEmpty) return;

        final placeholders = List.filled(idsToDelete.length, '?').join(',');
        final idsList = idsToDelete.toList();

        // 2. CAPTURA PRE-BORRADO: Obtenemos datos de las carpetas
        final List<Map<String, dynamic>> affectedFolders = await txn.query(
          'folders',
          columns: ['id', 'fileId'],
          where: 'id IN ($placeholders)',
          whereArgs: idsList,
        );

        // 3. CAPTURA PRE-BORRADO: Obtenemos datos de las notas que morirán por CASCADE
        final List<Map<String, dynamic>> affectedNotes = await txn.query(
          'notes',
          columns: ['id', 'fileId'],
          where: 'folderId IN ($placeholders)',
          whereArgs: idsList,
        );

        // Mapas para acumular cuánto restar a cada bucket y un Set para ensuciarlos
        final Map<String, int> countsToDecrement = {};
        final Set<String> bucketsToDirty = {};

        // 4. REGISTRO DE CARPETAS
        for (final row in affectedFolders) {
          final fId = row['id'] as String;
          final bId = row['fileId'] as String;

          bucketsToDirty.add(bId);
          countsToDecrement[bId] = (countsToDecrement[bId] ?? 0) + 1;

          await DeletedDao.saveId(txn, id: fId, type: DeletedType.folder);
        }

        // 5. REGISTRO DE NOTAS
        for (final row in affectedNotes) {
          final nId = row['id'] as String;
          final bId = row['fileId'] as String;

          bucketsToDirty.add(bId);
          countsToDecrement[bId] = (countsToDecrement[bId] ?? 0) + 1;

          await DeletedDao.saveId(txn, id: nId, type: DeletedType.note);
        }

        // 6. BORRADO FÍSICO: Aquí el ON DELETE CASCADE elimina notas y subcarpetas localmente
        await txn.delete(
          'folders',
          where: 'id IN ($placeholders)',
          whereArgs: idsList,
        );

        // 7. ACTUALIZACIÓN MASIVA DE BUCKETS (Sincronización y Conteos)
        for (final bId in bucketsToDirty) {
          // Marcamos como sucio para que el Pusher suba la nueva versión del bucket
          await LocalSyncQueueDao.markAsDirty(txn, bucketId: bId);

          // Restamos el total acumulado (carpetas + notas) de este bucket específico
          final totalADescontar = countsToDecrement[bId] ?? 0;
          if (totalADescontar > 0) {
            await LocalSyncQueueDao.decrementCountBy(txn,
              fileId: bId,
              amount: totalADescontar,
            );
          }
        }

        debugPrint(
          "FoldersDao.delete: Recursión terminada. Buckets afectados: ${bucketsToDirty.length}",
        );
      });
    } catch (e) {
      debugPrint('FoldersDao.delete ERROR: $e');
      rethrow;
    }
  }

  /// GET BY ID
  Future<Folder?> getById(String id) async {
    final db = _db;

    final result = await db.query(
      'folders',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return _mapFolderWithTags(db, result.first);
  }

  /// ROOT FOLDERS
  Future<List<Folder>> getRootFolders({
    required PaginatedByDate paginated,
  }) async {
    try {
      final result = await _db.query(
        'folders',
        where: 'parentId IS NULL',
        orderBy: paginated.orderSql,
        limit: paginated.limit,
        offset: paginated.offset,
      );

      return Future.wait(result.map((f) => _mapFolderWithTags(_db, f)));
    } catch (e) {
      debugPrint('FoldersDao.getRootFolders ERROR: $e');
      return [];
    }
  }

  /// BY PARENT
  Future<List<Folder>> getByParentId(
    String parentId, {
    required PaginatedByDate paginated,
  }) async {
    final db = _db;

    final result = await db.query(
      'folders',
      where: 'parentId = ?',
      whereArgs: [parentId],
      orderBy: paginated.orderSql,
      limit: paginated.limit,
      offset: paginated.offset,
    );

    return Future.wait(result.map((f) => _mapFolderWithTags(db, f)));
  }

  // Cambia a private si solo se usa internamente o mantén público
  Future<Set<String>> getAllDescendantIds(
    String folderId, {
    Transaction? executor,
  }) async {
    final db = executor ?? _db;

    final List<Map<String, dynamic>> results = await db.rawQuery(
      '''
      WITH RECURSIVE family AS (
        SELECT id FROM folders WHERE id = ?
        UNION ALL
        SELECT f.id FROM folders f
        INNER JOIN family ON f.parentId = family.id
      )
      SELECT id FROM family;
      ''',
      [folderId],
    );

    return results.map((row) => row['id'] as String).toSet();
  }

  Future<bool> hasChildren(String folderId) async {
    // Usamos SELECT COUNT para que la DB solo nos devuelva un número
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as total FROM folders WHERE parentId = ? LIMIT 1',
      [folderId],
    );

    // sqflite devuelve una lista de mapas, extraemos el primer entero
    final int? count = Sqflite.firstIntValue(result);
    return (count ?? 0) > 0;
  }

  // ------------- move ---------------
  Future<void> moveAndFlatten(
    Folder folder,
    String? newParentId, {
    bool toRoot = true,
  }) async {
    debugPrint('FoldersDao.moveAndFlatten: ${folder.toMap()}');
    final now = DateTime.now().millisecondsSinceEpoch;
    final childrenNewParentId = toRoot ? null : folder.parentId;

    await _db.transaction((txn) async {
      // 1. Obtener todos los fileIds que van a ser afectados ANTES de moverlos
      // Buscamos el fileId de la carpeta padre y de todos sus hijos directos.
      final List<Map<String, dynamic>> result = await txn.rawQuery(
        '''
      SELECT DISTINCT fileId FROM folders 
      WHERE id = ? OR parentId = ?
    ''',
        [folder.id, folder.id],
      );
      debugPrint('FoldersDao.moveAndFlatten: DISTINCT fileId $result');

      final fileIdsAfectados = result
          .map((row) => row['fileId'] as String)
          .where((id) => id.isNotEmpty)
          .toSet(); // Set para evitar duplicados

      // 2. "Subir" a los hijos (Flatten)
      await txn.update(
        'folders',
        {'parentId': childrenNewParentId, 'updatedAt': now},
        where: 'parentId = ?',
        whereArgs: [folder.id],
      );

      // 3. Mover la carpeta padre (Move)
      final rowsPadre = await txn.update(
        'folders',
        {'parentId': newParentId, 'updatedAt': now},
        where: 'id = ?',
        whereArgs: [folder.id],
      );

      if (rowsPadre == 0) throw Exception('Error: Carpeta no encontrada');
      debugPrint("se movieron ${fileIdsAfectados.length} buckets");

      // 🚀 4. Marcar todos los Buckets como Dirty de golpe
      await LocalSyncQueueDao.markMultipleAsDirty(
        txn,
        bucketIds: fileIdsAfectados,
      );
    });
  }

  /// MAP FOLDER + TAGS
  Future<Folder> _mapFolderWithTags(
    Database db,
    Map<String, dynamic> map,
  ) async {
    // 1. Obtenemos las etiquetas asociadas a esta carpeta
    final tags = await _getTagsByFolderId(db, map['id'] as String);
    // 2. Construimos el objeto Folder mapeando tipos de SQLite a Dart
    return Folder(
      id: map['id'] as String,
      parentId: map['parentId'] as String?,
      fileId:
          map['fileId'] as String, // Crucial para la sincronización por buckets
      title: map['title'] as String? ?? 'Carpeta sin título',
      description: map['description'] as String?,
      image: map['image'] as String?,
      color: map['color'] as String?,
      tags: tags,
      createdAt: map['createdAt'] as int,
      updatedAt: map['updatedAt'] as int,
      isFavorite: (map['isFavorite'] == 1 || map['isFavorite'] == true),
    );
  }

  Future<List<Tag>> _getTagsByFolderId(Database db, String folderId) async {
    final result = await db.rawQuery(
      '''
      SELECT t.*
      FROM tags t
      INNER JOIN folder_tags ft ON ft.tagId = t.id
      WHERE ft.folderId = ?
    ''',
      [folderId],
    );

    return result.map(Tag.fromMap).toList();
  }

  // --------------------- SYNC section ----------------------//
  Future<List<Folder>> getByFileId(String fileId) async {
    final result = await _db.query(
      'folders',
      where: 'fileId = ?',
      whereArgs: [fileId],
    );
    return Future.wait(result.map((f) => _mapFolderWithTags(_db, f)));
  }

  Future<void> serverDeleteByIds(List<String> ids) async {
    if (ids.isEmpty) return;
    try {
      final placeholders = List.filled(ids.length, '?').join(',');
      await _db.delete(
        'folders',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
    } catch (e) {
      debugPrint('FoldersDao.serverDeleteByIds ERROR: $e');
    }
  }
}
