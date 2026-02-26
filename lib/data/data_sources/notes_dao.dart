import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tag_links/data/data_sources/link_preview_dao.dart';
import 'package:tag_links/data/database.dart';
import 'package:tag_links/models/link_preview.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/models/note_join_row.dart';
import 'package:tag_links/models/search_query.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/utils/paginated_utils.dart';

//DAO = Data Access Object
class NotesDao {
  final _fetch = _FetchersNotesDao();
  /* ----------------------------- PUBLIC API ----------------------------- */
  Future<List<Note>> searchByQuery(
    SearchQuery query, {
    required PaginatedByDate paginated,
    String? folderId,
  }) async {
    try {
      final rows = await _fetch.searchByQuery(
        query,
        folderId: folderId,
        paginated: paginated,
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

  Future<void> insert(Note note) async {
    await _fetch.insert(note);
  }

  Future<void> update(Note note) async {
    await _fetch.update(note);
  }

  Future<void> delete(String noteId) async {
    await _fetch.delete(noteId);
  }

  Future<void> upsertAll(List<Note> notes) async {
    await _fetch.upsertAll(notes);
  }

  Future<void> deleteByIds(List<String> ids) async {
    await _fetch.deleteByIds(ids);
  }

  Future<Note?> getById(String id) async {
    final rows = await _fetch.byId(id);
    if (rows.isEmpty) return null;
    return _hydrate(rows).first;
  }

  Future<List<Note>> getByFolder(
    String folderId, {
    required PaginatedByDate pagination,
  }) async {
    final rows = await _fetch.byFolder(folderId, pagination);
    return _hydrate(rows);
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

  Future<int> countByFolder(String folderId) async {
    return _fetch.countByFolder(folderId);
  }

  Future<int> countByTags(String folderId, List<String> tagIds) async {
    return _fetch.countByTags(folderId, tagIds);
  }

  Future<List<Note>> search(
    String folderId,
    String query, {
    required PaginatedByDate pagination,
  }) async {
    final rows = await _fetch.search(folderId, query, pagination);
    return _hydrate(rows);
  }

  Future<int> countSearch(String folderId, String query) async {
    return _fetch.countSearch(folderId, query);
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
      final note = map.putIfAbsent(
        row.noteId,
        () {
          // Si la nota es nueva en el mapa, también inicializamos su set de rastreo
          tagsTracker[row.noteId] = {};
          
          return Note(
            id: row.noteId,
            folderId: row.folderId,
            title: row.title,
            content: row.content ?? '',
            color: row.color,
            createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
            updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
            isFavorite: row.isFavorite,
            tags: [], // Lista vacía que iremos llenando
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
        },
      );

      // 3. Lógica optimizada para etiquetas
      if (row.tagId != null) {
        // Obtenemos el set de IDs de etiquetas ya procesadas para esta nota
        final processedTags = tagsTracker[row.noteId]!;

        // .add() intenta agregar el ID al Set. Si ya existía, devuelve false.
        // Si no existía, devuelve true y lo agrega. Todo en un solo paso súper rápido.
        if (processedTags.add(row.tagId!)) {
          note.tags.add(Tag(id: row.tagId!, name: row.tagName!));
        }
      }
    }

    return map.values.toList();
  }
}

/* ----------------------------- FETCHERS ----------------------------- */

class _FetchersNotesDao {
  Future<Database> get _db async => AppDatabase().database;
  final _linkDao = LinkPreviewDao();

  Future<List<NoteJoinRow>> searchByQuery(
    SearchQuery searchQuery, {
    required PaginatedByDate paginated,
    String? folderId,
  }) async {
    final ids = await _fetchNoteIds(
      searchQuery,
      folderId: folderId,
      paginated: paginated,
    );
    if (ids.isEmpty) return [];

    final db = await _db;
    final placeholders = List.filled(ids.length, '?').join(',');

    final sql =
        '''
    ${NoteJoinRow.selectQuery}
    WHERE n.id IN ($placeholders)
    ORDER BY ${paginated.orderSql}
  ''';

    final result = await db.rawQuery(sql, ids);
    return result.map(NoteJoinRow.fromMap).toList();
  }

  Future<List<NoteJoinRow>> getByLastUpdate({
    required int? lastUpdate,
    required int limit,
  }) async {
    final db = await _db;
    final hasLastUpdate = lastUpdate != null;
    final where = hasLastUpdate ? "WHERE updatedAt > ?" : "";
    final args = hasLastUpdate ? [lastUpdate, limit] : [limit];
    final sql =
        '''
        SELECT *
        FROM notes
        $where
        ORDER BY updatedAt DESC
        LIMIT ?
      ''';
    final result = await db.rawQuery(sql, args);
    return result.map(NoteJoinRow.fromMap).toList();
  }

  Future<List<NoteJoinRow>> byFolder(String folderId, PaginatedByDate p) async {
    final db = await _db;

    final rows = await db.rawQuery(
      '''
      ${NoteJoinRow.selectQuery}
      WHERE n.id IN (
        SELECT id
        FROM notes
        WHERE folderId = ?
        ORDER BY ${p.orderSql}
        LIMIT ? OFFSET ?
      )
      ORDER BY ${p.orderSql}
      ''',
      [folderId, p.limit, p.offset],
    );
    return rows.map(NoteJoinRow.fromMap).toList();
  }

  Future<List<NoteJoinRow>> byTags(
    String folderId,
    List<String> tagIds,
    PaginatedByDate p,
  ) async {
    final db = await _db;
    final placeholders = List.filled(tagIds.length, '?').join(',');

    final rows = await db.rawQuery(
      '''
      ${NoteJoinRow.selectQuery}
      WHERE n.id IN (
        SELECT n2.id
        FROM notes n2
        INNER JOIN note_tags nt2 ON nt2.noteId = n2.id
        WHERE n2.folderId = ?
          AND nt2.tagId IN ($placeholders)
        GROUP BY n2.id
        HAVING COUNT(DISTINCT nt2.tagId) = ?
        ORDER BY ${p.orderSql}
        LIMIT ? OFFSET ?
      )
      ORDER BY ${p.orderSql}
      ''',
      [folderId, ...tagIds, tagIds.length, p.limit, p.offset],
    );

    return rows.map(NoteJoinRow.fromMap).toList();
  }

  Future<List<NoteJoinRow>> favorites(PaginatedByDate p) async {
    final db = await _db;

    final rows = await db.rawQuery(
      '''
      ${NoteJoinRow.selectQuery}
      WHERE n.id IN (
        SELECT id
        FROM notes
        WHERE isFavorite = 1
        ORDER BY ${p.orderSql}
        LIMIT ? OFFSET ?
      )
      ORDER BY ${p.orderSql}
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

    final query =
        '''
  SELECT COUNT(*) as count
  FROM notes
  WHERE folderId = ?
    AND $field $whereClause (
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

  Future<List<String>> _fetchNoteIds(
    SearchQuery searchQuery, {
    required PaginatedByDate paginated,
    String? folderId,
  }) async {
    final db = await _db;

    final where = <String>[];
    final args = <Object?>[];

    if (searchQuery.text.isNotEmpty) {
      where.add('(n.title LIKE ? OR n.content LIKE ?)');
      args.add('%${searchQuery.text}%');
      args.add('%${searchQuery.text}%');
    }

    if (folderId != null && folderId.isNotEmpty) {
      where.add('n.folderId = ?');
      args.add(folderId);
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

    final result = await db.rawQuery(sql, args);
    return result.map((r) => r['id'] as String).toList();
  }

  Future<List<NoteJoinRow>> byId(String id) async {
    final db = await _db;

    final rows = await db.rawQuery(
      '''
      ${NoteJoinRow.selectQuery}
      WHERE n.id = ?
      ''',
      [id],
    );

    return rows.map(NoteJoinRow.fromMap).toList();
  }

  Future<int> countByFolder(String folderId) async {
    final db = await _db;

    final result = await db.rawQuery(
      '''
    SELECT COUNT(*) as total
    FROM notes
    WHERE folderId = ?
    ''',
      [folderId],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> countByTags(String folderId, List<String> tagIds) async {
    final db = await _db;
    final placeholders = List.filled(tagIds.length, '?').join(',');

    final result = await db.rawQuery(
      '''
    SELECT COUNT(*) as total
    FROM (
      SELECT n.id
      FROM notes n
      INNER JOIN note_tags nt ON nt.noteId = n.id
      WHERE n.folderId = ?
        AND nt.tagId IN ($placeholders)
      GROUP BY n.id
      HAVING COUNT(DISTINCT nt.tagId) = ?
    )
    ''',
      [folderId, ...tagIds, tagIds.length],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<NoteJoinRow>> search(
    String folderId,
    String query,
    PaginatedByDate p,
  ) async {
    final db = await _db;
    final q = '%$query%';

    final rows = await db.rawQuery(
      '''
    ${NoteJoinRow.selectQuery}
    WHERE n.id IN (
      SELECT id
      FROM notes
      WHERE folderId = ?
        AND (title LIKE ? OR content LIKE ?)
      ORDER BY ${p.orderSql}
      LIMIT ? OFFSET ?
    )
    ORDER BY ${p.orderSql}
    ''',
      [folderId, q, q, p.limit, p.offset],
    );

    return rows.map(NoteJoinRow.fromMap).toList();
  }

  Future<int> countSearch(String folderId, String query) async {
    final db = await _db;
    final q = '%$query%';

    final result = await db.rawQuery(
      '''
    SELECT COUNT(*)
    FROM notes
    WHERE folderId = ?
      AND (title LIKE ? OR content LIKE ?)
    ''',
      [folderId, q, q],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }
  /* ----------------------------------------------------------------------
   * INSERT
   * -------------------------------------------------------------------- */

Future<void> insert(Note note) async {
    final db = await _db;
    await db.transaction((txn) async {
      // 1️⃣ Insert note
      await txn.insert(
        'notes',
        note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2️⃣ Insert tags (El Trigger se encarga del usageCount automáticamente)
      for (final tag in note.tags) {
        await txn.insert('note_tags', {
          'noteId': note.id,
          'tagId': tag.id,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }

      // 3️⃣ Link
      if (note.link != null) {
        _linkDao.insert(txn, note.id, note.link!);
      }
    });
  }

  /* ----------------------------------------------------------------------
   * UPDATE
   * -------------------------------------------------------------------- */

Future<void> update(Note note) async {
    final db = await _db;
    await db.transaction((txn) async {
      // 1️⃣ Update base note
      await txn.update(
        'notes',
        note.copyWith(updatedAt: DateTime.now()).toMap(),
        where: 'id = ?',
        whereArgs: [note.id],
      );

      // 2️⃣ Tags: Borrar y Recrear. 
      // Al borrar de 'note_tags', el Trigger decrementa usageCount.
      // Al insertar en 'note_tags', el Trigger incrementa usageCount.
      await txn.delete('note_tags', where: 'noteId = ?', whereArgs: [note.id]);
      
      for (final tag in note.tags) {
        await txn.insert('note_tags', {
          'noteId': note.id,
          'tagId': tag.id,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }

      // 3️⃣ Links
      if (note.link != null) {
        await _linkDao.replace(txn: txn, noteId: note.id, link: note.link);
      } else {
        await _linkDao.delete(txn, note.id);
      }
    });
  }

Future<void> upsertAll(List<Note> notes) async {
  if (notes.isEmpty) return;
  final db = await _db;

  await db.transaction((txn) async {
    final batch = txn.batch(); // 👈 Iniciamos el Batch

    for (final note in notes) {
      // 1. Upsert de la Nota
      batch.insert(
        'notes',
        note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. Gestión de Tags: Borramos todos y re-insertamos (más rápido en batch)
      batch.delete('note_tags', where: 'noteId = ?', whereArgs: [note.id]);
      for (final tag in note.tags) {
        batch.insert('note_tags', {
          'noteId': note.id,
          'tagId': tag.id,
        });
        // Si tienes una tabla maestra de tags, podrías hacer upsert del tag aquí también
      }

      // 3. Gestión de Links
      if (note.link != null) {
          await _linkDao.replace(txn: txn, noteId: note.id, link: note.link!);
        } else {
          await _linkDao.delete(txn, note.id);
        }
    }

    // Ejecutamos todo de un solo golpe
    await batch.commit(noResult: true); 
  });
}

  /* ----------------------------------------------------------------------
   * DELETE
   * -------------------------------------------------------------------- */

Future<void> delete(String noteId) async {
    final db = await _db;
    // Con ON DELETE CASCADE en la tabla note_tags y link_previews,
    // solo necesitas borrar la nota. Los triggers se dispararán solos.
    await db.delete('notes', where: 'id = ?', whereArgs: [noteId]);
  }

Future<void> deleteByIds(List<String> ids) async {
  if (ids.isEmpty) return;
  final db = await _db;
  
  // Dividir en trozos de 500 si la lista es enorme (Opcional, pero robusto)
  final placeholders = List.filled(ids.length, '?').join(',');
  
  await db.transaction((txn) async {
    // Si no tienes "ON DELETE CASCADE" en tu base de datos, 
    // debes borrar manualmente los hijos aquí también en el mismo batch.
    final batch = txn.batch();
    
    batch.delete('note_tags', where: 'noteId IN ($placeholders)', whereArgs: ids);
    batch.delete('links', where: 'noteId IN ($placeholders)', whereArgs: ids);
    batch.delete('notes', where: 'id IN ($placeholders)', whereArgs: ids);
    
    await batch.commit(noResult: true);
  });
}

  //helpers

  // String _buildOrderWhereClause(PaginatedByDate paginated) {
  //   return switch (paginated.order) {
  //     OrderDate.updatedDesc => 'updatedAt > ?',
  //     OrderDate.updatedAsc => 'updatedAt < ?',
  //     OrderDate.createdDesc => 'createdAt > ?',
  //     OrderDate.createdAsc => 'createdAt < ?',
  //   };
  // }

  String _buildOrderField(PaginatedByDate paginated) {
    return switch (paginated.order) {
      OrderDate.updatedDesc || OrderDate.updatedAsc => 'updatedAt',
      OrderDate.createdDesc || OrderDate.createdAsc => 'createdAt',
    };
  }
}
