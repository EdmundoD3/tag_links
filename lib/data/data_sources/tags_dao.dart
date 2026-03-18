import 'package:flutter/rendering.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/utils/paginated_utils.dart';

class TagsDao {
  final String _tableName = 'tags';
  final Database _db;
  TagsDao(this._db);

  Future<Tag?> upsert(Tag tag) async {
    try {
      final existedTag = await getByExactlyName(tag.name);
      if(existedTag != null) return existedTag;
      final newTag = await _db.insert(
        _tableName,
        tag.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      debugPrint("TagsDao.upsert: $newTag");
      return tag;
    } catch (e) {
      debugPrint('TagsDao.upsert error: ${e.toString()}');
      return null;
    }
  }

  Future<void> update(Tag tag) async {
    await _db.update(
      _tableName,
      tag.toMap(),
      where: 'id = ?',
      whereArgs: [tag.id],
    );
  }

  Future<void> delete(String id) async {
    await _db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<Tag?> getById(String id) async {
    final result = await _db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return null;

    return Tag.fromMap(result.first);
  }

  Future<List<Tag>> getAll({required PaginatedByUsage paginated}) async {
    final result = await _db.query(
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
    final result = await _db.query(
      _tableName,
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
      orderBy: paginated.orderSql,
      limit: paginated.limit,
    );
    return result.map(Tag.fromMap).toList();
  }

  Future<Tag?> getByExactlyName(String name) async {
    try {
      // Asegúrate de que el nombre no vaya con espacios accidentales
      final cleanName = name.trim();

      final result = await _db.query(
        _tableName,
        where: 'name = ?',
        whereArgs: [cleanName],
        limit: 1,
      );

      debugPrint("DAO: Query finalizada. Resultados: ${result.length}");

      if (result.isEmpty) return null;
      return Tag.fromMap(result.first);
    } catch (e) {
      debugPrint("Error: TagsDao.getByExactlyName: $e");
      return null;
    }
  }
}
