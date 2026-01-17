import 'package:sqflite/sqflite.dart';
import 'package:tag_links/data/database.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/models/search_query.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/utils/paginated_utils.dart';

class FoldersDao {
  Future<Database> get _db async => AppDatabase().database;

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

  Future<PaginatedByDate> getPageForNoteId(
    Note note, {
    required PaginatedByDate paginated,
  }) async {
    final field = _buildOrderField(paginated);
    final whereClause = _buildOrderWhereClause(paginated);

    final query =
        '''
          SELECT COUNT(*) as count
          FROM notes
          WHERE folderId = ?
            AND $whereClause (
              SELECT $field FROM notes WHERE id = ?
            );
        ''';

    final args = [note.folderId, note.id];

    final result = await _db.then((db) => db.rawQuery(query, args));

    final rawCount = result.first['count'];
    final count = (rawCount as num?)?.toInt() ?? 0;

    final page = (count ~/ paginated.pageSize) + 1;

    return PaginatedByDate(
      page: page < 1 ? 1 : page,
      pageSize: paginated.pageSize,
      order: paginated.order,
    );
  }

  /// INSERT
  Future<void> insert(Folder folder) async {
    final db = await _db;

    await db.transaction((txn) async {
      await txn.insert('folders', folder.toMap());

      for (final tag in folder.tags) {
        await txn.insert('folder_tags', {
          'folderId': folder.id,
          'tagId': tag.id,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);

        // 🔥 Incrementar uso del tag
        await txn.rawUpdate(
          '''
          UPDATE tags
          SET usageCount = usageCount + 1
          WHERE id = ?
        ''',
          [tag.id],
        );
      }
    });
  }

  Future<void> update(Folder folder) async {
    final db = await _db;

    await db.transaction((txn) async {
      // 1️⃣ Update datos base
      await txn.update(
        'folders',
        folder.toMap(),
        where: 'id = ?',
        whereArgs: [folder.id],
      );

      // 2️⃣ Obtener tags actuales
      final currentTagRows = await txn.rawQuery(
        '''
      SELECT tagId FROM folder_tags
      WHERE folderId = ?
    ''',
        [folder.id],
      );

      final currentTagIds = currentTagRows
          .map((e) => e['tagId'] as String)
          .toSet();

      final newTagIds = folder.tags.map((t) => t.id).toSet();

      // 3️⃣ Calcular diferencias
      final tagsToAdd = newTagIds.difference(currentTagIds);
      final tagsToRemove = currentTagIds.difference(newTagIds);

      // 4️⃣ Agregar nuevos tags
      for (final tagId in tagsToAdd) {
        await txn.insert('folder_tags', {
          'folderId': folder.id,
          'tagId': tagId,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);

        await txn.rawUpdate(
          '''
        UPDATE tags
        SET usageCount = usageCount + 1
        WHERE id = ?
      ''',
          [tagId],
        );
      }

      // 5️⃣ Eliminar tags removidos
      for (final tagId in tagsToRemove) {
        await txn.delete(
          'folder_tags',
          where: 'folderId = ? AND tagId = ?',
          whereArgs: [folder.id, tagId],
        );

        await txn.rawUpdate(
          '''
        UPDATE tags
        SET usageCount = MAX(usageCount - 1, 0)
        WHERE id = ?
      ''',
          [tagId],
        );
      }
    });
  }

  /// DELETE
  Future<void> delete(String id) async {
    final db = await _db;

    await db.transaction((txn) async {
      // obtener tags usados antes de borrar
      final tagRows = await txn.rawQuery(
        '''
        SELECT tagId FROM folder_tags WHERE folderId = ?
      ''',
        [id],
      );

      await txn.delete('folders', where: 'id = ?', whereArgs: [id]);

      for (final row in tagRows) {
        await txn.rawUpdate(
          '''
          UPDATE tags
          SET usageCount = MAX(usageCount - 1, 0)
          WHERE id = ?
        ''',
          [row['tagId']],
        );
      }
    });
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
      tags: tags,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
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

String _buildOrderWhereClause(PaginatedByDate paginated) {
  return switch (paginated.order) {
    OrderDate.updatedDesc => 'updatedAt > ?',
    OrderDate.updatedAsc => 'updatedAt < ?',
    OrderDate.createdDesc => 'createdAt > ?',
    OrderDate.createdAsc => 'createdAt < ?',
  };
}

String _buildOrderField(PaginatedByDate paginated) {
  return switch (paginated.order) {
    OrderDate.updatedDesc || OrderDate.updatedAsc => 'updatedAt',
    OrderDate.createdDesc || OrderDate.createdAsc => 'createdAt',
  };
}
