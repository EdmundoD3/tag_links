import 'package:sqflite/sqflite.dart';
import 'package:tag_links/data/database.dart';
import 'package:tag_links/models/link_preview.dart';

class LinkPreviewDao {
  final String _tableName = 'link_previews';
  Future<Database> get _db async => AppDatabase().database;
  Future<void> replace({
    required String noteId,
    Transaction? txn,
    LinkPreview? link,
  }) async {
    await delete(txn, noteId);

    if (link != null) {
      await insert(txn, noteId, link);
    }
  }

  Future<void> delete(Transaction? txn, String noteId) async {
    final db = txn ?? await _db;
    await db.delete(_tableName, where: 'noteId = ?', whereArgs: [noteId]);
  }

  Future<void> insert(Transaction? txn, String noteId, LinkPreview link) async {
    final db = txn ?? await _db;
    await db.insert(_tableName, {
      'id': link.id,
      'noteId': noteId,
      'url': link.url,
      'title': link.title,
      'description': link.description,
      'image': link.image,
      'siteName': link.siteName,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
