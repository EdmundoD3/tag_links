import 'package:sqflite/sqflite.dart';

class DeletedTables {
  static final deletedFoldersTable = DeletedFoldersDao.table;
  static final deletedNotesTable = DeletedNotesDao.table;
  static final deletedTagsTable = DeletedTagsDao.table; // <--- Agregado
}

class DeletedTagsDao {
  final _DeletedDao _dao;
  
  DeletedTagsDao({required Database db})
    : _dao = _DeletedDao(tableName: 'deleted_tags', db: db);

  // Genera el SQL para la tabla de tags borrados
  static String get table => _DeletedDao.getTable('deleted_tags');

  Future<void> saveId(String id, {Transaction? executor}) => 
      _dao.saveId(id, executor: executor);

  Future<List<DeletedData>> getBatch({int limit = 500}) => 
      _dao.getBatch(limit: limit);

  Future<void> deleteIds(List<String> ids) => 
      _dao.deleteIds(ids);
}

class DeletedFoldersDao {
  final _DeletedDao _dao;
  DeletedFoldersDao({required Database db})
    : _dao = _DeletedDao(tableName: DeletedFoldersDao.table, db: db);

  static String get table => _DeletedDao.getTable('deleted_folders');

  Future<void> saveId(String id, {Transaction? executor}) => _dao.saveId(id,executor: executor);

  Future<List<DeletedData>> Function({int limit}) get getBatch => _dao.getBatch;
  Future<void> Function(List<String> ids) get deleteIds => _dao.deleteIds;
}

class DeletedNotesDao {
  final _DeletedDao _dao;
  DeletedNotesDao({required Database db})
    : _dao = _DeletedDao(tableName: DeletedNotesDao.table, db: db);

  static String get table => _DeletedDao.getTable('deleted_notes');

  Future<void> saveId(String id, {Transaction? executor}) => _dao.saveId(id,executor: executor);

  Future<List<DeletedData>> Function({int limit}) get getBatch => _dao.getBatch;
  Future<void> Function(List<String> ids) get deleteIds => _dao.deleteIds;
}

// -----------------
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

class _DeletedDao {
  final String tableName;
  final Database _db;
// Fix: Asignación correcta en el constructor
  _DeletedDao({required this.tableName, required Database db}) : _db = db;

  static String getTable(String tableName) => '''
    CREATE TABLE IF NOT EXISTS $tableName (
      id TEXT PRIMARY KEY,
      deletedAt INTEGER NOT NULL
    );
  ''';

  Future<void> saveId(String id, {Transaction? executor}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final db = executor ?? _db; 

    await db.insert(
      tableName,
      {'id': id, 'deletedAt': now},
      conflictAlgorithm: ConflictAlgorithm.replace,
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
