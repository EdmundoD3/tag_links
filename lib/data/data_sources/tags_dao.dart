import 'package:sqflite/sqflite.dart';
import 'package:tag_links/data/database.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/utils/paginated_utils.dart';

class TagsDao {
  final String _tableName = 'tags';
  Future<Database> get _db async => AppDatabase().database;
  Future<void> insert(Tag tag) async {
    final db = await _db;

    await db.insert(
      _tableName,
      tag.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(Tag tag) async {
    final db = await _db;

    await db.update(_tableName, tag.toMap(), where: 'id = ?', whereArgs: [tag.id]);
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<Tag?> getById(String id) async {
    final db = await _db;

    final result = await db.query(_tableName, where: 'id = ?', whereArgs: [id]);

    if (result.isEmpty) return null;

    return Tag.fromMap(result.first);
  }

  Future<List<Tag>> getAll({required PaginatedByUsage paginated}) async {
    final db = await _db;

    final result = await db.query(
      _tableName,
      orderBy: paginated.orderSql,
      limit: paginated.limit,
      offset: paginated.offset,
    );

    return result.map(Tag.fromMap).toList();
  }

  Future<List<Tag>> getByName(
    String name, {
    required PaginatedByUsage paginated,
  }) async {
    final db = await _db;

    final result = await db.query(
      _tableName,
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
      orderBy: paginated.orderSql,
      limit: paginated.limit,
    );
    return result.map(Tag.fromMap).toList();
  }

}
