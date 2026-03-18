import 'package:sqflite/sqflite.dart';

class FolderTagsDao {
  final String _tableName = 'folder_tags';
  final Database _db;

  FolderTagsDao(this._db);

  // 1. Operación Individual o Transaccional
  // Usamos 'dynamic' para que acepte tanto la Database como una Transaction
  Future<void> upsert({
    required String folderId,
    required String tagId,
    dynamic executor,
  }) async {
    final db = executor ?? _db;
    await db.insert(
      _tableName,
      {
        'folderId': folderId,
        'tagId': tagId,
      },
      // Usamos IGNORE porque si la relación ya existe, no hay nada que actualizar
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // 2. Borrado Individual o Transaccional
  Future<void> delete({
    required String folderId,
    required String tagId,
    dynamic executor,
  }) async {
    final db = executor ?? _db;
    await db.delete(
      _tableName,
      where: 'folderId = ? AND tagId = ?',
      whereArgs: [folderId, tagId],
    );
  }

  // 3. Borrado masivo de etiquetas de una carpeta (Útil para el upsertAll)
  void deleteBatch(Batch batch, {required String folderId}) {
    batch.delete(
      _tableName,
      where: 'folderId = ?',
      whereArgs: [folderId],
    );
  }

  // 4. Inserción masiva para Sincronización (Batch)
  void upsertBatch(Batch batch, {required String folderId, required String tagId}) {
    batch.insert(
      _tableName,
      {
        'folderId': folderId,
        'tagId': tagId,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }
}