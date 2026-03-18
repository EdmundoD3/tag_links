import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tag_links/models/link_preview.dart';

class LinkPreviewDao {
  final String _tableName = 'link_previews';
  final Database _db;
  const LinkPreviewDao(this._db);

  Future<void> replace({
    required String noteId,
    Transaction? txn,
    LinkPreview? link,
  }) async {
    if (link == null) {
      // Si no hay link, solo borramos el que exista para esa nota
      await delete(txn, noteId);
    } else {
      // Si hay link, el upsert (ConflictAlgorithm.replace) se encarga de todo
      // Nota: Esto asume que el ID del link es el mismo o que solo quieres un link por nota.
      await upsert(txn: txn, link: link);
    }
  }

  Future<void> delete(Transaction? txn, String noteId) async {
    final db = txn ?? _db;
    await db.delete(_tableName, where: 'noteId = ?', whereArgs: [noteId]);
  }

  Future<void> upsert({required LinkPreview link, Transaction? txn}) async {
    try {
      // Usamos el ejecutor disponible (transacción o base de datos base)
      final executor = txn ?? _db;

      await executor.insert(
        _tableName,
        link.toMap(),
        // 🚀 UPSERT: Si el link ya existe (mismo id), lo actualiza con la nueva metadata
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('❌ error LinkPreviewDao.upsert: $e');
      rethrow; // Es mejor lanzar el error para que la transacción padre falle si es necesario
    }
  }

  void upsertBatch(Batch batch, LinkPreview link) {
    batch.insert(
      _tableName,
      link.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  void deleteBatch(Batch batch, String noteId) {
    batch.delete(_tableName, where: 'noteId = ?', whereArgs: [noteId]);
  }
}
