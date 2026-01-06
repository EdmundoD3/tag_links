import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/models/folder_tag.dart';
import 'package:tag_links/models/link_preview.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/models/note_tag.dart';
import 'package:tag_links/models/tag.dart';

class AppDatabase {
  static Database? _db;
  static String indexes = '''
      -- NOTES
        CREATE INDEX idx_notes_folder_updated
        ON notes(folderId, updatedAt DESC);

        CREATE INDEX idx_notes_favorite_updated
        ON notes(isFavorite, updatedAt DESC);

        -- TAGS
        CREATE INDEX idx_note_tags_tag_note
        ON note_tags(tagId, noteId);

        -- FOLDERS
        CREATE INDEX idx_folders_parentId
        ON folders(parentId);

        -- LINKS
        CREATE INDEX idx_link_noteId
        ON link_previews(noteId);
''';

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'app.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('PRAGMA foreign_keys = ON');

        await db.execute(folderTable);
        await db.execute(tagTable);
        await db.execute(noteTable);
        await db.execute(linkPreviewTable);
        await db.execute(folderTagTable);
        await db.execute(noteTagTable);

        await db.execute(indexes);
      },
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }
}
