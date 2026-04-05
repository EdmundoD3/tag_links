import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tag_links/data/data_sources/deleted_dao.dart';
import 'package:tag_links/data/data_sources/folder_tags_dao.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/models/search_query.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/sync/db/local_sync_queue_dao.dart';
import 'package:tag_links/utils/paginated_utils.dart';

class FoldersDao {
  final Database _db;
  final FolderTagsDao _folderTagsDao;
  final DeletedFoldersDao _deletedFoldersDao;
  final LocalSyncQueueDao _syncDao;

  FoldersDao({
    required Database db,
    required FolderTagsDao folderTagsDao,
    required DeletedFoldersDao deletedFoldersDao,
    required LocalSyncQueueDao syncDao,
  }) : _db = db,
       _folderTagsDao = folderTagsDao,
       _deletedFoldersDao = deletedFoldersDao,
       _syncDao = syncDao;

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

        final currentTagIds = currentTagRows.map((e) => e['tagId'] as String).toSet();
        final newTagIds = folder.tags.map((t) => t.id).toSet();

        for (final tagId in newTagIds.difference(currentTagIds)) {
          await _folderTagsDao.upsert(folderId: folder.id, tagId: tagId, executor: txn);
        }
        for (final tagId in currentTagIds.difference(newTagIds)) {
          await _folderTagsDao.delete(folderId: folder.id, tagId: tagId, executor: txn);
        }

        // 🚀 4. NOTIFICAR AL BUCKET: Marcar como Dirty (syncStatus = 2)
        await txn.update(
          'files',
          {
            'syncStatus': 2, 
            'lastUpdate': folder.updatedAt,
          },
          where: 'id = ?',
          whereArgs: [folder.fileId],
        );
      });
    } catch (e) {
      debugPrint('FoldersDao.upsert ERROR: $e');
      rethrow;
    }
  }

  Future<void> upsertAll(List<Folder> folders) async {
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
            folder.id, folder.parentId, folder.fileId, folder.title,
            folder.description, folder.image, folder.color,
            folder.createdAt, folder.updatedAt,
            folder.isFavorite ? 1 : 0,
          ],
        );

        // B. Sincronizar etiquetas (Limpieza rápida en batch)
        batch.delete('folder_tags', where: 'folderId = ?', whereArgs: [folder.id]);
        for (final tag in folder.tags) {
          batch.insert('folder_tags', {
            'folderId': folder.id,
            'tagId': tag.id,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      }

      await batch.commit(noResult: true);
      // Al ser PULL (upsertAll), no marcamos el bucket como sucio.
    });
  }

/// DELETE RECURSIVO
  Future<void> delete(String id) async {
    await _db.transaction((txn) async {
      // 1. Obtener todos los hijos recursivamente (incluyendo el ID actual)
      // Asegúrate de que esta función use el 'executor' (txn) para ser atómica
      final idsToDelete = await getAllDescendantIds(id, executor: txn);
      if (idsToDelete.isEmpty) return;

      final placeholders = List.filled(idsToDelete.length, '?').join(',');

      // 2. Antes de borrar, obtenemos los datos necesarios: 
      // - driveFileId: Para saber si hay que avisarle a Drive (DeletedDao)
      // - fileId: Para saber qué buckets quedaron "sucios" localmente
      final List<Map<String, dynamic>> affectedData = await txn.query(
        'folders',
        columns: ['id', 'driveFileId', 'fileId'],
        where: 'id IN ($placeholders)',
        whereArgs: idsToDelete.toList(),
      );

      final Set<String> bucketsToDirty = {};

      // 3. Procesar datos para sincronización
      for (final row in affectedData) {
        final folderId = row['id'] as String;
        final driveId = row['driveFileId']; // Puede ser null si nunca se subió
        final bucketId = row['fileId'] as String;

        // Guardamos el bucket para marcarlo como sucio después
        bucketsToDirty.add(bucketId);

        // Si el servidor ya conocía esta carpeta, registramos el borrado
        if (driveId != null) {
          await _deletedFoldersDao.saveId(folderId, executor: txn);
        }
      }

      // 4. Borrado físico local
      // El ON DELETE CASCADE de tu base de datos se encargará de limpiar 
      // las tablas dependientes (como folder_tags o notes si así lo configuraste)
      await txn.delete(
        'folders',
        where: 'id IN ($placeholders)',
        whereArgs: idsToDelete.toList(),
      );

      // 5. "Manchar" todos los buckets involucrados
      // Importante: markAsDirty debe aceptar Transaction? executor
      for (final bId in bucketsToDirty) {
        await _syncDao.markAsDirty(bId, executor: txn);
      }
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
    // 1. Obtenemos las etiquetas asociadas a esta carpeta
    final tags = await _getTagsByFolderId(db, map['id'] as String);

    // 2. Construimos el objeto Folder mapeando tipos de SQLite a Dart
    return Folder(
      id: map['id'] as String,
      parentId: map['parentId'] as String?,
      fileId: map['fileId'] as String, // Crucial para la sincronización por buckets
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

  /// GET TAGS BY FOLDER
  Future<List<Tag>> _getTagsByFolderId(Database db, String folderId) async {
    // Agregamos updatedAt al SELECT para que Tag.fromMap no falle
    final result = await db.rawQuery(
      '''
      SELECT t.id, t.name, t.fileId, t.isFavorite, t.usageCount, t.updatedAt
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
