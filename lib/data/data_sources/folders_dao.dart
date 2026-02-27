import 'package:sqflite/sqflite.dart';
import 'package:tag_links/data/database.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/models/search_query.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/utils/paginated_utils.dart';

class FoldersDao {
  Future<Database> get _db async => AppDatabase().database;

  Future<List<Folder>> getByLastUpdate({
    required int? lastUpdate,
    int limit = 500,
  }) async {
    final db = await _db;
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
    final db = await _db;

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
    final db = await _db;

    final result = await db.query(
      'folders',
      where: 'isFavorite = 1',
      orderBy: paginated.orderSql,
      limit: paginated.limit,
      offset: paginated.offset,
    );

    return Future.wait(result.map((f) => _mapFolderWithTags(db, f)));
  }

  /// INSERT
  Future<void> insert(Folder folder) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.insert(
        'folders',
        folder.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (final tag in folder.tags) {
        await txn.insert('folder_tags', {
          'folderId': folder.id,
          'tagId': tag.id,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        // El trigger tr_folder_tags_insert hace el resto
      }
    });
  }

  /// UPDATE
  Future<void> update(Folder folder) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.update(
        'folders',
        folder.toMap(),
        where: 'id = ?',
        whereArgs: [folder.id],
      );

      // Sincronización de tags
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
        await txn.insert('folder_tags', {
          'folderId': folder.id,
          'tagId': tagId,
        });
      }
      for (final tagId in tagsToRemove) {
        await txn.delete(
          'folder_tags',
          where: 'folderId = ? AND tagId = ?',
          whereArgs: [folder.id, tagId],
        );
      }
    });
  }

/// UPSERT ALL
  Future<void> upsertAll(List<Folder> folders) async {
    final db = await _db;
    await db.transaction((txn) async {
      for (final folder in folders) {
        await txn.insert('folders', folder.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

        final currentTagRows = await txn.query('folder_tags', columns: ['tagId'], where: 'folderId = ?', whereArgs: [folder.id]);
        final currentTagIds = currentTagRows.map((e) => e['tagId'] as String).toSet();
        final newTagIds = folder.tags.map((t) => t.id).toSet();

        for (final tagId in newTagIds.difference(currentTagIds)) {
          await txn.insert('folder_tags', {'folderId': folder.id, 'tagId': tagId});
        }
        for (final tagId in currentTagIds.difference(newTagIds)) {
          await txn.delete('folder_tags', where: 'folderId = ? AND tagId = ?', whereArgs: [folder.id, tagId]);
        }
      }
    });
  }

Future<void> deleteByIds(List<String> ids) async {
    if (ids.isEmpty) return;
    final db = await _db;
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.delete('folders', where: 'id IN ($placeholders)', whereArgs: ids);
  }

/// DELETE
  Future<void> delete(String id) async {
    final db = await _db;
    // Gracias al ON DELETE CASCADE en folder_tags, al borrar la carpeta
    // se borran sus relaciones y el trigger descuenta el usageCount.
    await db.delete('folders', where: 'id = ?', whereArgs: [id]);
  }

  /// GET BY ID
  Future<Folder?> getById(String id) async {
    final db = await _db;

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
    final db = await _db;

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
    final db = await _db;

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
  Future<Set<String>> getAllDescendantIds(String folderId) async {
  final db = await _db; // Tu instancia de sqflite
  
  // Esta consulta busca la carpeta inicial y luego se une a sí misma
  // buscando todos los registros cuyo parentId sea el id de la carpeta anterior
  final List<Map<String, dynamic>> results = await db.rawQuery('''
    WITH RECURSIVE family AS (
      -- Caso base: empezar por la carpeta que queremos mover
      SELECT id FROM folders WHERE id = ?
      UNION ALL
      -- Paso recursivo: buscar hijos cuyo parentId sea un ID ya encontrado en 'family'
      SELECT f.id FROM folders f
      INNER JOIN family ON f.parentId = family.id
    )
    SELECT id FROM family;
  ''', [folderId]);

  // Retornamos un Set para que la búsqueda sea O(1) (instantánea)
  return results.map((row) => row['id'] as String).toSet();
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
}
