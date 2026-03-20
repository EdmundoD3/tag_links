import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tag_links/data/data_sources/deleted_dao.dart';
import 'package:tag_links/data/data_sources/folder_tags_dao.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/models/search_query.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/utils/paginated_utils.dart';

class FoldersDao {
  final Database _db;
  final FolderTagsDao _folderTagsDao;
  final DeletedFoldersDao _deletedFoldersDao;
  FoldersDao({
    required Database db,
    required FolderTagsDao folderTagsDao,
    required DeletedFoldersDao deletedFoldersDao,
  }) : _db = db,
       _folderTagsDao = folderTagsDao,
       _deletedFoldersDao = deletedFoldersDao;

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
    final db = _db;

    await db.transaction((txn) async {
      // 1. UPSERT de la carpeta usando SQL puro (Evita el DELETE del REPLACE)
      await txn.rawInsert(
        '''
      INSERT INTO folders (
        id, parentId, title, description, image, color, 
        createdAt, updatedAt, syncAt, isFavorite
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(id) DO UPDATE SET
        parentId = excluded.parentId,
        title = excluded.title,
        description = excluded.description,
        image = excluded.image,
        color = excluded.color,
        updatedAt = excluded.updatedAt,
        syncAt = excluded.syncAt,
        isFavorite = excluded.isFavorite
    ''',
        [
          folder.id,
          folder.parentId,
          folder.title,
          folder.description,
          folder.image,
          folder.color,
          folder.createdAt.millisecondsSinceEpoch,
          folder.updatedAt.millisecondsSinceEpoch,
          folder.syncAt?.millisecondsSinceEpoch,
          folder.isFavorite ? 1 : 0,
        ],
      );

      // 2. Sincronizar Etiquetas (folder_tags)
      // El resto de la lógica de etiquetas se mantiene igual, ya que no afecta a la jerarquía
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
      final tagsToAdd = newTagIds.difference(currentTagIds);
      final tagsToRemove = currentTagIds.difference(newTagIds);

      for (final tagId in tagsToAdd) {
        await _folderTagsDao.upsert(
          folderId: folder.id,
          tagId: tagId,
          executor: txn,
        );
      }

      for (final tagId in tagsToRemove) {
        await _folderTagsDao.delete(
          folderId: folder.id,
          tagId: tagId,
          executor: txn,
        );
      }
    });
  }

  Future<void> upsertAll(List<Folder> folders) async {
    if (folders.isEmpty) return;

    await _db.transaction((txn) async {
      final batch = txn.batch();

      for (final folder in folders) {
        // 1. Upsert de la Carpeta (Usa rawInsert con ON CONFLICT para el syncAt inteligente)
        batch.rawInsert(
          '''
        INSERT INTO folders (id, parentId, title, description, image, color, createdAt, updatedAt, syncAt, isFavorite)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
          parentId = excluded.parentId,
          title = excluded.title,
          description = excluded.description,
          image = excluded.image,
          color = excluded.color,
          updatedAt = excluded.updatedAt,
          isFavorite = excluded.isFavorite
        WHERE excluded.updatedAt > updatedAt
      ''',
          [
            folder.id,
            folder.parentId,
            folder.title,
            folder.description,
            folder.image,
            folder.color,
            folder.createdAt.millisecondsSinceEpoch,
            folder.updatedAt.millisecondsSinceEpoch,
            folder.syncAt?.millisecondsSinceEpoch,
            folder.isFavorite ? 1 : 0,
          ],
        );

        // 2. Tags de la carpeta (Borrar y re-insertar en batch es eficiente)
        _folderTagsDao.deleteBatch(batch, folderId: folder.id);
        for (final tag in folder.tags) {
          _folderTagsDao.upsertBatch(batch, folderId: folder.id, tagId: tag.id);
        }
      }

      await batch.commit(noResult: true);
    });
  }

  Future<void> serverDeleteByIds(List<String> ids) async {
    if (ids.isEmpty) return;
    final db = _db;
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.delete('folders', where: 'id IN ($placeholders)', whereArgs: ids);
  }

  /// DELETE
  Future<void> delete(String id) async {
    await _db.transaction((txn) async {
      // 1. Obtener todos los hijos recursivamente (incluyendo el ID actual)
      // Nota: Modifica getAllDescendantIds para que acepte un 'executor' (txn)
      final idsToDelete = await getAllDescendantIds(id, executor: txn);

      // 2. Verificar cuáles de esos IDs ya conocen el servidor
      final placeholders = List.filled(idsToDelete.length, '?').join(',');
      final synchronized = await txn.query(
        'folders',
        columns: ['id'],
        where: 'id IN ($placeholders) AND syncAt IS NOT NULL',
        whereArgs: idsToDelete.toList(),
      );

      // 3. Registrar los borrados para el servidor
      for (final row in synchronized) {
        await _deletedFoldersDao.saveId(row['id'] as String, executor: txn);
      }

      // 4. Borrado físico (El ON DELETE CASCADE limpiará las tablas hijas)
      await txn.delete(
        'folders',
        where: 'id IN ($placeholders)',
        whereArgs: idsToDelete.toList(),
      );
    });
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
    final db = _db;

    final result = await db.query(
      'folders',
      where: 'parentId IS NULL',
      orderBy: paginated.orderSql,
      limit: paginated.limit,
      offset: paginated.offset,
    );

    return Future.wait(result.map((f) => _mapFolderWithTags(db, f)));
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
  final now = DateTime.now().millisecondsSinceEpoch;
  // Si toRoot es true, los hijos van a null (Raíz)
  // Si no, van al parentId que tenía la carpeta (suben un nivel)
  final childrenNewParentId = toRoot ? null : folder.parentId;

  await _db.transaction((txn) async {
    // 1. "Subir" a los hijos
    await txn.update(
      'folders',
      {
        'parentId': childrenNewParentId,
        'updatedAt': now,
      },
      where: 'parentId = ?',
      whereArgs: [folder.id],
    );

    // 2. Mover la carpeta padre
    final rowsPadre = await txn.update(
      'folders',
      {'parentId': newParentId, 'updatedAt': now},
      where: 'id = ?',
      whereArgs: [folder.id],
    );

    if (rowsPadre == 0) throw Exception('Error: Carpeta no encontrada');
  });
}

  /// MAP FOLDER + TAGS
  Future<Folder> _mapFolderWithTags(
    Database db,
    Map<String, dynamic> map,
  ) async {
    final tags = await _getTagsByFolderId(db, map['id']);

    return Folder(
      id: map['id'],
      parentId: map['parentId'],
      title: map['title'],
      description: map['description'],
      image: map['image'],
      color: map['color'],
      tags: tags,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      syncAt: map['syncAt'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['syncAt']),
      isFavorite: map['isFavorite'] == 1,
    );
  }

  /// GET TAGS BY FOLDER
  Future<List<Tag>> _getTagsByFolderId(Database db, String folderId) async {
    final result = await db.rawQuery(
      '''
      SELECT t.id, t.name, t.isFavorite, t.usageCount
      FROM tags t
      INNER JOIN folder_tags ft ON ft.tagId = t.id
      WHERE ft.folderId = ?
    ''',
      [folderId],
    );

    return result.map(Tag.fromMap).toList();
  }

  // --------------------- SYNC section ----------------------//

  Future<List<Folder>> getForSync({int limit = 200}) async {
    final sql = '''
    SELECT *
    FROM folders
    WHERE syncAt IS NULL OR syncAt < updatedAt
    ORDER BY updatedAt DESC
    LIMIT ?
  ''';

    final result = await _db.rawQuery(sql, [limit]);

    return Future.wait(result.map((f) => _mapFolderWithTags(_db, f)));
  }

  Future<bool> updateSyncAt(List<String> ids, int syncAt) async {
    if (ids.isEmpty) return false;

    final db = _db;

    final placeholders = List.filled(ids.length, '?').join(',');

    final sql =
        '''
    UPDATE folders
    SET syncAt = ?
    WHERE id IN ($placeholders)
  ''';

    final success = await db.rawUpdate(sql, [syncAt, ...ids]);
    return success >= ids.length;
  }
}
