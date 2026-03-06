import 'package:sqflite/sqflite.dart';
import 'package:tag_links/models/folder_preference.dart';

class FolderPreferencesDao {
  final String _tableName = 'folder_preferences';
  final Database _db;
  FolderPreferencesDao({required Database db}) : _db = db;

  Future<void> save(FolderPreference pref) async {
    await _db.insert(
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
    await _db.update(
      _tableName,
      folderPreference.toMap(),
      where: 'folderId = ?',
      whereArgs: [folderPreference.folderId],
    );
  }

  Future<void> delete(String folderId) async {
    await _db.delete(_tableName, where: 'folderId = ?', whereArgs: [folderId]);
  }

  Future<FolderPreference?> _getByFolderId(String folderId) async {
    final result = await _db.query(
      _tableName,
      where: 'folderId = ?',
      whereArgs: [folderId],
    );

    if (result.isEmpty) return null;

    return FolderPreference.fromMap(result.first);
  }
}
