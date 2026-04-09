import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/google/auth_provider.dart';
import 'package:tag_links/repository/deletes_repository.dart';
import 'package:tag_links/repository/folder_repository.dart';
import 'package:tag_links/repository/notes_repository.dart';
import 'package:tag_links/repository/tags_repository.dart';
import 'package:tag_links/sync/db/local_sync_queue_repository.dart';
import 'package:tag_links/sync/drive_data_service.dart';
import 'package:tag_links/sync/models/archive_info.dart';
import 'package:tag_links/sync/models/archive_item.dart';
import 'package:tag_links/sync/models/sync_file_wrapper.dart';
import 'package:tag_links/sync/models/local_sync_queue.dart';

class SyncPusher {
  final LocalSyncQueueRepository _syncQueueRepo;
  final DriveDataService _driveDataService;
  final NotesRepository _notesRepo;
  final FolderRepository _folderRepo;
  final TagsRepository _tagsRepo;
  final DeletesRepository _deletesRepo;

  SyncPusher({
    required LocalSyncQueueRepository syncQueueRepo,
    required DriveDataService driveDataService,
    required NotesRepository notesRepo,
    required FolderRepository folderRepo,
    required TagsRepository tagsRepo,
    required DeletesRepository deletesRepo,
  }) : _syncQueueRepo = syncQueueRepo,
       _driveDataService = driveDataService,
       _notesRepo = notesRepo,
       _folderRepo = folderRepo,
       _tagsRepo = tagsRepo,
       _deletesRepo = deletesRepo;

  /// Procesa las subidas pendientes de "Buckets" sucios.
  Future<ArchiveInfo> pushLocalChanges({
    required ArchiveInfo currentArchive,
    int maxFiles = 10,
  }) async {
    // 1. MANTENIMIENTO PREVIO
    // Limpiamos localmente. Si algo se borra, marcará su bucket como 'dirty'.
    try {
      await _deletesRepo.cleanOldDeletes(days: 15);
    } catch (e) {
      debugPrint("SyncPusher: Error en mantenimiento preventivo: $e");
      // No lanzamos excepción aquí para no detener el Push si la limpieza falla
    }

    ArchiveInfo workingArchive = currentArchive;
    int filesProcessed = 0;
    final int now = DateTime.now().millisecondsSinceEpoch;

    // 2. OBTENER ARCHIVOS (Incluirá el de borrados si la limpieza hizo cambios)
    final dirtyFiles = await _syncQueueRepo.getDirtyFiles(limit: maxFiles);

    debugPrint(
      "SyncPusher.pushLocalChanges: ${dirtyFiles.length} dirty files found. ${dirtyFiles.map((e) => e.fileName).join(', ')}",
    );
    for (var fileMeta in dirtyFiles) {
      if (filesProcessed >= maxFiles) break;

      try {
        final type = TypeQueue.fromString(fileMeta.type);
        final SyncFileWrapper wrapper = await _createWrapper(type, fileMeta);
        final driveId = await _driveDataService.uploadArray(
          items: [wrapper],
          toMap: (w) => w.toMap(),
          fileName: fileMeta.fileName,
          existingFileId: fileMeta.driveFileId,
        );

        if (driveId == null || driveId.isEmpty) {
          throw Exception("Drive no devolvió un ID válido");
        }

        await _syncQueueRepo.markAsSynced(
          bucketId: fileMeta.id,
          driveFileId: driveId,
          timestamp: now,
        );

        workingArchive = _updateArchiveInfo(
          info: workingArchive,
          type: type,
          driveId: driveId,
          localId: fileMeta.id,
          fileName: fileMeta.fileName,
          now: now,
        );

        filesProcessed++;
        debugPrint("SyncPusher: ✅ Bucket ${fileMeta.fileName} sincronizado.");
      } catch (e) {
        debugPrint("SyncPusher: ❌ Error en bucket ${fileMeta.id}: $e");
      }
    }

    return workingArchive;
  }

  /// Helper para crear el Wrapper correcto según el tipo
  Future<SyncFileWrapper> _createWrapper(
    TypeQueue type,
    LocalSyncQueue meta,
  ) async {
    final now = DateTime.now();

    return switch (type) {
      TypeQueue.notes => await _notesRepo.getFileWrapper(
        fileId: meta.id,
        driveFileId: meta.driveFileId,
        now: now,
      ),
      TypeQueue.folders => await _folderRepo.getFileWrapper(
        fileId: meta.id,
        driveFileId: meta.driveFileId,
        now: now,
      ),
      TypeQueue.tags => await _tagsRepo.getFileWrapper(
        fileId: meta.id,
        driveFileId: meta.driveFileId,
        now: now,
      ),
      TypeQueue.deletes => await _deletesRepo.getDeleteFileWrapper(meta),
    };
  }

  /// Actualiza la lista de ArchiveItems para el config.json
  ArchiveInfo _updateArchiveInfo({
    required ArchiveInfo info,
    required TypeQueue type,
    required String driveId,
    required String localId,
    required String fileName,
    required int now,
  }) {
    final newItem = ArchiveItem(
      id: localId, // Tu ID local (UUID)
      driveFileId: driveId, // El ID de Google Drive
      fileName: fileName,
      lastUpdate: now,
      type: type.tableName,
    );

    return switch (type) {
      TypeQueue.tags => info.copyWith(
        tags: _mergeArchiveList(info.tags, newItem),
      ),
      TypeQueue.folders => info.copyWith(
        folders: _mergeArchiveList(info.folders, newItem),
      ),
      TypeQueue.notes => info.copyWith(
        notes: _mergeArchiveList(info.notes, newItem),
      ),
      TypeQueue.deletes => info.copyWith(
        deletes: _mergeArchiveList(info.deletes, newItem),
      ), // 🎯 Agregado
    };
  }

  List<ArchiveItem> _mergeArchiveList(
    List<ArchiveItem> list,
    ArchiveItem newItem,
  ) {
    final index = list.indexWhere((item) => item.id == newItem.id);
    if (index != -1) {
      final newList = List<ArchiveItem>.from(list);
      newList[index] = newItem;
      return newList;
    }
    return [...list, newItem];
  }
}

final syncPusherProvider = Provider<SyncPusher?>((ref) {
  // Observamos el estado de autenticación
  final auth = ref.watch(authProvider);

  // Si no hay API de Drive, el Pusher no debería existir
  if (auth.driveApi == null) return null;

  return SyncPusher(
    syncQueueRepo: ref.watch(localSyncQueueRepositoryProvider),
    driveDataService: DriveDataService(auth.driveApi!),
    folderRepo: ref.watch(folderRepositoryProvider),
    notesRepo: ref.watch(notesRepositoryProvider),
    tagsRepo: ref.watch(tagsRepositoryProvider),
    deletesRepo: ref.watch(deletesRepositoryProvider),
  );
});
