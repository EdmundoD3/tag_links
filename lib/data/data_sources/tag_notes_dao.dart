
import 'package:sqflite/sqflite.dart';

class TagsNotesDao {
  final String _tableName = "note_tags";
  final Database _db;

  TagsNotesDao(this._db);

  // 1. Método para INSERT/UPSERT
  // Usamos dynamic o un tipo genérico si prefieres,
  // pero lo importante es que acepte Batch, Transaction o Database.
  Future<void> upsert({
    required String tagId,
    required String noteId,
    dynamic executor, // Puede ser Transaction o Database
  }) async {
    final db = executor ?? _db;
    await db.insert(_tableName, {
      'noteId': noteId,
      'tagId': tagId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // 2. Método para DELETE
  Future<void> delete({
    required String tagId,
    required String noteId,
    dynamic executor,
  }) async {
    final db = executor ?? _db;
    await db.delete(
      _tableName,
      where: 'noteId = ? AND tagId = ?',
      whereArgs: [noteId, tagId],
    );
  }

  void deleteBatch(Batch batch, {required String noteId}) {
    batch.delete('note_tags', where: 'noteId = ?', whereArgs: [noteId]);
  }

  // 3. Método especial para BATCH (Sincronización masiva)
  void upsertBatch(
    Batch batch, {
    required String tagId,
    required String noteId,
  }) {
    batch.insert(_tableName, {
      'noteId': noteId,
      'tagId': tagId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
