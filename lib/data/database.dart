import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tag_links/data/data_sources/deleted_dao.dart';
import 'package:tag_links/models/folder.dart';
import 'package:tag_links/models/folder_preference.dart';
import 'package:tag_links/models/folder_tag.dart';
import 'package:tag_links/models/link_preview.dart';
import 'package:tag_links/models/note.dart';
import 'package:tag_links/models/note_tag.dart';
import 'package:tag_links/models/tag.dart';
import 'package:tag_links/sync/models/local_sync_queue.dart';

class AppDatabase {
  Future<String> get dbPath async {
    final path = await getDatabasesPath();
    return join(path, 'app.db');
  }

  static Database? _db;
  static List<String> indexes = [
    // -- NOTES
    'CREATE INDEX idx_notes_folder_updated ON notes(folderId, updatedAt DESC);',
    'CREATE INDEX idx_notes_favorite_updated ON notes(isFavorite, updatedAt DESC);',
    'CREATE INDEX idx_notes_sync ON notes(updatedAt, syncAt);',

    // -- TAGS
    'CREATE INDEX idx_note_tags_tag_note ON note_tags(tagId, noteId);',

    // -- FOLDERS
    'CREATE INDEX idx_folders_parentId ON folders(parentId);',
    'CREATE INDEX idx_folders_sync ON folders(updatedAt, syncAt);',
    // -- LINKS
    'CREATE INDEX idx_link_noteId ON link_previews(noteId);',
  ];
  static List<String> triggers = [
    // -- TRIGGERS PARA NOTAS
    '''
    CREATE TRIGGER IF NOT EXISTS tr_note_tags_insert
    AFTER INSERT ON note_tags
    BEGIN
      UPDATE tags SET usageCount = usageCount + 1 WHERE id = NEW.tagId;
    END;
    ''',
    '''
      CREATE TRIGGER IF NOT EXISTS tr_note_tags_delete
      AFTER DELETE ON note_tags
      BEGIN
        UPDATE tags SET usageCount = MAX(usageCount - 1, 0) WHERE id = OLD.tagId;
      END;
    ''',
    // -- TRIGGERS PARA CARPETAS
    '''
      CREATE TRIGGER IF NOT EXISTS tr_folder_tags_insert
      AFTER INSERT ON folder_tags
      BEGIN
        UPDATE tags SET usageCount = usageCount + 1 WHERE id = NEW.tagId;
      END;
    ''',
    '''
      CREATE TRIGGER IF NOT EXISTS tr_folder_tags_delete
      AFTER DELETE ON folder_tags
      BEGIN
        UPDATE tags SET usageCount = MAX(usageCount - 1, 0) WHERE id = OLD.tagId;
      END;
    ''',
  ];

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final String path = await dbPath;

    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.rawQuery('PRAGMA journal_mode=WAL');
        await db.rawQuery('PRAGMA synchronous=NORMAL');
        // 🚀 Activar llaves foráneas aquí es más seguro
        await db.rawQuery('PRAGMA foreign_keys = ON');
        // 🚀 Opcional: Activar triggers recursivos si quieres que el CASCADE dispare tus triggers
        await db.rawQuery('PRAGMA recursive_triggers = ON');
      },
      onCreate: (db, version) async {
        await db.execute('PRAGMA foreign_keys = ON');

        //tablas
        await db.execute(localSyncQueueTable);
        await db.execute(folderTable);
        await db.execute(tagTable);
        await db.execute(noteTable);
        await db.execute(linkPreviewTable);
        await db.execute(folderTagTable);
        await db.execute(noteTagTable);
        await db.execute(folderPreferencesTable);
        await db.execute(DeletedTables.deletedFoldersTable);
        await db.execute(DeletedTables.deletedNotesTable);
        


        //triggers
        for (var trigger in triggers) {
          await db.execute(trigger);
        }
        for (var index in indexes) {
          await db.execute(index);
        }
      },
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }
}

final databaseProvider = Provider<Database>((ref) {
  throw UnimplementedError();
});
