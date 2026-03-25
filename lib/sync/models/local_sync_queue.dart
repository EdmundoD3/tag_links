// Lo que vive en tu SQLite (Capa de Sincronización)
import 'package:tag_links/sync/models/archive_item.dart';

class LocalSyncQueue extends ArchiveItem {
  final String type; // 'note', 'folder', 'tag'
  final int syncStatus; // 0: pendiente, 1: sincronizado, 2: error
  
  LocalSyncQueue({
    required super.id, 
    required super.fileName, 
    required super.lastUpdate,
    required this.type,
    this.syncStatus = 0,
  });
   static LocalSyncQueue fromMap(Map<String, dynamic> map){
    return LocalSyncQueue(
      id: map['id'],
      fileName: map['fileName'],
      lastUpdate: map['lastUpdate'],
      type: map['type'],
      syncStatus: map['syncStatus'],
    );
  }
  @override
  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'fileName': fileName,
      'lastUpdate': lastUpdate,
      'type': type,
      'syncStatus': syncStatus,
    };
  }
}

final localSyncQueueTable = '''
  CREATE TABLE IF NOT EXISTS files (
    id TEXT PRIMARY KEY,
    fileName TEXT NOT NULL,
    lastUpdate INTEGER NOT NULL,
    type TEXT NOT NULL,
    syncStatus INTEGER NOT NULL
  );
''';