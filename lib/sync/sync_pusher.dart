import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/google/auth_provider.dart';
import 'package:tag_links/repository/folder_repository.dart';
import 'package:tag_links/repository/notes_repository.dart';
import 'package:tag_links/repository/tags_repository.dart';
import 'package:tag_links/sync/db/local_sync_queue_repository.dart';
import 'package:tag_links/sync/drive_data_service.dart';
import 'package:tag_links/sync/models/archive_info.dart';
import 'package:tag_links/sync/models/archive_item.dart';
import 'package:tag_links/sync/models/sync_file_wrapper.dart';
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
/// Procesa las subidas pendientes de "Buckets" sucios.
Future<ArchiveInfo> pushLocalChanges({
  required ArchiveInfo currentArchive,
  int maxFiles = 10,
}) async {
  ArchiveInfo workingArchive = currentArchive;
  int filesProcessed = 0;
  final int now = DateTime.now().millisecondsSinceEpoch;

  // 1. Obtenemos TODOS los archivos sucios (LocalOnly o Dirty)
  // El Repo ya nos devuelve objetos LocalSyncQueue ordenados por importancia
  final dirtyFiles = await _syncQueueRepo.getDirtyFiles(limit: maxFiles);

  for (var fileMeta in dirtyFiles) {
    if (filesProcessed >= maxFiles) break;

    try {
      // Determinamos el tipo de contenido basado en el type del bucket
      final type = _getTypeQueueFromStr(fileMeta.type);

      // 2. Preparamos el Wrapper con los datos reales del bucket
      // _createWrapper debe consultar la tabla (notes/folders/tags) 
      // filtrando por where: 'fileId = ?', fileMeta.id
      final SyncFileWrapper? wrapper = await _createWrapper(type, fileMeta);

      if (wrapper == null) {
        // Si el bucket está vacío en DB pero marcado como sucio, lo limpiamos
        await _syncQueueRepo.markAsSynced(
          bucketId: fileMeta.id,
          driveFileId: fileMeta.driveFileId ?? '',
          timestamp: now,
        );
        debugPrint("SyncPusher: Bucket ${fileMeta.fileName} vacío. Ignorado.");
        continue;
      }

      // 3. Subida a Google Drive
      // uploadArray detecta si 'existingFileId' es null para hacer CREATE o UPDATE
      final driveId = await _driveDataService.uploadArray(
        items: [wrapper],
        toMap: (w) => w.toMap(),
        fileName: fileMeta.fileName,
        existingFileId: fileMeta.driveFileId,
      );

      if (driveId == null || driveId.isEmpty) {
        throw Exception("Drive no devolvió un ID válido");
      }

      // 4. Actualización Local: El bucket ahora está LIMPIO (statusSynced)
      await _syncQueueRepo.markAsSynced(
        bucketId: fileMeta.id,
        driveFileId: driveId,
        timestamp: now,
      );

      // 5. Actualización del ArchiveInfo (para el config.json final)
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
      // Opcional: markAsError(fileMeta.id) para no reintentar infinitamente
    }
  }

  return workingArchive;
}

// Helper sencillo para convertir el string de la DB al enum TypeQueue
TypeQueue _getTypeQueueFromStr(String type) {
  switch (type) {
    case 'tags': return TypeQueue.tags;
    case 'folders': return TypeQueue.folders;
    default: return TypeQueue.notes;
  }
}

  /// Helper para crear el Wrapper correcto según el tipo
  Future<SyncFileWrapper?> _createWrapper(
    TypeQueue type,
    LocalSyncQueue meta,
  ) async {
    final now = DateTime.now();
    switch (type) {
      case TypeQueue.tags:
        final items = await _tagsRepo.getByFileId(meta.id);
        if (items.isEmpty) return null;
        return TagsFile(
          id: meta.id,
          fileId: meta.driveFileId ?? '',
          tags: items,
          createdAt: now,
          updatedAt: now,
        );
      case TypeQueue.folders:
        final items = await _folderRepo.getByFileId(meta.id);
        if (items.isEmpty) return null;
        return FoldersFile(
          id: meta.id,
          fileId: meta.driveFileId ?? '',
          folders: items,
          createdAt: now,
          updatedAt: now,
        );
      case TypeQueue.notes:
        final items = await _notesRepo.getByFileId(meta.id);
        if (items.isEmpty) return null;
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
  );
});
