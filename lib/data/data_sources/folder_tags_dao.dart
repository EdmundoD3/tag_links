import 'package:sqflite/sqflite.dart';

class FolderTagsDao {
  static const String _tableName = 'folder_tags';

  // Un solo método para individual/transacción
  static Future<void> upsert(
    DatabaseExecutor db, { // Acepta Database o Transaction
    required String folderId,
    required String tagId,
  }) async {
    await db.insert(
      _tableName,
      {'folderId': folderId, 'tagId': tagId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }
    static Future<void> upsertBatch(
    Batch db, { // Acepta Database o Transaction
    required String folderId,
    required String tagId,
  }) async {
    db.insert(
      _tableName,
      {'folderId': folderId, 'tagId': tagId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<void> delete(
    DatabaseExecutor db, {
    required String folderId,
    required String tagId,
  }) async {
    await db.delete(
      _tableName,
      where: 'folderId = ? AND tagId = ?',
      whereArgs: [folderId, tagId],
    );
  }

  // Batch sigue siendo especial porque no es async de la misma forma
  static void deleteBatch(Batch batch, {required String folderId}) {
    batch.delete(_tableName, where: 'folderId = ?', whereArgs: [folderId]);
  }
}