import 'package:sqflite/sqflite.dart';
import 'package:tag_links/data/database.dart';
import 'package:tag_links/models/link_preview.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/utils/paginated_utils.dart';
//DAO = Data Access Object
class NotesDao {
  final _fetch = _FetchersNotesDao();
  /* ----------------------------- PUBLIC API ----------------------------- */
  Future<void> insert(Note note) async {
    await _fetch.insert(note);
  }

  Future<void> update(Note note) async {
    await _fetch.update(note);
  }

  Future<void> delete(String noteId) async {
    await _fetch.delete(noteId);
  }

  Future<Note?> getById(String id) async {
    final rows = await _fetch.byId(id);
    if (rows.isEmpty) return null;
    return _hydrate(rows).first;
  }

  Future<List<Note>> getByFolder(
    String folderId, {
    PaginatedParams? pagination,
  }) async {
    final rows = await _fetch.byFolder(
      folderId,
      pagination ?? const PaginatedParams(),
    );
    return _hydrate(rows);
  }

  Future<List<Note>> getByTags(
    String folderId,
    List<String> tagIds, {
    PaginatedParams? pagination,
  }) async {
    final p = pagination ?? const PaginatedParams();

    if (tagIds.isEmpty) {
      return getByFolder(folderId, pagination: p);
    }

    final rows = await _fetch.byTags(folderId, tagIds, p);
    return _hydrate(rows);
  }

  Future<List<Note>> getFavorites({PaginatedParams? pagination}) async {
    final rows = await _fetch.favorites(pagination ?? const PaginatedParams());
    return _hydrate(rows);
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
    PaginatedParams? pagination,
  }) async {
    final rows = await _fetch.search(
      folderId,
      query,
      pagination ?? const PaginatedParams(),
    );
    return _hydrate(rows);
  }

  Future<int> countSearch(String folderId, String query) async {
    return _fetch.countSearch(folderId, query);
  }

  /* ----------------------------- HYDRATION ----------------------------- */
  List<Note> _hydrate(List<NoteJoinRow> rows) {
    final Map<String, Note> map = {};

    for (final row in rows) {
      final note = map.putIfAbsent(
        row.noteId,
        () => Note(
          id: row.noteId,
          folderId: row.folderId,
          title: row.title,
          content: row.content,
          createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
          tags: [],
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
        ),
      );

      if (row.tagId != null && !note.tags.any((t) => t.id == row.tagId)) {
        note.tags.add(Tag(id: row.tagId!, name: row.tagName!));
      }
    }

    return map.values.toList();
  }
}

/* ----------------------------- FETCHERS ----------------------------- */

class _FetchersNotesDao {
  Future<Database> get _db async => AppDatabase().database;

  Future<List<NoteJoinRow>> byFolder(String folderId, PaginatedParams p) async {
    final db = await _db;

    final rows = await db.rawQuery(
      '''
      ${NoteJoinRow.selectQuery}
      WHERE n.id IN (
        SELECT id
        FROM notes
        WHERE folderId = ?
        ORDER BY ${orderBySql(p.order)}
        LIMIT ? OFFSET ?
      )
      ORDER BY ${orderBySql(p.order)}
      ''',
      [folderId, p.limit, p.offset],
    );

    return rows.map(NoteJoinRow.fromMap).toList();
  }

  Future<List<NoteJoinRow>> byTags(
    String folderId,
    List<String> tagIds,
    PaginatedParams p,
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
        ORDER BY ${orderBySql(p.order)}
        LIMIT ? OFFSET ?
      )
      ORDER BY ${orderBySql(p.order)}
      ''',
      [folderId, ...tagIds, tagIds.length, p.limit, p.offset],
    );

    return rows.map(NoteJoinRow.fromMap).toList();
  }

  Future<List<NoteJoinRow>> favorites(PaginatedParams p) async {
    final db = await _db;

    final rows = await db.rawQuery(
      '''
      ${NoteJoinRow.selectQuery}
      WHERE n.id IN (
        SELECT id
        FROM notes
        WHERE isFavorite = 1
        ORDER BY ${orderBySql(p.order)}
        LIMIT ? OFFSET ?
      )
      ORDER BY ${orderBySql(p.order)}
      ''',
      [p.limit, p.offset],
    );

    return rows.map(NoteJoinRow.fromMap).toList();
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
    PaginatedParams p,
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
      ORDER BY ${orderBySql(p.order)}
      LIMIT ? OFFSET ?
    )
    ORDER BY ${orderBySql(p.order)}
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
      await txn.insert('notes', note.toMap());

      // 2️⃣ Insert tags
      for (final tag in note.tags) {
        await txn.insert('note_tags', {
          'noteId': note.id,
          'tagId': tag.id,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);

        // incrementar uso
        await txn.rawUpdate(
          '''
          UPDATE tags
          SET usageCount = usageCount + 1
          WHERE id = ?
          ''',
          [tag.id],
        );
      }

      // 3️⃣ Insert link (si existe)
      if (note.link != null) {
        await txn.insert('link_previews', {
          'id': note.link!.id,
          'noteId': note.id,
          'url': note.link!.url,
          'title': note.link!.title,
          'description': note.link!.description,
          'image': note.link!.image,
          'siteName': note.link!.siteName,
        });
      }
    });
  }

  /* ----------------------------------------------------------------------
   * UPDATE
   * -------------------------------------------------------------------- */

  Future<void> update(Note note) async {
    final db = await _db;

    await db.transaction((txn) async {
      // 1️⃣ Update note
      await txn.update(
        'notes',
        note.copyWith(updatedAt: DateTime.now()).toMap(),
        where: 'id = ?',
        whereArgs: [note.id],
      );

      // 2️⃣ Tags: borrar y recrear
      final oldTags = await txn.query(
        'note_tags',
        columns: ['tagId'],
        where: 'noteId = ?',
        whereArgs: [note.id],
      );

      // decrement usageCount
      for (final row in oldTags) {
        await txn.rawUpdate(
          '''
          UPDATE tags
          SET usageCount = MAX(usageCount - 1, 0)
          WHERE id = ?
          ''',
          [row['tagId']],
        );
      }

      await txn.delete('note_tags', where: 'noteId = ?', whereArgs: [note.id]);

      for (final tag in note.tags) {
        await txn.insert('note_tags', {
          'noteId': note.id,
          'tagId': tag.id,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);

        await txn.rawUpdate(
          '''
          UPDATE tags
          SET usageCount = usageCount + 1
          WHERE id = ?
          ''',
          [tag.id],
        );
      }

      // 3️⃣ Links: borrar y recrear
      await txn.delete(
        'link_previews',
        where: 'noteId = ?',
        whereArgs: [note.id],
      );

      if (note.link != null) {
        await txn.insert('link_previews', {
          'id': note.link!.id,
          'noteId': note.id,
          'url': note.link!.url,
          'title': note.link!.title,
          'description': note.link!.description,
          'image': note.link!.image,
          'siteName': note.link!.siteName,
        });
      }
    });
  }

  /* ----------------------------------------------------------------------
   * DELETE
   * -------------------------------------------------------------------- */

  Future<void> delete(String noteId) async {
    final db = await _db;

    await db.transaction((txn) async {
      // 1️⃣ Obtener tags asociados
      final tags = await txn.query(
        'note_tags',
        columns: ['tagId'],
        where: 'noteId = ?',
        whereArgs: [noteId],
      );

      // 2️⃣ Decrementar usageCount
      for (final row in tags) {
        await txn.rawUpdate(
          '''
          UPDATE tags
          SET usageCount = MAX(usageCount - 1, 0)
          WHERE id = ?
          ''',
          [row['tagId']],
        );
      }

      // 3️⃣ Borrar note (cascade se encarga del resto)
      await txn.delete('notes', where: 'id = ?', whereArgs: [noteId]);
    });
  }
}
