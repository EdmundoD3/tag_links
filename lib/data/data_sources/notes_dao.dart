import 'package:sqflite/sqflite.dart';
import 'package:tag_links/data/database.dart';
import 'package:tag_links/models/note.dart';

class NotesDao {
  Future<Database> get _db async => AppDatabase().database;

  Future<void> insert(Note note) async {
    final db = await _db;
    await db.insert('notes', note.toMap());
  }

  Future<void> update(Note note) async {
    final db = await _db;
    await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Note>> getByFolder(String folderId) async {
    final db = await _db;
    final result = await db.query(
      'notes',
      where: 'folderId = ?',
      whereArgs: [folderId],
      orderBy: 'createdAt DESC',
    );

    return result.map(Note.fromMap).toList();
  }

  Future<List<Note>> getFavorites() async {
    final db = await _db;
    final result = await db.query(
      'notes',
      where: 'isFavorite = 1',
      orderBy: 'updatedAt DESC',
    );

    return result.map(Note.fromMap).toList();
  }

  Future<Note?> getById(String id) async {
    final db = await _db;
    final result = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return Note.fromMap(result.first);
  }
}
