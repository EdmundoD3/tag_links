import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/google/auth_provider.dart';
import 'package:tag_links/repository/deletes_repository.dart';
import 'package:tag_links/repository/folder_repository.dart';
import 'package:tag_links/repository/notes_repository.dart';
import 'package:tag_links/repository/tags_repository.dart';
import 'package:tag_links/sync/db/local_sync_queue_repository.dart';
import 'package:tag_links/sync/drive_data_service.dart';
import 'package:tag_links/sync/exceptions/path_not_found.dart';
import 'package:tag_links/sync/models/archive_info.dart';
import 'package:tag_links/sync/models/archive_item.dart';
import 'package:tag_links/sync/models/delete_file.dart';
import 'package:tag_links/sync/models/folders_file.dart';
import 'package:tag_links/sync/models/local_sync_queue.dart';
import 'package:tag_links/sync/models/notes_file.dart';
import 'package:tag_links/sync/models/pull_result.dart';
import 'package:tag_links/sync/models/tags_file.dart';

/// Se encarga exclusivamente de transformar lo que hay en Drive hacia SQLite.
class SyncPuller {
  final LocalSyncQueueRepository _syncQueueRepo;
  final DriveDataService _driveDataService;
  final NotesRepository _notesRepo;
  final FolderRepository _folderRepo;
  final TagsRepository _tagsRepo;
  final LocalSyncQueueRepository _localSyncRepo;
  final DeletesRepository _deletesRepo;

  SyncPuller({
    required LocalSyncQueueRepository syncQueueRepo,
    required DriveDataService driveDataService,
    required NotesRepository notesRepo,
    required FolderRepository folderRepo,
    required TagsRepository tagsRepo,
    required LocalSyncQueueRepository localSyncRepo,
    required DeletesRepository deletesRepo,
  }) : _localSyncRepo = localSyncRepo,
       _driveDataService = driveDataService,
       _syncQueueRepo = syncQueueRepo,
       _notesRepo = notesRepo,
       _folderRepo = folderRepo,
       _tagsRepo = tagsRepo,
       _deletesRepo = deletesRepo;

  Future<PullResult> processRemoteArchive({required ArchiveInfo remote}) async {
    try {
      // 1. Sincronizamos los IDs de Drive con nuestra tabla local de buckets (LocalSyncQueue)
      // Esto es vital para que downloadArray sepa de dónde bajar los archivos después.
      await _syncQueueRepo.reconcileDriveIds(remote);

      // Retornamos éxito. success: true indica que el mapeo fue correcto.
      return PullResult(success: true);
    } catch (e) {
      debugPrint("❌ SyncPuller.processRemoteArchive Error: $e");
      // Si esto falla, es un error crítico (probablemente DB local) y debemos detener la sincronización.
      return PullResult(success: false);
    }
  }

  Future<PullResult> processRemoteDeletes(
    List<ArchiveItem> deleteFiles,
    int lastPulledAt,
  ) async {
    final enshureLastPulledAt =
        lastPulledAt - const Duration(minutes: 15).inMilliseconds;
    final porEliminar = deleteFiles.where(
      (item) => item.lastUpdate > enshureLastPulledAt,
    );

    // Si no hay archivos de borrado nuevos, terminamos rápido
    if (porEliminar.isEmpty) return PullResult(success: true);

    List<String> deleteNotesIds = [];
    List<String> deleteFoldersIds = [];
    List<String> deleteTagsIds = [];
    bool hadError = false;

    for (var file in porEliminar) {
      try {
        if (file.driveFileId == null) continue;

        final List<DeleteFile> remoteFiles = await _driveDataService
            .downloadArray<DeleteFile>(
              fileId: file.driveFileId!,
              fromMap: DeleteFile.fromMap,
              fileName: file.fileName,
            );

        if (remoteFiles.isNotEmpty) {
          final dFile = remoteFiles.first;
          final filtered = dFile.filterForDelete(
            lastPulledAt: enshureLastPulledAt,
          );

          if (!filtered.isEmpty) {
            deleteNotesIds.addAll(filtered.notes.map((e) => e.id));
            deleteFoldersIds.addAll(filtered.folders.map((e) => e.id));
            deleteTagsIds.addAll(filtered.tags.map((e) => e.id));
          }
        }
      } on PathNotFoundException catch (e) {
        debugPrint(
          "SyncPuller: 扫 Archivo de borrado fantasma detectado: ${e.fileId}",
        );
        await _localSyncRepo.clearDriveId(file.id);
      } catch (e) {
        debugPrint("❌ SyncPuller Error de red/desconocido en deletes: $e");
        hadError = true;
      }
    }

    // Ejecutamos los borrados y detectamos si hubo cambios reales
    bool notesChanged = false;
    bool foldersChanged = false;
    bool tagsChanged = false;

    try {
      if (deleteNotesIds.isNotEmpty) {
        await _notesRepo.serverDeleteByIds(deleteNotesIds);
        notesChanged = true;
      }
      if (deleteFoldersIds.isNotEmpty) {
        await _folderRepo.serverDeleteByIds(deleteFoldersIds);
        foldersChanged = true;
      }
      if (deleteTagsIds.isNotEmpty) {
        await _tagsRepo.serverDeleteByIds(deleteTagsIds);
        tagsChanged = true;
      }
    } catch (e) {
      debugPrint("❌ SyncPuller Error al ejecutar borrados en DB local: $e");
      return PullResult(success: false);
    }

    return PullResult(
      success: !hadError,
      notesChanged: notesChanged,
      foldersChanged: foldersChanged,
      tagsChanged: tagsChanged,
    );
  }

  Future<PullResult> processRemoteData(
    ArchiveInfo remote,
    int lastPulledAt,
  ) async {
    // 1. Aplicamos el margen de seguridad (15 min antes) para no perder nada por desfase de relojes
    final ensureLastPulledAt =
        lastPulledAt - const Duration(minutes: 15).inMilliseconds;

    bool overallSuccess = true;
    bool notesChanged = false;
    bool foldersChanged = false;
    bool tagsChanged = false;

    final allCategories = [
      {'items': remote.deletes, 'type': TypeQueue.deletes},
      {'items': remote.tags, 'type': TypeQueue.tags},
      {'items': remote.folders, 'type': TypeQueue.folders},
      {'items': remote.notes, 'type': TypeQueue.notes},
    ];

    for (var cat in allCategories) {
      final type = cat['type'] as TypeQueue;

      final itemsToDownload = (cat['items'] as List<ArchiveItem>).where(
        (f) => f.lastUpdate > ensureLastPulledAt,
      );

      for (var file in itemsToDownload) {
        try {
          if (file.driveFileId == null) continue;

          if (type == TypeQueue.tags) {
            final res = await _driveDataService.downloadArray<TagsFile>(
              fileId: file.driveFileId!,
              fromMap: TagsFile.fromMap,
              fileName: file.fileName,
            );
            if (res.isNotEmpty) {
              await _tagsRepo.upsertAll(res.first.tags);
              tagsChanged = true;
            }
          } else if (type == TypeQueue.folders) {
            final res = await _driveDataService.downloadArray<FoldersFile>(
              fileId: file.driveFileId!,
              fromMap: FoldersFile.fromMap,
              fileName: file.fileName,
            );
            if (res.isNotEmpty) {
              await _folderRepo.upsertAll(res.first.folders);
              foldersChanged = true;
            }
          } else if (type == TypeQueue.notes) {
            final res = await _driveDataService.downloadArray<NotesFile>(
              fileId: file.driveFileId!,
              fromMap: NotesFile.fromMap,
              fileName: file.fileName,
            );
            if (res.isNotEmpty) {
              await _notesRepo.upsertAll(res.first.notes);
              notesChanged = true;
            }
          } else if (type == TypeQueue.deletes) {
            final res = await _driveDataService.downloadArray<DeleteFile>(
              fileId: file.driveFileId!,
              fromMap: DeleteFile.fromMap,
              fileName: file.fileName,
            );
            if (res.isNotEmpty) {
              await _deletesRepo.upsertAllFromRemote(res.first);
            }
          }

          // 2. REGISTRO POST-DESCARGA EXITOSA:
          // Actualiza el estado local para decir "ya estoy al día con este archivo"
          await _registerFileInQueue(file, type);
        } on PathNotFoundException catch (e) {
          debugPrint(
            "🧹 SyncPuller: Archivo fantasma detectado en Drive: ${e.fileId}",
          );

          // 🎯 ESTRATEGIA DE AUTOCURACIÓN:
          // Ponemos el driveFileId en NULL y el syncStatus en DIRTY (2).
          // Al hacer esto, el SyncPusher verá que el archivo "debe" existir pero no está en Drive,
          // y lo subirá de nuevo automáticamente en el siguiente ciclo.
          await _localSyncRepo.markAsDeletedInDrive(file.id);

          // No marcamos overallSuccess como false porque estamos saneando la base de datos
        } catch (e) {
          debugPrint(
            "❌ SyncPuller.processRemoteData Error en bucket ${file.fileName}: $e",
          );
          overallSuccess = false;
        }
      }
    }

    return PullResult(
      success: overallSuccess,
      notesChanged: notesChanged,
      foldersChanged: foldersChanged,
      tagsChanged: tagsChanged,
    );
  }

  // Helper para registrar el "Cubo" en la tabla de sincronización local
  Future<void> _registerFileInQueue(
    ArchiveItem remoteFile,
    TypeQueue type,
  ) async {
    await _localSyncRepo.upsert(
      LocalSyncQueue(
        id: remoteFile.id,
        driveFileId: remoteFile.driveFileId,
        fileName: remoteFile.fileName,
        lastUpdate: remoteFile.lastUpdate, // La estampa de tiempo de Drive
        type: type.tableName,
        syncStatus: SyncStatus.synced, // Constante de statusSynced
        itemCount:
            0, // Se puede recalcular con refreshAllCounts() al final del proceso
      ),
    );
  }
}

final syncPullerProvider = Provider<SyncPuller?>((ref) {
  final auth = ref.watch(authProvider);

  if (auth.driveApi == null) return null;

  final dataService = DriveDataService(auth.driveApi!);

  return SyncPuller(
    syncQueueRepo: ref.watch(localSyncQueueRepositoryProvider),
    driveDataService: dataService,
    notesRepo: ref.watch(notesRepositoryProvider),
    folderRepo: ref.watch(folderRepositoryProvider),
    tagsRepo: ref.watch(tagsRepositoryProvider),
    localSyncRepo: ref.watch(localSyncQueueRepositoryProvider),
    deletesRepo: ref.watch(deletesRepositoryProvider),
  );
});
