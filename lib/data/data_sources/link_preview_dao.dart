import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tag_links/models/link_preview.dart';

class LinkPreviewDao {
  static const String _tableName = 'link_previews';
  final Database _db;
  LinkPreviewDao(Database db) : _db = db;

  // 1. Lógica de Reemplazo (Útil para operaciones fuera de Batch)
  Future<void> replace({required String noteId, LinkPreview? link}) async {
    if (link == null) {
      await delete(_db, noteId);
    } else {
      await upsert(_db, link: link);
    }
  }

Future<void> invalidatePreviewImage(String id) async {
  await _db.update(
    _tableName,
    {
      'image': null,
      'lastUpdate': DateTime.now().millisecondsSinceEpoch,
    },
    where: 'id = ?',
    whereArgs: [id],
  );
}

  // 2. Operaciones Inmediatas
  static Future<void> upsert(
    DatabaseExecutor db, {
    required LinkPreview link,
  }) async {
    try {
      await db.insert(
        _tableName,
        link.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('❌ Error LinkPreviewDao.upsert: $e');
      rethrow;
    }
  }

  static Future<void> delete(DatabaseExecutor db, String noteId) async {
    await db.delete(_tableName, where: 'noteId = ?', whereArgs: [noteId]);
  }

  // 3. Operaciones en Batch (Para tu upsertAll de Notas)
  static void upsertBatch(Batch batch, LinkPreview link) {
    batch.insert(
      _tableName,
      link.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static void deleteBatch(Batch batch, String noteId) {
    batch.delete(_tableName, where: 'noteId = ?', whereArgs: [noteId]);
  }
}
