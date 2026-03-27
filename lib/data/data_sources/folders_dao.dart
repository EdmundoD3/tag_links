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
    try {
      await _db.transaction((txn) async {
        String? validatedParentId = folder.parentId;

        // 1. Si tiene un padre, verificamos el nivel de ese padre
        if (validatedParentId != null) {
          final parentRow = await txn.query(
            'folders',
            columns: ['parentId'],
            where: 'id = ?',
            whereArgs: [validatedParentId],
          );

          if (parentRow.isNotEmpty) {
            final parentsParentId = parentRow.first['parentId'];

            // REGLA DE ORO: Si mi padre ya tiene un padre,
            // yo no puedo ser su hijo (sería nivel 3).
            // Me voy a la raíz para salvar los datos.
            if (parentsParentId != null) {
              validatedParentId = null;
              debugPrint('Validación: Nivel máximo alcanzado. Movida a raíz.');
            }
          } else {
            // Si el padre no existe en la DB (por un error de sync),
            // también la mandamos a la raíz para evitar error de FK.
            validatedParentId = null;
          }
        }

        // 2. Ejecutar el UPSERT con el parentId validado
        await txn.rawInsert(
          '''
      INSERT INTO folders (
        id, parentId, fileId, title, description, image, color, 
        createdAt, updatedAt, syncAt, isFavorite
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(id) DO UPDATE SET
        parentId = ?, -- <--- Usamos un ? para pasar el validatedParentId
        fileId = excluded.fileId,
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
            validatedParentId, // Argumento para el VALUES
            folder.fileId,
            folder.title,
            folder.description,
            folder.image,
            folder.color,
            folder.createdAt.millisecondsSinceEpoch,
            folder.updatedAt.millisecondsSinceEpoch,
            folder.syncAt?.millisecondsSinceEpoch,
            folder.isFavorite ? 1 : 0,
            validatedParentId, // <--- Argumento extra para el SET parentId = ?
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
    } catch (e) {
      debugPrint('FoldersDao.upsert ERROR: $e');
    }
  }

  Future<void> upsertAll(List<Folder> folders) async {
    if (folders.isEmpty) return;

    // 1. Separar para garantizar orden jerárquico
    final parents = folders.where((f) => f.parentId == null).toList();
    final children = folders.where((f) => f.parentId != null).toList();

    await _db.transaction((txn) async {
      final batch = txn.batch();

      // 2. Insertar primero los padres (Raíz)
      for (final folder in parents) {
        _addFolderToBatch(batch, folder);
      }

      // 3. Insertar después los hijos
      for (final folder in children) {
        _addFolderToBatch(batch, folder);
      }

      await batch.commit(noResult: true);
    });
  }

  // Helper para no repetir el SQL del rawInsert
  void _addFolderToBatch(Batch batch, Folder folder) {
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
        {'parentId': childrenNewParentId, 'updatedAt': now},
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
      // IMPORTANTE: Asegúrate de que el modelo Folder tenga el campo fileId
      // y que lo estés pasando aquí para que viaje al JSON de Drive.
      fileId: map['fileId'],
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
    // Agregamos updatedAt y syncAt al SELECT para que Tag.fromMap no falle
    final result = await db.rawQuery(
      '''
      SELECT t.id, t.name, t.isFavorite, t.usageCount, t.updatedAt, t.syncAt
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

  Future<List<Folder>> getPendingSync({int limit = 200}) async {
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

  Future<bool> updateSyncAt({
    required List<String> ids,
    required int syncAt,
    required String fileId,
  }) async {
    if (ids.isEmpty) return false;

    final db = _db;
    final placeholders = List.filled(ids.length, '?').join(',');

    // Ahora actualizamos tanto la fecha de sync como el ID del archivo
    final sql =
        '''
          UPDATE folders
          SET syncAt = ?, 
              fileId = ?
          WHERE id IN ($placeholders)
        ''';

    // Los argumentos deben seguir el orden de los '?'
    final count = await db.rawUpdate(sql, [syncAt, fileId, ...ids]);

    // Es mejor retornar si afectó a alguna fila que comparar estrictamente el length
    // por si alguna ID ya no existiera, pero en general count == ids.length es lo ideal.
    return count > 0;
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
