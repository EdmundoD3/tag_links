import 'package:flutter/widgets.dart';
import 'package:tag_links/repository/folder_repository.dart';
import 'package:tag_links/repository/notes_repository.dart';
import 'package:tag_links/repository/tags_repository.dart';
import 'package:tag_links/sync/db/local_sync_queue_repository.dart';
import 'package:tag_links/sync/drive_data_service.dart';
import 'package:tag_links/sync/models/archive_info.dart';
import 'package:tag_links/sync/models/archive_item.dart';
import 'package:tag_links/sync/models/delete_file.dart';
import 'package:tag_links/sync/models/folders_file.dart';
import 'package:tag_links/sync/models/notes_file.dart';
import 'package:tag_links/sync/models/tags_file.dart';

/// Se encarga exclusivamente de transformar lo que hay en Drive hacia SQLite.
class SyncPuller {
  final LocalSyncQueueRepository _syncQueueRepo;
  final DriveDataService _driveDataService;
  final NotesRepository _notesRepo;
  final FolderRepository _folderRepo;
  final TagsRepository _tagsRepo;
  SyncPuller({
    required LocalSyncQueueRepository syncQueueRepo,
    required DriveDataService driveDataService,
    required NotesRepository notesRepo,
    required FolderRepository folderRepo,
    required TagsRepository tagsRepo,
  }) : _driveDataService = driveDataService,
       _syncQueueRepo = syncQueueRepo,
       _notesRepo = notesRepo,
       _folderRepo = folderRepo,
       _tagsRepo = tagsRepo;

  Future<bool> processRemoteArchive({required ArchiveInfo remote}) async {
    try {
      //primero nos aseguramos que todos los files esten ligados a un archivo en drive
      await _syncQueueRepo.reconcileDriveIds(remote);
      return true;
    } catch (e) {
      debugPrint("SyncPuller.processRemoteArchive Error: $e");
      return false;
    }
  }

  Future<bool> processRemoteDeletes(
    List<ArchiveItem> deleteFiles,
    int lastPulledAt,
  ) async {
    //obtenemos los archivos que contengan datos por eliminar
    final porEliminar = deleteFiles.where(
      (item) => item.lastUpdate > lastPulledAt,
    );
    if (porEliminar.isEmpty) return true;
    try {
      List<String> deleteNotesIds = [];
      List<String> deleteFoldersIds = [];
      List<String> deleteTagsIds = [];

      for (var file in porEliminar) {
        // downloadArray suele devolver una lista. Como es un archivo wrapper,
        // tomamos el primero o cambiamos el método a downloadObject.
        final List<DeleteFile> remoteFiles = await _driveDataService
            .downloadArray<DeleteFile>(
              fileId: file.driveFileId!,
              fromMap: DeleteFile.fromMap,
            );

        if (remoteFiles.isNotEmpty) {
          // Tomamos el archivo descargado
          final dFile = remoteFiles.first;

          // Filtramos solo lo que se borró después de nuestra última sincronización
          final filtered = dFile.filterForDelete(lastPulledAt: lastPulledAt);

          if (!filtered.isEmpty) {
            // Ejecutamos los borrados en lote
            deleteNotesIds.addAll(filtered.notes.map((e) => e.id));
            deleteFoldersIds.addAll(filtered.folders.map((e) => e.id));
            deleteTagsIds.addAll(filtered.tags.map((e) => e.id));

            debugPrint(
              "Sincronización: Se eliminaron ${filtered.notes.length} notas remotas.",
            );
          }
        }
      }
      await _notesRepo.deleteByIds(deleteNotesIds);
      await _folderRepo.deleteByIds(deleteFoldersIds);
      await _tagsRepo.deleteByIds(deleteTagsIds);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> processRemoteData(ArchiveInfo remote, int lastPulledAt) async {
    try {
      // 1. Identificar archivos actualizados en Drive
      final updatedNotesFiles = remote.notes.where((f) => f.lastUpdate > lastPulledAt);
      final updatedFoldersFiles = remote.folders.where((f) => f.lastUpdate > lastPulledAt);
      final updatedTagsFiles = remote.tags.where((f) => f.lastUpdate > lastPulledAt);

      // --- PROCESAR ETIQUETAS (Importante ir de lo general a lo específico) ---
      for (var file in updatedTagsFiles) {
        final List<TagsFile> remoteFiles = await _driveDataService.downloadArray<TagsFile>(
          fileId: file.driveFileId!,
          fromMap: TagsFile.fromMap,
        );
        if (remoteFiles.isNotEmpty) {
          // UpsertAll debe manejar la lógica de "si existe y es más nuevo, actualiza"
          await _tagsRepo.upsertAll(remoteFiles.first.tags);
        }
      }

      // --- PROCESAR CARPETAS ---
      for (var file in updatedFoldersFiles) {
        final List<FoldersFile> remoteFiles = await _driveDataService.downloadArray<FoldersFile>(
          fileId: file.driveFileId!,
          fromMap: FoldersFile.fromMap,
        );
        if (remoteFiles.isNotEmpty) {
          await _folderRepo.upsertAll(remoteFiles.first.folders);
        }
      }

      // --- PROCESAR NOTAS ---
      for (var file in updatedNotesFiles) {
        final List<NotesFile> remoteFiles = await _driveDataService.downloadArray<NotesFile>(
          fileId: file.driveFileId!,
          fromMap: NotesFile.fromMap,
        );
        if (remoteFiles.isNotEmpty) {
          await _notesRepo.upsertAll(remoteFiles.first.notes);
        }
      }

      return true;
    } catch (e) {
      debugPrint("SyncPuller.processRemoteData Error: $e");
      return false;
    }
  }
}
