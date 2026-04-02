import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tag_links/data/data_sources/deleted_dao.dart';
import 'package:tag_links/data/data_sources/link_preview_dao.dart';
import 'package:tag_links/data/data_sources/tag_notes_dao.dart';
import 'package:tag_links/models/link_preview.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/models/note_join_row.dart';
import 'package:tag_links/models/search_query.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/utils/paginated_utils.dart';

//DAO = Data Access Object
class NotesDao {
  final FetchersNotesDao _fetch;
  NotesDao(Database db)
    : _fetch = FetchersNotesDao(
        db: db,
        linkDao: LinkPreviewDao(db),
        tagsNotesDao: TagsNotesDao(db),
        deletedNotesDao: DeletedNotesDao(db: db),
      );
  /* ----------------------------- PUBLIC API ----------------------------- */
  Future<List<Note>> searchByQuery(
    SearchQuery query, {
    required PaginatedByDate paginated,
    String? folderId,
    required FolderFilter folderFilter,
  }) async {
    try {
      final rows = await _fetch.searchByQuery(
        query,
        folderId: folderId,
        paginated: paginated,
        folderFilter: folderFilter,
      );
      return _hydrate(rows);
    } catch (e) {
      debugPrint("NotesDao.searchByQuery:\n ${e.toString()}");
      if (query.isFavorite) {
        return getFavorites(pagination: paginated);
      }
      return [];
    }
  }

  Future<List<Note>> getByLastUpdate({
    required int? lastUpdate,
    int limit = 500,
  }) async {
    final rows = await _fetch.getByLastUpdate(
      lastUpdate: lastUpdate,
      limit: limit,
    );
    return _hydrate(rows);
  }

  Future<void> delete(String noteId) async {
    await _fetch.delete(noteId);
  }

  Future<void> upsert(Note note) async {
    await _fetch.upsert(note);
  }

  Future<void> upsertAll(List<Note> notes) async {
    await _fetch.upsertAll(notes);
  }

  Future<void> serverDeleteByIds(List<String> ids) async {
    await _fetch.serverDeleteByIds(ids);
  }

  Future<Note?> getById(String id) async {
    final rows = await _fetch.byId(id);
    if (rows.isEmpty) return null;
    return _hydrate(rows).first;
  }

  Future<List<Note>> getByFolder(
    String? folderId, {
    required PaginatedByDate pagination,
  }) async {
    try {
      final rows = await _fetch.byFolder(folderId, pagination);
      return _hydrate(rows);
    } catch (e) {
      debugPrint("NotesDao.getByFolder:\n ${e.toString()}");
      return [];
    }
  }

  Future<List<Note>> getByTags(
    String folderId,
    List<String> tagIds, {
    required PaginatedByDate pagination,
  }) async {
    final p = pagination;

    if (tagIds.isEmpty) {
      return getByFolder(folderId, pagination: p);
    }

    final rows = await _fetch.byTags(folderId, tagIds, p);
    return _hydrate(rows);
  }

  Future<List<Note>> getFavorites({required PaginatedByDate pagination}) async {
    final rows = await _fetch.favorites(pagination);
    return _hydrate(rows);
  }

  Future<PaginatedByDate> getPageForNoteId(
    Note note, {
    required PaginatedByDate paginated,
  }) async {
    return _fetch.getPageForNoteId(note, paginated: paginated);
  }

  // --------------- SYNC section ---------------
  Future<List<Note>> getByFileId(String fileId) async {
    final rows = await _fetch.getByFileId(fileId);
    return _hydrate(rows);
  }

  Future<List<Note>> getPendingSync({int limit = 200}) async {
    final rows = await _fetch.getPendingSync(limit: limit);
    return _hydrate(rows);
  }

  Future<bool> updateNotesSyncAt({
    required List<String> ids,
    required int syncAt,
    required String fileId,
  }) async {
    if (ids.isEmpty) {
      return true; //si no habia nada entonces fue un exito actualizar 0 datos
    }
    final success = await _fetch.updateNotesSyncAt(
      ids: ids,
      syncAt: syncAt,
      fileId: fileId,
    );
    return success >= ids.length;
  }
  Future<bool> hasAnyData() async {
    return await _fetch.hasAnyData();
  }


  /* ----------------------------- HYDRATION ----------------------------- */
  List<Note> _hydrate(List<NoteJoinRow> rows) {
    // 1. Mapa principal de notas (el que ya tenías)
    final Map<String, Note> map = {};

    // 2. Mapa auxiliar de Sets para que la búsqueda de etiquetas sea instantánea O(1)
    // Esto evita usar el .any() que hace lento el proceso con muchos datos
    final Map<String, Set<String>> tagsTracker = {};

    for (final row in rows) {
      // Intentamos obtener o crear la nota
      final note = map.putIfAbsent(row.noteId, () {
        // Si la nota es nueva en el mapa, también inicializamos su set de rastreo
        tagsTracker[row.noteId] = {};

        return Note(
          id: row.noteId,
          folderId: row.folderId,
          fileId: row.fileId,
          title: row.title,
          content: row.content ?? '',
          color: row.color,
          createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
          isFavorite: row.isFavorite,
          tags: [], // Lista vacía que iremos llenando
          syncAt: DateTime.fromMillisecondsSinceEpoch(row.syncAt ?? 0),
          link: row.linkId == null
              ? null
              : LinkPreview(
                  id: row.linkId!,
                  noteId: row.noteId,
                  url: row.linkUrl!,
                  title: row.linkTitle,
                  description: row.linkDescription,
                  image: row.linkImage,
                  siteName: row.linkSiteName,
                ),
        );
      });

      // 3. Lógica optimizada para etiquetas
      if (row.tagId != null) {
        // Obtenemos el set de IDs de etiquetas ya procesadas para esta nota
        final processedTags = tagsTracker[row.noteId]!;

        // .add() intenta agregar el ID al Set. Si ya existía, devuelve false.
        // Si no existía, devuelve true y lo agrega. Todo en un solo paso súper rápido.
        if (processedTags.add(row.tagId!)) {
          note.tags.add(
            Tag(
              id: row.tagId!,
              name: row.tagName!,
              fileId: row.fileId, //provisional
              isFavorite: row.isFavorite,
            ),
          );
        }
      }
    }

    return map.values.toList();
  }
}

/* ----------------------------- FETCHERS ----------------------------- */
class FetchersNotesDao {
  final Database _db;
  final LinkPreviewDao _linkDao;
  final TagsNotesDao _tagsNotesDao;
  final DeletedNotesDao _deletedNotesDao;
  FetchersNotesDao({
    required Database db,
    required LinkPreviewDao linkDao,
    required TagsNotesDao tagsNotesDao,
    required DeletedNotesDao deletedNotesDao,
  }) : _db = db,
       _linkDao = linkDao,
       _tagsNotesDao = tagsNotesDao,
       _deletedNotesDao = deletedNotesDao;

  Future<bool> hasAnyData() async {
    final result = await _db.query('notes', limit: 1);
    return result.isNotEmpty;
  }


  Future<List<NoteJoinRow>> searchByQuery(
    SearchQuery searchQuery, {
    required PaginatedByDate paginated,
    String? folderId,
    required FolderFilter folderFilter,
  }) async {
    final ids = await _fetchNoteIds(
      searchQuery,
      paginated: paginated,
      folderFilter: folderFilter,
    );
    if (ids.isEmpty) return [];

    final placeholders = List.filled(ids.length, '?').join(',');

    final sql =
        '''
    ${NoteJoinRow.selectQuery}
    WHERE n.id IN ($placeholders)
    ORDER BY n.${paginated.orderSql}
  ''';

    final result = await _db.rawQuery(sql, ids);
    return result.map(NoteJoinRow.fromMap).toList();
  }

  Future<List<NoteJoinRow>> getByLastUpdate({
    required int? lastUpdate,
    required int limit,
  }) async {
    final hasLastUpdate = lastUpdate != null;
    final where = hasLastUpdate ? "WHERE n.updatedAt > ?" : "";
    final args = hasLastUpdate ? [lastUpdate, limit] : [limit];
    final sql =
        '''
        ${NoteJoinRow.selectQuery}
        $where
        ORDER BY n.updatedAt DESC
        LIMIT ?
      ''';
    final result = await _db.rawQuery(sql, args);
    return result.map(NoteJoinRow.fromMap).toList();
  }

  Future<List<NoteJoinRow>> byFolder(
    String? folderId,
    PaginatedByDate p,
  ) async {
    String where = '';
    final args = <Object?>[];

    if (folderId != null) {
      where = 'WHERE n2.folderId = ?';
      args.add(folderId);
    } else {
      where = 'WHERE n2.folderId IS NULL';
    }

    args.addAll([p.limit, p.offset]);

    final rows = await _db.rawQuery('''
    ${NoteJoinRow.selectQuery}
    WHERE n.id IN (
      SELECT n2.id
      FROM notes n2
      $where
      ORDER BY n2.${p.orderSql}
      LIMIT ? OFFSET ?
    )
    ORDER BY n.${p.orderSql}
  ''', args);

    return rows.map(NoteJoinRow.fromMap).toList();
  }

  Future<List<NoteJoinRow>> byTags(
    String? folderId,
    List<String> tagIds,
    PaginatedByDate p,
  ) async {
    final placeholders = List.filled(tagIds.length, '?').join(',');

    final whereFolder = folderId != null
        ? 'n2.folderId = ?'
        : 'n2.folderId IS NULL';

    final List<Object> args;
    if (folderId != null) {
      args = [folderId, ...tagIds, tagIds.length, p.limit, p.offset];
    } else {
      args = [...tagIds, tagIds.length, p.limit, p.offset];
    }

    final rows = await _db.rawQuery('''
    ${NoteJoinRow.selectQuery}
    WHERE n.id IN (
      SELECT n2.id
      FROM notes n2
      INNER JOIN note_tags nt2 ON nt2.noteId = n2.id
      WHERE $whereFolder
        AND nt2.tagId IN ($placeholders)
      GROUP BY n2.id
      HAVING COUNT(DISTINCT nt2.tagId) = ?
      ORDER BY n2.${p.orderSql}
      LIMIT ? OFFSET ?
    )
    ORDER BY n.${p.orderSql}
    ''', args);

    return rows.map(NoteJoinRow.fromMap).toList();
  }

  Future<List<NoteJoinRow>> favorites(PaginatedByDate p) async {
    final rows = await _db.rawQuery(
      '''
    ${NoteJoinRow.selectQuery}
    WHERE n.id IN (
      SELECT n2.id 
      FROM notes n2
      WHERE n2.isFavorite = 1
      ORDER BY n2.${p.orderSql}
      LIMIT ? OFFSET ?
    )
    ORDER BY n.${p.orderSql}
    ''',
      [p.limit, p.offset],
    );

    return rows.map(NoteJoinRow.fromMap).toList();
  }

  Future<PaginatedByDate> getPageForNoteId(
    Note note, {
    required PaginatedByDate paginated,
  }) async {
    final field = _buildOrderField(paginated);
    final whereClause = paginated.order == OrderDate.updatedDesc ? '>' : '<';

    final whereFolder = note.folderId != null
        ? 'folderId = ?'
        : 'folderId IS NULL';

    final args = [if (note.folderId != null) note.folderId, note.id];

    final query =
        '''
    SELECT COUNT(*) as count
    FROM notes
    WHERE $whereFolder
      AND $field $whereClause (
        SELECT $field FROM notes WHERE id = ?
      );
  ''';

    final result = await _db.rawQuery(query, args);

    final rawCount = result.first['count'];
    final count = (rawCount as num?)?.toInt() ?? 0;

    final page = (count ~/ paginated.pageSize) + 1;

    return PaginatedByDate(
      page: page < 1 ? 1 : page,
      pageSize: paginated.pageSize,
      order: paginated.order,
    );
  }

  Future<List<String>> _fetchNoteIds(
    SearchQuery searchQuery, {
    required PaginatedByDate paginated,
    required FolderFilter folderFilter,
    String? folderId,
  }) async {
    final where = <String>[];
    final args = <Object?>[];

    // 🔎 Texto
    if (searchQuery.text.isNotEmpty) {
      where.add('(n.title LIKE ? OR n.content LIKE ?)');
      args.add('%${searchQuery.text}%');
      args.add('%${searchQuery.text}%');
    }

    // ⭐ Favoritos
    if (searchQuery.isFavorite == true) {
      where.add('n.isFavorite = 1');
    }

    // 📂 Folder filter (🔥 aquí está lo importante)
    switch (folderFilter) {
      case FolderFilter.all:
        break;

      case FolderFilter.root:
        where.add('n.folderId IS NULL');
        break;

      case FolderFilter.specific:
        if (folderId == null) {
          throw ArgumentError('folderId is required for FolderFilter.specific');
        }
        where.add('n.folderId = ?');
        args.add(folderId);
        break;
    }

    // 🏷 Include tags
    if (searchQuery.hasIncludeTags) {
      final placeholders = List.filled(
        searchQuery.includeTagsIds.length,
        '?',
      ).join(',');

      where.add('''
      n.id IN (
        SELECT nt.noteId
        FROM note_tags nt
        WHERE nt.tagId IN ($placeholders)
        GROUP BY nt.noteId
        HAVING COUNT(DISTINCT nt.tagId) = ${searchQuery.includeTagsIds.length}
      )
    ''');

      args.addAll(searchQuery.includeTagsIds);
    }

    // 🚫 Exclude tags
    if (searchQuery.hasExcludeTags) {
      final placeholders = List.filled(
        searchQuery.excludeTagsIds.length,
        '?',
      ).join(',');

      where.add('''
      n.id NOT IN (
        SELECT nt.noteId
        FROM note_tags nt
        WHERE nt.tagId IN ($placeholders)
      )
    ''');

      args.addAll(searchQuery.excludeTagsIds);
    }

    final whereSql = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';

    final sql =
        '''
    SELECT n.id
    FROM notes n
    $whereSql
    ORDER BY ${paginated.orderSql}
    LIMIT ? OFFSET ?
  ''';

    args.add(paginated.limit);
    args.add(paginated.offset);

    final result = await _db.rawQuery(sql, args);
    return result.map((r) => r['id'] as String).toList();
  }

  Future<List<NoteJoinRow>> byId(String id) async {
    final rows = await _db.rawQuery(
      '''
      ${NoteJoinRow.selectQuery}
      WHERE n.id = ?
      ''',
      [id],
    );

    return rows.map(NoteJoinRow.fromMap).toList();
  }

  Future<void> upsert(Note note) async {
    await _db.transaction((txn) async {
      // 1. Nota Principal (Manteniendo tu lógica inteligente de fecha)
      await txn.rawInsert(
        '''
      INSERT INTO notes (id, folderId, fileId, title, content, color, createdAt, updatedAt, syncAt, isFavorite)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(id) DO UPDATE SET
        folderId = excluded.folderId,
        fileId = excluded.fileId,
        title = excluded.title,
        content = excluded.content,
        color = excluded.color,
        updatedAt = excluded.updatedAt,
        isFavorite = excluded.isFavorite
      WHERE excluded.updatedAt > updatedAt 
    ''',
        [
          note.id,
          note.folderId,
          note.fileId,
          note.title,
          note.content,
          note.color,
          note.createdAt.millisecondsSinceEpoch,
          note.updatedAt.millisecondsSinceEpoch,
          note.syncAt?.millisecondsSinceEpoch,
          note.isFavorite ? 1 : 0,
        ],
      );

      // 2. Tags: Optimización por Diferencia (Ahorra batería y procesos)
      final currentRows = await txn.query(
        'note_tags',
        columns: ['tagId'],
        where: 'noteId = ?',
        whereArgs: [note.id],
      );
      final currentIds = currentRows.map((e) => e['tagId'] as String).toSet();
      final newIds = note.tags.map((t) => t.id).toSet();

      // Ahora usamos el DAO de Tags
      for (final tagId in currentIds.difference(newIds)) {
        await _tagsNotesDao.delete(
          noteId: note.id,
          tagId: tagId,
          executor: txn,
        );
      }

      for (final tagId in newIds.difference(currentIds)) {
        await _tagsNotesDao.upsert(
          noteId: note.id,
          tagId: tagId,
          executor: txn,
        );
      }

      // 3. Link Preview (Usando el DAO con upsert que ya corregimos)
      if (note.link != null) {
        await _linkDao.upsert(link: note.link!, txn: txn);
      } else {
        await _linkDao.delete(txn, note.id);
      }
    });
  }

  Future<void> upsertAll(List<Note> notes) async {
    if (notes.isEmpty) return;

    await _db.transaction((txn) async {
      final batch = txn.batch();

      for (final note in notes) {
        // 1. Upsert de la Nota
        batch.rawInsert(
          '''
        INSERT INTO notes (id, folderId, title, content, color, createdAt, updatedAt, syncAt, isFavorite)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
          folderId = excluded.folderId,
          title = excluded.title,
          content = excluded.content,
          color = excluded.color,
          updatedAt = excluded.updatedAt,
          isFavorite = excluded.isFavorite
        WHERE excluded.updatedAt > updatedAt 
      ''',
          [
            note.id,
            note.folderId,
            note.title,
            note.content,
            note.color,
            note.createdAt.millisecondsSinceEpoch,
            note.updatedAt.millisecondsSinceEpoch,
            note.syncAt?.millisecondsSinceEpoch,
            note.isFavorite ? 1 : 0,
          ],
        );

        // 2. Tags: Borrado y re-insertado es aceptable solo en BATCH masivo
        _tagsNotesDao.deleteBatch(batch, noteId: note.id);
        for (final tag in note.tags) {
          _tagsNotesDao.upsertBatch(batch, noteId: note.id, tagId: tag.id);
        }

        // 3. Links: DEBEN ir en el batch también
        if (note.link != null) {
          _linkDao.upsertBatch(batch, note.link!);
        } else {
          _linkDao.deleteBatch(batch, note.id);
        }
      }

      // 🚀 UN SOLO VIAJE A LA DB
      await batch.commit(noResult: true);
    });
  }

  /* ----------------------------------------------------------------------
   * DELETE
   * -------------------------------------------------------------------- */

  Future<void> delete(String id) async {
    await _db.transaction((txn) async {
      // 1. Verificar si el servidor conoce este elemento
      final result = await txn.query(
        'notes', // o 'folders'
        columns: ['syncAt'],
        where: 'id = ?',
        whereArgs: [id],
      );

      if (result.isNotEmpty) {
        final syncAt = result.first['syncAt'];

        // 2. Solo registramos el borrado si ya fue sincronizado alguna vez
        if (syncAt != null) {
          await _deletedNotesDao.saveId(id, executor: txn);
        }
      }

      // 3. Borrado físico de la base de datos local
      await txn.delete('notes', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<void> serverDeleteByIds(List<String> ids) async {
    if (ids.isEmpty) return;

    final placeholders = List.filled(ids.length, '?').join(',');
    try {
      await _db.transaction((txn) async {
        // Si tienes CASCADE, esto borrará automáticamente
        // etiquetas y links asociados en un solo paso de DB.
        await txn.delete(
          'notes',
          where: 'id IN ($placeholders)',
          whereArgs: ids,
        );
      });
    } catch (e) {
      debugPrint('NotesDao.serverDeleteByIds ERROR: $e');
    }
  }

  //helpers
  String _buildOrderField(PaginatedByDate paginated) {
    return switch (paginated.order) {
      OrderDate.updatedDesc || OrderDate.updatedAsc => 'updatedAt',
      OrderDate.createdDesc || OrderDate.createdAsc => 'createdAt',
    };
  }

  // ------------- SYNC section -------------
  Future<List<NoteJoinRow>> getByFileId(String fileId) async {
    final sql =
        '''
    ${NoteJoinRow.selectQuery}
    WHERE n.fileId = ?
    ORDER BY n.updatedAt DESC
  ''';

    final result = await _db.rawQuery(sql, [fileId]);

    return result.map(NoteJoinRow.fromMap).toList();
  }
  Future<List<NoteJoinRow>> getPendingSync({int limit = 200}) async {
    final sql =
        '''
    ${NoteJoinRow.selectQuery}
    WHERE n.syncAt IS NULL OR n.syncAt < n.updatedAt
    ORDER BY n.updatedAt DESC
    LIMIT ?
  ''';

    final result = await _db.rawQuery(sql, [limit]);

    return result.map(NoteJoinRow.fromMap).toList();
  }

  Future<int> updateNotesSyncAt({
    required List<String> ids,
    required int syncAt,
    required String fileId,
  }) async {
    if (ids.isEmpty) return 0;

    final db = _db;

    final placeholders = List.filled(ids.length, '?').join(',');

    final sql =
        '''
    UPDATE notes
    SET syncAt = ?,
    fileId = ?
    WHERE id IN ($placeholders)
  ''';

    return await db.rawUpdate(sql, [syncAt, ...ids]);
  }
}
