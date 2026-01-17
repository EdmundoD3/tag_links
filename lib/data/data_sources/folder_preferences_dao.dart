import 'package:sqflite/sqflite.dart';
import 'package:tag_links/data/database.dart';
import 'package:tag_links/models/folder_preference.dart';

class FolderPreferencesDao {
  final String _tableName = 'folder_preferences';
  Future<Database> get _db async => AppDatabase().database;

  Future<void> save(FolderPreference pref) async {
    final db = await _db;
    await db.insert(
      _tableName,
      pref.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<FolderDefaultView> getDefaultView(String folderId) async {
    final pref = await _getByFolderId(folderId);
    return pref?.defaultView ?? FolderDefaultView.folders;
  }

  Future<void> update(FolderPreference folderPreference) async {
    final db = await _db;

    await db.update(
      _tableName,
      folderPreference.toMap(),
      where: 'folderId = ?',
      whereArgs: [folderPreference.folderId],
    );
  }

  Future<void> delete(String folderId) async {
    final db = await _db;
    await db.delete(_tableName, where: 'folderId = ?', whereArgs: [folderId]);
  }

  Future<FolderPreference?> _getByFolderId(String folderId) async {
    final db = await _db;

    final result = await db.query(
      _tableName,
      where: 'folderId = ?',
      whereArgs: [folderId],
    );

    if (result.isEmpty) return null;

    return FolderPreference.fromMap(result.first);
  }
}
