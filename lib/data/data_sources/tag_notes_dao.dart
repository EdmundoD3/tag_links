import 'package:sqflite/sqflite.dart';

class TagsNotesDao {
  static const String _tableName = "note_tags";

  // 1. Operación Individual (Inmediata)
  // Usamos DatabaseExecutor para que acepte tanto la DB como una Transaction
  static Future<void> upsert(
    DatabaseExecutor db, {
    required String tagId,
    required String noteId,
  }) async {
    await db.insert(_tableName, {
      'noteId': noteId,
      'tagId': tagId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<void> delete(
    DatabaseExecutor db, {
    required String tagId,
    required String noteId,
  }) async {
    await db.delete(
      _tableName,
      where: 'noteId = ? AND tagId = ?',
      whereArgs: [noteId, tagId],
    );
  }

  // 2. Operaciones en Batch (Sincronización masiva)
  static void upsertBatch(
    Batch batch, {
    required String tagId,
    required String noteId,
  }) {
    batch.insert(
      _tableName,
      {'noteId': noteId, 'tagId': tagId},
      conflictAlgorithm: ConflictAlgorithm
          .ignore, // Usamos ignore para no reescribir si ya existe
    );
  }

  static void deleteBatch(Batch batch, {required String noteId}) {
    batch.delete(_tableName, where: 'noteId = ?', whereArgs: [noteId]);
  }
}
