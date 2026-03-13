import 'package:sqflite/sqflite.dart';

class DeletedTables {
  static final deletedFoldersTable = DeletedFoldersDao.table;
  static final deletedNotesTable = DeletedNotesDao.table;
}

class DeletedData {
  final String id;
  final int deletedAt;

  DeletedData({required this.id, required this.deletedAt});
  Map<String, Object> toMap() => {'id': id, 'deletedAt': deletedAt};
  factory DeletedData.fromRaw(Map<String, Object?> raw) {
    return DeletedData(
      id: raw['id'] as String,
      deletedAt: raw['deletedAt'] as int,
    );
  }
}

class DeletedFoldersDao {
  final _DeletedDao _dao;
  DeletedFoldersDao({required Database db}) : _dao = _DeletedDao(tableName: DeletedFoldersDao.table, db: db);

  static String get table => _DeletedDao.getTable('deleted_folders');

  Future<void> saveId(String id) => _dao.saveId(id);

  Future<List<DeletedData>> Function({int limit}) get getBatch => _dao.getBatch;
  Future<void> Function(List<String> ids) get deleteIds => _dao.deleteIds;
}

class DeletedNotesDao {
  final _DeletedDao _dao;
  DeletedNotesDao({required Database db}) : _dao = _DeletedDao(tableName: DeletedNotesDao.table, db: db);

  static String get table => _DeletedDao.getTable('deleted_notes');

  Future<void> saveId(String id) => _dao.saveId(id);

  Future<List<DeletedData>> Function({int limit}) get getBatch => _dao.getBatch;
  Future<void> Function(List<String> ids) get deleteIds => _dao.deleteIds;
}

class _DeletedDao {
  final String tableName;

  _DeletedDao({required this.tableName, required Database db}) : _db = db;

  static String getTable(String tableName) =>
      '''
    CREATE TABLE IF NOT EXISTS $tableName (
      id TEXT PRIMARY KEY,
      deletedAt INTEGER NOT NULL
    );
  ''';

  final Database _db;

  Future<void> saveId(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final data = DeletedData(id: id, deletedAt: now);

    await _db.insert(
      tableName,
      data.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<DeletedData>> getBatch({int limit = 500}) async {
    final result = await _db.query(
      tableName,
      limit: limit,
      orderBy: 'deletedAt ASC',
    );

    return result.map(DeletedData.fromRaw).toList();
  }

  Future<void> deleteIds(List<String> ids) async {
    if (ids.isEmpty) return;

    final placeholders = List.filled(ids.length, '?').join(',');
    await _db.delete(tableName, where: 'id IN ($placeholders)', whereArgs: ids);
  }
}
