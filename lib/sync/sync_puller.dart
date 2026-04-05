import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tag_links/core/google/auth_provider.dart';
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

  SyncPuller({
    required LocalSyncQueueRepository syncQueueRepo,
    required DriveDataService driveDataService,
    required NotesRepository notesRepo,
    required FolderRepository folderRepo,
    required TagsRepository tagsRepo,
    required LocalSyncQueueRepository localSyncRepo,
  }) : _localSyncRepo = localSyncRepo,
       _driveDataService = driveDataService,
       _syncQueueRepo = syncQueueRepo,
       _notesRepo = notesRepo,
       _folderRepo = folderRepo,
       _tagsRepo = tagsRepo;

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
  final porEliminar = deleteFiles.where(
    (item) => item.lastUpdate > lastPulledAt,
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

      final List<DeleteFile> remoteFiles = await _driveDataService.downloadArray<DeleteFile>(
        fileId: file.driveFileId!,
        fromMap: DeleteFile.fromMap,
        fileName: file.fileName,
      );

      if (remoteFiles.isNotEmpty) {
        final dFile = remoteFiles.first;
        final filtered = dFile.filterForDelete(lastPulledAt: lastPulledAt);

        if (!filtered.isEmpty) {
          deleteNotesIds.addAll(filtered.notes.map((e) => e.id));
          deleteFoldersIds.addAll(filtered.folders.map((e) => e.id));
          deleteTagsIds.addAll(filtered.tags.map((e) => e.id));
        }
      }
    } on PathNotFoundException catch (e) {
      debugPrint("扫 Archivo de borrado fantasma detectado: ${e.fileId}");
      await _localSyncRepo.clearDriveId(file.id);
    } catch (e) {
      debugPrint("❌ Error de red/desconocido en deletes: $e");
      hadError = true;
    }
  }

  // Ejecutamos los borrados y detectamos si hubo cambios reales
  bool notesChanged = false;
  bool foldersChanged = false;
  bool tagsChanged = false;

  try {
    if (deleteNotesIds.isNotEmpty) {
      await _notesRepo.deleteByIds(deleteNotesIds);
      notesChanged = true;
    }
    if (deleteFoldersIds.isNotEmpty) {
      await _folderRepo.deleteByIds(deleteFoldersIds);
      foldersChanged = true;
    }
    if (deleteTagsIds.isNotEmpty) {
      await _tagsRepo.deleteByIds(deleteTagsIds);
      tagsChanged = true;
    }
  } catch (e) {
    debugPrint("❌ Error al ejecutar borrados en DB local: $e");
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
    bool overallSuccess = true;
    bool notesChanged = false;
    bool foldersChanged = false;
    bool tagsChanged = false;

    // --- PROCESAR ETIQUETAS, CARPETAS Y NOTAS (Estructura similar para todos) ---
    final allCategories = [
      {'items': remote.tags, 'type': TypeQueue.tags, 'repo': _tagsRepo},
      {'items': remote.folders, 'type': TypeQueue.folders, 'repo': _folderRepo},
      {'items': remote.notes, 'type': TypeQueue.notes, 'repo': _notesRepo},
    ];

    for (var cat in allCategories) {
      final items = (cat['items'] as List<ArchiveItem>).where(
        (f) => f.lastUpdate > lastPulledAt,
      );
      final type = cat['type'] as TypeQueue;
      final repo = cat['repo'];

      for (var file in items) {
        try {
          await _registerFileInQueue(file, type);
          if (file.driveFileId == null) continue;

          // Intentamos descargar según el tipo
          if (type == TypeQueue.tags) {
            final res = await _driveDataService.downloadArray<TagsFile>(
              fileId: file.driveFileId!,
              fromMap: TagsFile.fromMap,
              fileName: file.fileName,
            );
            if (res.isNotEmpty) {
              await _tagsRepo.upsertAll(res.first.tags);
              tagsChanged = true; // <--- Marcamos cambio
            }
          } else if (type == TypeQueue.folders) {
            final res = await _driveDataService.downloadArray<FoldersFile>(
              fileId: file.driveFileId!,
              fromMap: FoldersFile.fromMap,
              fileName: file.fileName,
            );
            if (res.isNotEmpty) {
              await _folderRepo.upsertAll(res.first.folders);
              foldersChanged = true; // <--- Marcamos cambio
            }
          } else {
            final res = await _driveDataService.downloadArray<NotesFile>(
              fileId: file.driveFileId!,
              fromMap: NotesFile.fromMap,
              fileName: file.fileName,
            );
            if (res.isNotEmpty) {
              await _notesRepo.upsertAll(res.first.notes);
              notesChanged = true; // <--- Marcamos cambio
            }
          }
        } on PathNotFoundException catch (e) {
          debugPrint("🧹 Archivo fantasma detectado y limpiando: ${e.fileId}");
          await _localSyncRepo.clearDriveId(
            file.id,
          ); // Usamos el ID local del bucket
          // No retornamos false, dejamos que siga con el siguiente archivo
        } catch (e) {
          debugPrint("❌ Error grave en ${file.fileName}: $e");
          overallSuccess =
              false; // Algo salió mal (ej. red), pero intentaremos los demás
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
    // Aquí usamos tu repositorio de colas para hacer un upsert del archivo
    // 'remoteFile.id' es el UUID local que vive en el nombre del archivo en Drive
    await _localSyncRepo.upsert(
      LocalSyncQueue(
        id: remoteFile.id, // El ID que las carpetas/notas usan como fileId
        driveFileId: remoteFile.driveFileId,
        fileName: remoteFile.fileName,
        lastUpdate: remoteFile.lastUpdate,
        type: type.tableName,
        syncStatus: 1, // Ya está en la nube (Synced)
        itemCount: 0, // Se actualizará después si es necesario
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
  );
});
