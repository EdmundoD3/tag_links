import 'package:flutter/foundation.dart';
import 'package:tag_links/repository/folder_repository.dart';
import 'package:tag_links/repository/notes_repository.dart';
import 'package:tag_links/repository/tags_repository.dart';
import 'package:tag_links/sync/db/local_sync_queue_repository.dart';
import 'package:tag_links/sync/drive_data_service.dart';
import 'package:tag_links/sync/models/archive_info.dart';
import 'package:tag_links/sync/models/archive_item.dart';
import 'package:tag_links/sync/models/local_sync_queue.dart';
import 'package:tag_links/sync/models/notes_file.dart'; // Tus Wrappers
import 'package:tag_links/sync/models/folders_file.dart';
import 'package:tag_links/sync/models/tags_file.dart';

class SyncPusher {
  final LocalSyncQueueRepository _syncQueueRepo;
  final DriveDataService _driveDataService;
  final NotesRepository _notesRepo;
  final FolderRepository _folderRepo;
  final TagsRepository _tagsRepo;

  SyncPusher({
    required LocalSyncQueueRepository syncQueueRepo,
    required DriveDataService driveDataService,
    required NotesRepository notesRepo,
    required FolderRepository folderRepo,
    required TagsRepository tagsRepo,
  }) : _syncQueueRepo = syncQueueRepo,
       _driveDataService = driveDataService,
       _notesRepo = notesRepo,
       _folderRepo = folderRepo,
       _tagsRepo = tagsRepo;

  /// Procesa las subidas pendientes limitando a N archivos para cuidar la cuota.
  Future<ArchiveInfo> pushLocalChanges({
    required ArchiveInfo currentArchive,
    int maxFiles = 10,
  }) async {
    ArchiveInfo workingArchive = currentArchive;
    int filesProcessed = 0;
    final int now = DateTime.now().millisecondsSinceEpoch;

    // Iteramos por categorías para dar prioridad (Tags -> Folders -> Notes)
    final categories = [TypeQueue.tags, TypeQueue.folders, TypeQueue.notes];

    for (var type in categories) {
      if (filesProcessed >= maxFiles) break;

      // 1. Obtenemos solo los IDs de los buckets "sucios"
      final dirtyIds = await _syncQueueRepo.getDirtyFileIds(type);

      for (var localId in dirtyIds) {
        if (filesProcessed >= maxFiles) break;

        try {
          final LocalSyncQueue fileMeta = await _syncQueueRepo.getById(localId);
          if (fileMeta == null) continue;

          // 2. Preparamos el Wrapper con los datos reales
          final dynamic wrapper = await _createWrapper(type, fileMeta);
          if (wrapper == null) continue;

          // 3. Subimos usando tu uploadArray (tu función ya maneja create vs update)
          // Usamos una lista de un solo elemento porque es un Wrapper que contiene la lista real
          final driveId = await _driveDataService.uploadArray(
            items: [wrapper],
            toMap: (w) => w.toMap(),
            fileName: fileMeta.fileName,
            existingFileId: fileMeta.driveFileId,
          );

          // 4. Actualización Local: Marcamos como sincronizado
          if (driveId == null || driveId.isEmpty) {
            throw Exception("Drive no devolvió un ID válido");
          }
          await _syncQueueRepo.markItemsAsSynced(
            type: type,
            id: localId,
            syncTimestamp: now,
            fileId: driveId, // IMPORTANTE: Guardamos el ID que nos dio Drive
          );

          // 5. Actualización de la Configuración:
          workingArchive = _updateArchiveInfo(
            workingArchive,
            type,
            driveId,
            fileMeta.id,
            fileMeta.fileName,
            now,
          );

          filesProcessed++;
          debugPrint(
            "SyncPusher: Subido con éxito bucket ${fileMeta.fileName}",
          );
        } catch (e) {
          debugPrint("SyncPusher Error en bucket $localId: $e");
        }
      }
    }

    return workingArchive;
  }

  /// Helper para crear el Wrapper correcto según el tipo
  Future<dynamic> _createWrapper(TypeQueue type, LocalSyncQueue meta) async {
    final now = DateTime.now();
    switch (type) {
      case TypeQueue.tags:
        final items = await _tagsRepo.getByFileId(meta.id);
        return TagsFile(
          id: meta.id,
          fileId: meta.driveFileId ?? '',
          tags: items,
          createdAt: now,
          updatedAt: now,
        );
      case TypeQueue.folders:
        final items = await _folderRepo.getByFileId(meta.id);
        return FoldersFile(
          id: meta.id,
          fileId: meta.driveFileId ?? '',
          folders: items,
          createdAt: now,
          updatedAt: now,
        );
      case TypeQueue.notes:
        final items = await _notesRepo.getByFileId(meta.id);
        return NotesFile(
          id: meta.id,
          fileId: meta.driveFileId ?? '',
          notes: items,
          createdAt: now,
          updatedAt: now,
        );
    }
  }

  /// Actualiza la lista de ArchiveItems para el config.json
  ArchiveInfo _updateArchiveInfo(
    ArchiveInfo info,
    TypeQueue type,
    String driveId,
    String localId,
    String fileName,
    int now,
  ) {
    final newItem = ArchiveItem(
      id: localId, // Tu ID local (UUID)
      driveFileId: driveId, // El ID de Google Drive
      fileName: fileName,
      lastUpdate: now,
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
