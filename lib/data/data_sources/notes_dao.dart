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
import 'package:tag_links/sync/db/local_sync_queue_dao.dart';
import 'package:tag_links/sync/models/local_sync_queue.dart';
import 'package:tag_links/utils/paginated_utils.dart';

//DAO = Data Access Object
class NotesDao {
  final FetchersNotesDao _fetch;
  NotesDao(Database db, DeletedDao deletedDao)
    : _fetch = FetchersNotesDao(
        db: db,
        deletedDao: deletedDao,
        synDao: LocalSyncQueueDao(db),
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

  Future<void> delete(Note note) {
    return _fetch.delete(note);
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

  Future<bool> hasAnyData() async {
    return await _fetch.hasAnyData();
  }

  /* ----------------------------- HYDRATION ----------------------------- */
  List<Note> _hydrate(List<NoteJoinRow> rows) {
    // 1. Mapa principal para agrupar filas por ID de nota
    final Map<String, Note> map = {};

    // 2. Rastreador de Tags por nota (evita duplicados si una nota tiene múltiples links o tags)
    final Map<String, Set<String>> tagsTracker = {};

    for (final row in rows) {
      // Si la nota no está en el mapa, la creamos con sus datos base
      final note = map.putIfAbsent(row.noteId, () {
        tagsTracker[row.noteId] = {};

        return Note(
          id: row.noteId,
          folderId: row.folderId,
          fileId: row.fileId,
          title: row.title,
          content: row.content ?? '',
          color: row.color,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
          isFavorite: row.isFavorite,
          tags: [], // Lista inicial vacía
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

      // 3. Hidratación de Etiquetas (Tags)
      // Solo entramos si la fila actual contiene datos de un Tag
      if (row.tagId != null) {
        final processedTags = tagsTracker[row.noteId]!;

        // Si este tag específico aún no ha sido agregado a esta nota
        if (processedTags.add(row.tagId!)) {
          note.tags.add(
            Tag(
              id: row.tagId!,
              title: row.tagTitle!,
              fileId: row.tagFileId ?? '',
              isFavorite: row.tagIsFavorite ?? false,
              updatedAt: row.tagUpdatedAt ?? row.updatedAt,
              usageCount: row.tagUsageCount ?? 0,
            ),
          );
        }
      }
    }

    // Devolvemos la lista de notas únicas y completamente armadas
    return map.values.toList();
  }
}

/* ----------------------------- FETCHERS ----------------------------- */
class FetchersNotesDao {
  final Database _db;
  final DeletedDao _deletedDao;
  final LocalSyncQueueDao _syncDao;
  FetchersNotesDao({
    required Database db,
    required DeletedDao deletedDao,
    required LocalSyncQueueDao synDao,
  }) : _db = db,
       _deletedDao = deletedDao,
       _syncDao = synDao;

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
      // 1. Nota Principal
      await txn.rawInsert(
        '''
      INSERT INTO notes (id, folderId, fileId, title, content, color, createdAt, updatedAt, isFavorite)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(id) DO UPDATE SET
        folderId = excluded.folderId,
        fileId = excluded.fileId,
        title = excluded.title,
        content = excluded.content,
        color = excluded.color,
        updatedAt = excluded.updatedAt,
        isFavorite = excluded.isFavorite
      WHERE excluded.updatedAt >= updatedAt 
    ''',
        [
          note.id,
          note.folderId,
          note.fileId,
          note.title,
          note.content,
          note.color,
          note.createdAt,
          note.updatedAt,
          note.isFavorite ? 1 : 0,
        ],
      );

      // 2. Tags: Diferencia de Sets (Muy eficiente)
      final currentRows = await txn.query(
        'note_tags',
        columns: ['tagId'],
        where: 'noteId = ?',
        whereArgs: [note.id],
      );
      final currentIds = currentRows.map((e) => e['tagId'] as String).toSet();
      final newIds = note.tags.map((t) => t.id).toSet();

      for (final tagId in currentIds.difference(newIds)) {
        await TagsNotesDao.delete(txn,
          noteId: note.id,
          tagId: tagId,
        );
      }
      for (final tagId in newIds.difference(currentIds)) {
        await TagsNotesDao.upsert(txn,
          noteId: note.id,
          tagId: tagId,
        );
      }

      // 3. Link Preview
      if (note.link != null) {
        await LinkPreviewDao.upsert(txn,link: note.link!);
      } else {
        await LinkPreviewDao.delete(txn, note.id);
      }

      // 🚀 NOTIFICAR AL BUCKET: Cambio local detectado
      await LocalSyncQueueDao.markAsDirty(txn, bucketId: note.fileId);
    });
  }

Future<void> upsertAll(List<Note> unverifyNotes) async {
  if (unverifyNotes.isEmpty) return;

  // 1. Pre-procesamiento de IDs de archivo (Fuera de la transacción para velocidad)
  final String sharedFileId = await _syncDao.getOrCreateAvailableFileId(TypeQueue.notes);
  
  final notes = unverifyNotes.map((n) {
    return (n.fileId == null || n.fileId!.isEmpty) 
        ? n.copyWith(fileId: sharedFileId) 
        : n;
  }).toList();

  await _db.transaction((txn) async {
    // 🛡️ PASO 1: Filtrar notas borradas localmente
    final List<String> incomingIds = notes.map((e) => e.id).toList();
    final Set<String> dirtyDeletedIds = await _deletedDao
        .extractDirtyIdsByType(incomingIds, DeletedType.note, executor: txn);

    // 🔍 PASO 2: Verificar folders existentes (Solo para las notas que traen folderId)
    final Set<String> incomingFolderIds = notes
        .map((e) => e.folderId)
        .whereType<String>()
        .toSet();

    Set<String> existingFolderIds = {};
    if (incomingFolderIds.isNotEmpty) {
      final List<Map<String, dynamic>> foldersFound = await txn.query(
        'folders',
        columns: ['id'],
        where: 'id IN (${incomingFolderIds.map((_) => '?').join(',')})',
        whereArgs: incomingFolderIds.toList(),
      );
      existingFolderIds = foldersFound.map((f) => f['id'] as String).toSet();
    }

    final batch = txn.batch();

    for (final note in notes) {
      if (dirtyDeletedIds.contains(note.id)) continue;

      // 🎯 Lógica de Rescate: Si el folder no existe, mandamos a NULL (Raíz)
      String? finalFolderId = note.folderId;
      if (finalFolderId != null && !existingFolderIds.contains(finalFolderId)) {
        finalFolderId = null; // Directo a la raíz
        debugPrint("📦 Nota ${note.id} movida a Raíz (Folder original no existe)");
      }

      batch.rawInsert(
        '''
        INSERT INTO notes (
          id, folderId, fileId, title, content, color, 
          createdAt, updatedAt, isFavorite
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
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
          finalFolderId,
          note.fileId,
          note.title,
          note.content,
          note.color,
          note.createdAt,
          note.updatedAt,
          note.isFavorite ? 1 : 0,
        ],
      );

      // Tags y Links (Batch)
      TagsNotesDao.deleteBatch(batch, noteId: note.id);
      for (final tag in note.tags) {
        TagsNotesDao.upsertBatch(batch, noteId: note.id, tagId: tag.id);
      }
      
      if (note.link != null) {
        LinkPreviewDao.upsertBatch(batch, note.link!);
      } else {
        LinkPreviewDao.deleteBatch(batch, note.id);
      }
    }

    await batch.commit(noResult: true);
  });
}
  /* ----------------------------------------------------------------------
   * DELETE
   * -------------------------------------------------------------------- */

  Future<void> delete(Note note) async {
    // Recibimos el objeto completo
    try {
      await _db.transaction((txn) async {
        final String id = note.id;
        final String bucketId =
            note.fileId; // 🎯 Ya lo tenemos, no hay que buscarlo

        // 1. Registramos el borrado en la tabla de "deletes"
        // (Esto marcará el bucket de borrados como sucio internamente)
        await DeletedDao.saveId(txn,id: id,type: DeletedType.note);

        // 2. ¡IMPORTANTE! Marcamos el bucket original de la nota como sucio
        // Ahora el Pusher generará un JSON de notas SIN esta nota.
        await LocalSyncQueueDao.markAsDirty(txn, bucketId: bucketId);
        await _syncDao.decreceCount(fileId: note.fileId, executor: txn);

        // 3. Borrado físico local
        await txn.delete('notes', where: 'id = ?', whereArgs: [id]);
      });
    } catch (e) {
      debugPrint('NotesDao.delete ERROR: $e');
      rethrow;
    }
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
      rethrow;
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
}
