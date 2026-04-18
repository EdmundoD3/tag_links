import 'package:tag_links/sync/models/local_sync_queue.dart';

class LocalSyncConfig {
  static const _notesLimit = 100;
  static const _foldersLimit = 200; 
  static const _tagsLimit = 300;
  static const _deletesLimit = 500;  // Muy ligeros

  static int getLimit(TypeQueue type) {
    switch (type) {
      case TypeQueue.notes:
        return _notesLimit;
      case TypeQueue.folders:
        return _foldersLimit;
      case TypeQueue.tags:
        return _tagsLimit;
      case TypeQueue.deletes:
        return _deletesLimit;
    }
  }
}