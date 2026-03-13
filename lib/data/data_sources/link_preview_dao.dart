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
    await delete(txn, noteId);

    if (link != null) {
      await insert(txn: txn,noteId: noteId, link: link);
    }
  }

  Future<void> delete(Transaction? txn, String noteId) async {
    final db = txn ?? _db;
    await db.delete(_tableName, where: 'noteId = ?', whereArgs: [noteId]);
  }

  Future<int?> insert({required String noteId, required LinkPreview link, Transaction? txn}) async {
    final db = txn ?? _db;
    try {
      return db.insert(_tableName, {
      'id': link.id,
      'noteId': noteId,
      'url': link.url,
      'title': link.title,
      'description': link.description,
      'image': link.image,
      'siteName': link.siteName,
    });
    } catch (e) {
      debugPrint('error LinkPreviewDao.insert: $e');
      return null;
    }
    
  }
}
