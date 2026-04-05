// Lo que vive en tu SQLite (Capa de Sincronización)
import 'package:tag_links/sync/models/archive_item.dart';

class LocalSyncQueue extends ArchiveItem {
  final String type; // 'note', 'folder', 'tag'
  final int syncStatus; // 0: pendiente, 1: sincronizado, 2: error
  final int itemCount;

  LocalSyncQueue({
    required super.id,
    super.driveFileId,
    required super.fileName,
    required super.lastUpdate,
    required this.type,
    this.syncStatus = 0,
    required this.itemCount,
  });
  static LocalSyncQueue fromMap(Map<String, dynamic> map) {
    return LocalSyncQueue(
      id: map['id'],
      driveFileId: map['driveFileId'],
      fileName: map['fileName'],
      lastUpdate: map['lastUpdate'],
      type: map['type'],
      syncStatus: map['syncStatus'],
      itemCount: map['itemCount'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'driveFileId':
          driveFileId, // <--- INDISPENSABLE para no perder el ID de Drive
      'fileName': fileName,
      'lastUpdate': lastUpdate,
      'type': type,
      'syncStatus': syncStatus,
      'itemCount': itemCount,
    };
  }
}

enum TypeQueue {
  notes,
  folders,
  tags;

  String get tableName {
    switch (this) {
      case TypeQueue.notes:
        return 'notes';
      case TypeQueue.folders:
        return 'folders';
      case TypeQueue.tags:
        return 'tags';
    }
  }
}

// En tu LocalSyncQueue podrías añadir constantes o un Enum para no liarte con los números
class SyncStatus {
  static const int localOnly = 0;
  static const int synced = 1;
  static const int dirty = 2;
  static const int error = 3;
}

final localSyncQueueTable = '''
CREATE TABLE IF NOT EXISTS files (
    id TEXT PRIMARY KEY,       -- Tu ID interno (ej: 'notes_bucket_1', UUID, o auto-increment)
    driveFileId TEXT,          -- El ID que te da Google Drive (NULL hasta que se suba)
    fileName TEXT NOT NULL,    -- Nombre legible: 'notes_part_1.json'
    lastUpdate INTEGER NOT NULL,
    type TEXT NOT NULL,        -- 'notes', 'folders', 'tags'
    syncStatus INTEGER NOT NULL, -- 0: Local-Only, 1: Synced, 2: Dirty
    itemCount INTEGER DEFAULT 0
);
''';
