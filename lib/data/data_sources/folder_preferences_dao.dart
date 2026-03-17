import 'package:sqflite/sqflite.dart';
import 'package:tag_links/models/folder_preference.dart';

class FolderPreferencesDao {
  final String _tableName = 'folder_preferences';
  final Database _db;
  FolderPreferencesDao({required Database db}) : _db = db;

  Future<FolderDefaultView> getDefaultView(String folderId) async {
    final result = await _db.query(
      _tableName,
      where: 'folderId = ?',
      whereArgs: [folderId],
    );

    if (result.isEmpty) return FolderDefaultView.folders;
    return FolderPreference.fromMap(result.first).defaultView;
  }

  Future<void> upsert(FolderPreference folderPreference) async {
    int count = await _db.update(
      _tableName,
      folderPreference.toMap(),
      where: 'folderId = ?',
      whereArgs: [folderPreference.folderId],
    );

    if (count == 0) {
      await _db.insert(
        _tableName,
        folderPreference.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore, // Por seguridad
      );
    }
  }
}
